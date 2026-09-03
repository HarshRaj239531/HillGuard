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
      _startPeerCleanupTimer();
      debugPrint('P2PSocketService: Started successfully on UDP $udpDiscoveryPort & TCP $tcpMeshPort');
    } catch (e) {
      debugPrint('P2PSocketService start note: $e');
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    _beaconTimer?.cancel();
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
        final payload = buffer.toString();
        socket.destroy();
        if (payload.isNotEmpty) {
          try {
            final map = json.decode(payload) as Map<String, dynamic>;
            final packet = MeshPacket.fromMap(map);
            onPacketReceived(packet, remoteIp);
          } catch (e) {
            debugPrint('Failed to parse incoming mesh packet: $e');
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
            _handleUdpBeacon(datagram);
          }
        }
      });
    } catch (e) {
      debugPrint('Could not bind UDP discovery socket: $e');
    }
  }

  void _handleUdpBeacon(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final jsonMap = json.decode(message) as Map<String, dynamic>;

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
    } catch (e) {
      // Ignore malformed broadcast frames
    }
  }

  void _startBeaconTimer() {
    _beaconTimer?.cancel();
    _beaconTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _sendUdpBeacon();
    });
    // Send immediate beacon
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
      // Broadcast to standard subnet broadcast
      _udpSocket?.send(bytes, InternetAddress('255.255.255.255'), udpDiscoveryPort);

      // Also send directly to common Android Hotspot gateway IPs
      _udpSocket?.send(bytes, InternetAddress('192.168.43.1'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.43.255'), udpDiscoveryPort);
      _udpSocket?.send(bytes, InternetAddress('192.168.1.255'), udpDiscoveryPort);
    } catch (e) {
      // Ignored for non-routable interfaces
    }
  }

  void _startPeerCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now();
      final expired = <String>[];

      _discoveredPeers.forEach((id, peer) {
        if (now.difference(peer.lastSeen).inSeconds > 15) {
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

  /// Broadcast a Mesh Packet to all physically discovered phones over TCP
  Future<int> broadcastPacket(MeshPacket packet) async {
    final payloadJson = packet.toJson();
    final bytes = utf8.encode(payloadJson);
    int successCount = 0;

    // Send to each discovered peer
    final currentPeers = List<DiscoveredSocketPeer>.from(peers);

    for (final peer in currentPeers) {
      try {
        final socket = await Socket.connect(
          peer.address,
          peer.tcpPort,
          timeout: const Duration(seconds: 2),
        );
        socket.add(bytes);
        await socket.flush();
        await socket.close();
        successCount++;
        debugPrint('Transmitted packet ${packet.packetId} to physical peer ${peer.address.address}:${peer.tcpPort}');
      } catch (e) {
        debugPrint('Failed transmitting packet to ${peer.address.address}: $e');
      }
    }

    // Opportunistic fallback: If Phone B connected to Phone A's hotspot,
    // Phone A's gateway IP is typically 192.168.43.1
    try {
      final gatewaySocket = await Socket.connect(
        InternetAddress('192.168.43.1'),
        tcpMeshPort,
        timeout: const Duration(milliseconds: 500),
      );
      gatewaySocket.add(bytes);
      await gatewaySocket.flush();
      await gatewaySocket.close();
      successCount++;
    } catch (_) {
      // Gateway unreachable, normal
    }

    return successCount;
  }
}
