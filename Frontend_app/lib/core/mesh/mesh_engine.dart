import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/hazard_types.dart';
import '../models/landslide_report.dart';
import '../models/road_report.dart';
import '../models/mesh_packet.dart';
import '../storage/local_store.dart';

class MeshPeer {
  final String peerId;
  final String name;
  final String role; // e.g. "Patrol Vehicle", "Relief Camp Node", "Local Resident"
  final int signalStrengthDbm; // e.g. -65 dBm
  final DateTime lastSeen;
  final bool isDirectNeighbor;

  MeshPeer({
    required this.peerId,
    required this.name,
    required this.role,
    required this.signalStrengthDbm,
    required this.lastSeen,
    this.isDirectNeighbor = true,
  });
}

class MeshRelayEvent {
  final String id;
  final DateTime timestamp;
  final String title;
  final String description;
  final String packetId;
  final int hopCount;
  final bool isIncoming;

  MeshRelayEvent({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.packetId,
    required this.hopCount,
    required this.isIncoming,
  });
}

class MeshEngine extends ChangeNotifier {
  final LocalStore localStore;
  final String deviceId = 'node-${const Uuid().v4().substring(0, 6)}';

  final List<MeshPeer> _activePeers = [];
  final List<MeshRelayEvent> _relayLogs = [];
  bool _isMeshBroadcasting = true;

  List<MeshPeer> get activePeers => List.unmodifiable(_activePeers);
  List<MeshRelayEvent> get relayLogs => List.unmodifiable(_relayLogs);
  bool get isMeshBroadcasting => _isMeshBroadcasting;

  MeshEngine({required this.localStore}) {
    _initSimulatedPeers();
  }

