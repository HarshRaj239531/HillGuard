import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/mesh_packet.dart';

class DiscoveredSocketPeer {
  final String peerId;
  final String name;
  final InternetAddress address;
  final int tcpPort;
  DateTime lastSeen;

  DiscoveredSocketPeer({
    required this.peerId,
    required this.name,
    required this.address,
    required this.tcpPort,
    required this.lastSeen,
  });
}

class P2PSocketService {
  static const int udpDiscoveryPort = 44555;
  static const int tcpMeshPort = 44556;

  final String localNodeId;
  final String localNodeName;
  final Function(MeshPacket packet, String fromIp) onPacketReceived;
  final Function(List<DiscoveredSocketPeer> peers) onPeersUpdated;

  RawDatagramSocket? _udpSocket;
  ServerSocket? _tcpServer;
  Timer? _beaconTimer;
  Timer? _subnetProbeTimer;
  Timer? _cleanupTimer;

  final Map<String, DiscoveredSocketPeer> _discoveredPeers = {};
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  List<DiscoveredSocketPeer> get peers => _discoveredPeers.values.toList();

  P2PSocketService({
    required this.localNodeId,
    required this.localNodeName,
    required this.onPacketReceived,
    required this.onPeersUpdated,
  });

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      await _startTcpServer();
      await _startUdpDiscovery();
      _startBeaconTimer();
      _startSubnetProbeTimer();
      _startPeerCleanupTimer();
      debugPrint('P2PSocketService: Started successfully on UDP $udpDiscoveryPort & TCP $tcpMeshPort');
    } catch (e) {
      debugPrint('P2PSocketService start note: $e');
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    _beaconTimer?.cancel();
    _subnetProbeTimer?.cancel();
    _cleanupTimer?.cancel();
    _udpSocket?.close();
    await _tcpServer?.close();
    _discoveredPeers.clear();
  }

  Future<void> _startTcpServer() async {
    try {
      _tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, tcpMeshPort);
      _tcpServer?.listen((Socket clientSocket) {
        _handleIncomingTcpClient(clientSocket);
      }, onError: (e) {
        debugPrint('TCP Server listen error: $e');
      });
    } catch (e) {
      debugPrint('Could not bind TCP server on port $tcpMeshPort: $e');
    }
  }

  void _handleIncomingTcpClient(Socket socket) {
    final buffer = StringBuffer();
    final remoteIp = socket.remoteAddress.address;

    socket.listen(
      (List<int> data) {
        buffer.write(utf8.decode(data));
      },
      onDone: () {
        final payload = buffer.toString().trim();
        socket.destroy();
        if (payload.isNotEmpty) {
          try {
            final map = json.decode(payload) as Map<String, dynamic>;

            // Handle Direct Peer Handshake
            if (map['type'] == 'HANDSHAKE') {
              final peerId = map['nodeId'] as String?;
              final peerName = map['name'] as String? ?? 'Nearby Mobile Peer';
              final port = map['tcpPort'] as int? ?? tcpMeshPort;

              if (peerId != null && peerId != localNodeId) {
                _discoveredPeers[peerId] = DiscoveredSocketPeer(
                  peerId: peerId,
                  name: peerName,
                  address: socket.remoteAddress,
                  tcpPort: port,
                  lastSeen: DateTime.now(),
                );
                onPeersUpdated(peers);
                debugPrint('TCP Handshake registered peer: $peerId @ $remoteIp');
              }
              return;
            }

            // Handle Full Mesh Packet
            if (map.containsKey('packetId') && map.containsKey('payload')) {
              final packet = MeshPacket.fromMap(map);

              // Auto-register the sender as an active peer
              if (packet.originalSenderId != localNodeId) {
                _discoveredPeers[packet.originalSenderId] = DiscoveredSocketPeer(
                  peerId: packet.originalSenderId,
                  name: 'Peer Unit ($remoteIp)',
                  address: socket.remoteAddress,
                  tcpPort: tcpMeshPort,
                  lastSeen: DateTime.now(),
                );
                onPeersUpdated(peers);
              }

              onPacketReceived(packet, remoteIp);
            }
          } catch (e) {
            debugPrint('Failed to parse incoming TCP payload: $e');
          }
        }
      },
      onError: (e) {
        debugPrint('TCP socket incoming error: $e');
        socket.destroy();
      },
    );
  }

  Future<void> _startUdpDiscovery() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        udpDiscoveryPort,
        reuseAddress: true,
      );
      _udpSocket?.broadcastEnabled = true;

      _udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket?.receive();
          if (datagram != null) {
            _handleIncomingUdpDatagram(datagram);
          }
        }
      });
    } catch (e) {
      debugPrint('Could not bind UDP discovery socket: $e');
    }
  }

  void _handleIncomingUdpDatagram(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final jsonMap = json.decode(message) as Map<String, dynamic>;

      // 1. Check if this is a direct Mesh Packet broadcast over UDP
      if (jsonMap.containsKey('packetId') && jsonMap.containsKey('payload')) {
        final packet = MeshPacket.fromMap(jsonMap);
        if (packet.originalSenderId != localNodeId) {
          debugPrint('UDP Datagram received MeshPacket ${packet.packetId} from ${datagram.address.address}');
          onPacketReceived(packet, datagram.address.address);
        }
        return;
      }

      // 2. Otherwise handle discovery beacon
      final peerId = jsonMap['nodeId'] as String?;
      final peerName = jsonMap['name'] as String? ?? 'Nearby Mobile Node';
      final tcpPort = jsonMap['tcpPort'] as int? ?? tcpMeshPort;

      if (peerId != null && peerId != localNodeId) {
        _discoveredPeers[peerId] = DiscoveredSocketPeer(
          peerId: peerId,
          name: peerName,
          address: datagram.address,
          tcpPort: tcpPort,
          lastSeen: DateTime.now(),
        );
        onPeersUpdated(peers);
      }
    } catch (_) {}
  }

  void _startBeaconTimer() {
    _beaconTimer?.cancel();
    _beaconTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _sendUdpBeacon();
    });
    _sendUdpBeacon();
  }

  void _sendUdpBeacon() {
    if (_udpSocket == null) return;

    final beaconData = json.encode({
      'type': 'BEACON',
      'nodeId': localNodeId,
      'name': localNodeName,
      'tcpPort': tcpMeshPort,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final bytes = utf8.encode(beaconData);

    try {
      _udpSocket?.send(bytes, InternetAddress('255.255.255.255'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.43.1'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.43.255'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.1.255'), udpDiscoveryPort);
    } catch (_) {}
  }

  /// Proactive Subnet Prober: Sweeps gateway and clients over TCP
  void _startSubnetProbeTimer() {
    _subnetProbeTimer?.cancel();
    _subnetProbeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      _probeHotspotSubnet();
    });
    _probeHotspotSubnet();
  }

  Future<List<String>> _getArpTableIps() async {
    final ips = <String>[];
    try {
      final file = File('/proc/net/arp');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        for (final line in lines.skip(1)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty && parts[0].contains('.') && parts[0] != '0.0.0.0') {
            ips.add(parts[0]);
          }
        }
      }
    } catch (_) {}
    return ips;
  }

  Future<void> _probeHotspotSubnet() async {
    final candidateIps = <String>{
      '192.168.43.1', // Android Hotspot Host
    };

    // Read connected clients from kernel ARP table (instant on Android!)
    final arpIps = await _getArpTableIps();
    candidateIps.addAll(arpIps);

    // Dynamic interface subnet detection
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
              candidateIps.add('$prefix.1');
            }
          }
        }
      }
    } catch (_) {}

    final handshakePayload = json.encode({
      'type': 'HANDSHAKE',
      'nodeId': localNodeId,
      'name': localNodeName,
      'tcpPort': tcpMeshPort,
    });

    for (final ip in candidateIps) {
      try {
        final socket = await Socket.connect(
          ip,
          tcpMeshPort,
          timeout: const Duration(seconds: 1),
        );
        socket.write(handshakePayload);
        await socket.flush();
        await socket.close();
      } catch (_) {}
    }
  }

  void _startPeerCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final now = DateTime.now();
      final expired = <String>[];

      _discoveredPeers.forEach((id, peer) {
        if (now.difference(peer.lastSeen).inSeconds > 45) {
          expired.add(id);
        }
      });

      if (expired.isNotEmpty) {
        for (final id in expired) {
          _discoveredPeers.remove(id);
        }
        onPeersUpdated(peers);
      }
    });
  }

  /// Broadcast a Mesh Packet to all physical peers using Dual-Channel Delivery:
  /// Channel 1: UDP Broadcast & Direct Subnet Blast (Instant, zero 3-way handshake)
  /// Channel 2: TCP Direct Transmission to all registered peers, ARP clients, and gateway
  Future<int> broadcastPacket(MeshPacket packet) async {
    final payloadJson = packet.toJson();
    final bytes = utf8.encode(payloadJson);
    int successCount = 0;

    // CHANNEL 1: Instant UDP Broadcast Delivery (Blasts to broadcast and gateway)
    try {
      _udpSocket?.send(bytes, InternetAddress('255.255.255.255'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.43.255'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.43.1'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.1.255'), udpDiscoveryPort);

      // Also send UDP directly to all known peers
      for (final peer in peers) {
        _udpSocket?.send(bytes, peer.address, udpDiscoveryPort);
      }
    } catch (e) {
      debugPrint('UDP broadcast dispatch note: $e');
    }

    // CHANNEL 2: Guaranteed TCP Stream Delivery
    final targetIps = <String>{};

    // 1. All explicitly discovered peers
    for (final peer in peers) {
      targetIps.add(peer.address.address);
    }

    // 2. Android Hotspot Host Gateway
    targetIps.add('192.168.43.1');

    // 3. Android Kernel ARP connected clients
    final arpClients = await _getArpTableIps();
    targetIps.addAll(arpClients);

    // 4. Interface subnets
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
              targetIps.add('$prefix.1');
            }
          }
        }
      }
    } catch (_) {}

    // Dispatch TCP to all target candidates with a reliable 2s timeout
    for (final ip in targetIps) {
      try {
        final socket = await Socket.connect(
          ip,
          tcpMeshPort,
          timeout: const Duration(seconds: 2),
        );
        socket.add(bytes);
        await socket.flush();
        await socket.close();
        successCount++;
        debugPrint('P2P Mesh: Successfully delivered packet via TCP to $ip:$tcpMeshPort');
      } catch (_) {}
    }

    return successCount;
  }
}