  void _initSimulatedPeers() {
    _activePeers.addAll([
      MeshPeer(
        peerId: 'peer-relay-beta',
        name: 'Rescue Van 04 (BLE)',
        role: 'Disaster Rapid Response',
        signalStrengthDbm: -58,
        lastSeen: DateTime.now(),
      ),
      MeshPeer(
        peerId: 'peer-relay-gamma',
        name: 'Tindharia Checkpost',
        role: 'Stationary Solar Node',
        signalStrengthDbm: -72,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      MeshPeer(
        peerId: 'peer-relay-delta',
        name: 'Darjeeling Courier',
        role: 'Mobile Vehicle Node',
        signalStrengthDbm: -81,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  void toggleBroadcasting() {
    _isMeshBroadcasting = !_isMeshBroadcasting;
    notifyListeners();
  }

  // Broadcast a newly authored Landslide report into the mesh
  Future<void> broadcastLandslideReport(LandslideReport report) async {
    final packet = MeshPacket(
      packetId: const Uuid().v4(),
      type: MeshPacketType.landslideReport,
      payload: report.toJson(),
      originalSenderId: deviceId,
      createdAt: DateTime.now(),
      maxTtl: 5,
      currentHop: 0,
      priority: report.severity == HazardSeverity.critical ? 3 : 2,
    );

    await localStore.enqueueMeshPacket(packet);

    _logEvent(
      title: 'Dispatched B1 Landslide Packet to Mesh',
      description: 'Broadcasting ${report.locationDescription} [${report.severity.displayName}] to ${_activePeers.length} direct BLE peers.',
      packetId: packet.packetId,
      hopCount: 0,
      isIncoming: false,
    );
  }

  // Broadcast a newly authored Road report into the mesh
  Future<void> broadcastRoadReport(RoadReport report) async {
    final packet = MeshPacket(
      packetId: const Uuid().v4(),
      type: MeshPacketType.roadReport,
      payload: report.toJson(),
      originalSenderId: deviceId,
      createdAt: DateTime.now(),
      maxTtl: 5,
      currentHop: 0,
      priority: report.status == RoadConditionStatus.blocked ? 3 : 2,
    );

    await localStore.enqueueMeshPacket(packet);

    _logEvent(
      title: 'Dispatched B6 Road Blockage Packet to Mesh',
      description: 'Relaying ${report.roadIdentifier} status: ${report.status.label} across peer mesh.',
      packetId: packet.packetId,
      hopCount: 0,
      isIncoming: false,
    );
  }

  // Ingest an incoming mesh packet from a peer
  Future<bool> ingestIncomingPacket(MeshPacket incomingPacket, String fromPeerId) async {
    // Deduplication check
    if (localStore.hasSeenPacket(incomingPacket.packetId)) {
      debugPrint('MeshEngine: Dropping duplicate packet ${incomingPacket.packetId}');
      return false;
    }

    localStore.markPacketSeen(incomingPacket.packetId);

    // Increment hop count & trace path
    incomingPacket.addHop(deviceId);

    _logEvent(
      title: 'Mesh Packet Relayed from $fromPeerId',
      description: 'Hop ${incomingPacket.currentHop}/${incomingPacket.maxTtl}. Origin: ${incomingPacket.originalSenderId}',
      packetId: incomingPacket.packetId,
      hopCount: incomingPacket.currentHop,
      isIncoming: true,
    );

    try {
      if (incomingPacket.type == MeshPacketType.landslideReport) {
        final reportMap = json.decode(incomingPacket.payload) as Map<String, dynamic>;
        final report = LandslideReport.fromMap(reportMap);
        report.syncStatus = SyncStatus.relayedViaMesh;
        report.relayHops = incomingPacket.currentHop;
        report.lastRelayPeer = fromPeerId;
        await localStore.saveLandslideReport(report);
      } else if (incomingPacket.type == MeshPacketType.roadReport) {
        final reportMap = json.decode(incomingPacket.payload) as Map<String, dynamic>;
        final report = RoadReport.fromMap(reportMap);
        report.syncStatus = SyncStatus.relayedViaMesh;
        report.relayHops = incomingPacket.currentHop;
        report.lastRelayPeer = fromPeerId;
        await localStore.saveRoadReport(report);
      }

      // Re-forward to other peers if TTL not reached
      if (!incomingPacket.isExpired && _isMeshBroadcasting) {
        await localStore.enqueueMeshPacket(incomingPacket);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('MeshEngine ingest error: $e');
      return false;
    }
  }

  // Simulation Helper for Hackathon / Testing
  Future<void> simulatePeerRelayInjection() async {
    final random = Random();
    final isLandslide = random.nextBool();
    final randomPeer = _activePeers[random.nextInt(_activePeers.length)].peerId;

    if (isLandslide) {
      final simulatedReport = LandslideReport(
        id: 'ls-sim-${const Uuid().v4().substring(0, 6)}',
        timestamp: DateTime.now(),
        latitude: 26.9100 + (random.nextDouble() - 0.5) * 0.05,
        longitude: 88.3200 + (random.nextDouble() - 0.5) * 0.05,
        locationDescription: 'Hill Ridge Cut, KM 24',
        severity: HazardSeverity.critical,
        detectedFeatures: [
          LandslideFeature.tensionCrack,
          LandslideFeature.slopeBulge,
          LandslideFeature.wallDeformation,
        ],
        estimatedSlopeAngle: 52.0,
        plainLanguageExplanation:
            'Critical crown deformation and toe bulging reported by field patrol. High likelihood of sudden catastrophic slope detachment.',
        recommendedSafetyActions: [
          'Immediate full evacuation.',
          'Close downhill vehicular bridge.',
          'Set up safe perimeter 250m away.',
        ],
        reporterId: randomPeer,
        syncStatus: SyncStatus.relayedViaMesh,
        relayHops: 2,
        lastRelayPeer: randomPeer,
      );

      final packet = MeshPacket(
        packetId: const Uuid().v4(),
        type: MeshPacketType.landslideReport,
        payload: simulatedReport.toJson(),
        originalSenderId: 'ranger-node-09',
        createdAt: DateTime.now(),
        currentHop: 2,
        maxTtl: 5,
        relayPath: ['ranger-node-09', randomPeer],
      );

      await ingestIncomingPacket(packet, randomPeer);
    } else {
      final simulatedRoad = RoadReport(
        id: 'rd-sim-${const Uuid().v4().substring(0, 6)}',
        roadIdentifier: 'NH-55 Bypass',
        sectionName: 'Giddapahar Turn',
        status: RoadConditionStatus.blocked,
        obstacleType: RoadObstacleType.rockfall,
        latitude: 26.8920 + (random.nextDouble() - 0.5) * 0.04,
        longitude: 88.2950 + (random.nextDouble() - 0.5) * 0.04,
        timestamp: DateTime.now(),
        estimatedClearanceTime: '3 Hours',
        passableByTwoWheeler: false,
        passableBy4x4: false,
        description: 'Large granitic boulder dislodged from overhang. Path completely obstructed.',
        reporterId: randomPeer,
        syncStatus: SyncStatus.relayedViaMesh,
        relayHops: 1,
        lastRelayPeer: randomPeer,
      );

      final packet = MeshPacket(
        packetId: const Uuid().v4(),
        type: MeshPacketType.roadReport,
        payload: simulatedRoad.toJson(),
        originalSenderId: 'taxi-union-44',
        createdAt: DateTime.now(),
        currentHop: 1,
        maxTtl: 5,
        relayPath: ['taxi-union-44', randomPeer],
      );

      await ingestIncomingPacket(packet, randomPeer);
    }
  }

  void _logEvent({
    required String title,
    required String description,
    required String packetId,
    required int hopCount,
    required bool isIncoming,
  }) {
    _relayLogs.insert(
      0,
      MeshRelayEvent(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        title: title,
        description: description,
        packetId: packetId,
        hopCount: hopCount,
        isIncoming: isIncoming,
      ),
    );
    if (_relayLogs.length > 50) {
      _relayLogs.removeLast();
    }
    notifyListeners();
  }
}
