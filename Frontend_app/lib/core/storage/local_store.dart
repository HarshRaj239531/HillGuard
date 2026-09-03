import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hazard_types.dart';
import '../models/landslide_report.dart';
import '../models/road_report.dart';
import '../models/mesh_packet.dart';

class LocalStore extends ChangeNotifier {
  static const String _landslideKey = 'hillguard_landslide_reports_v1';
  static const String _roadKey = 'hillguard_road_reports_v1';
  static const String _meshQueueKey = 'hillguard_mesh_outgoing_v1';
  static const String _seenPacketsKey = 'hillguard_mesh_seen_packets_v1';

  final List<LandslideReport> _landslideReports = [];
  final List<RoadReport> _roadReports = [];
  final List<MeshPacket> _meshQueue = [];
  final Set<String> _seenPacketIds = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<LandslideReport> get landslideReports => List.unmodifiable(_landslideReports);
  List<RoadReport> get roadReports => List.unmodifiable(_roadReports);
  List<MeshPacket> get meshQueue => List.unmodifiable(_meshQueue);
  int get pendingSyncCount =>
      _landslideReports.where((r) => r.syncStatus != SyncStatus.syncedToCloud).length +
      _roadReports.where((r) => r.syncStatus != SyncStatus.syncedToCloud).length;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Landslides
      final landslideJsonList = prefs.getStringList(_landslideKey) ?? [];
      _landslideReports.clear();
      for (final str in landslideJsonList) {
        try {
          _landslideReports.add(LandslideReport.fromJson(str));
        } catch (e) {
          debugPrint('Error decoding landslide report: $e');
        }
      }

      // Load Road Reports
      final roadJsonList = prefs.getStringList(_roadKey) ?? [];
      _roadReports.clear();
      for (final str in roadJsonList) {
        try {
          _roadReports.add(RoadReport.fromJson(str));
        } catch (e) {
          debugPrint('Error decoding road report: $e');
        }
      }

      // Load Seen Packets
      final seenList = prefs.getStringList(_seenPacketsKey) ?? [];
      _seenPacketIds.addAll(seenList);

      // Load Mesh Queue
      final meshJsonList = prefs.getStringList(_meshQueueKey) ?? [];
      _meshQueue.clear();
      for (final str in meshJsonList) {
        try {
          _meshQueue.add(MeshPacket.fromJson(str));
        } catch (e) {
          debugPrint('Error decoding mesh packet: $e');
        }
      }

      // Seed realistic initial demo data if empty
      if (_landslideReports.isEmpty && _roadReports.isEmpty) {
        _seedInitialData();
        await _persistAll();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('LocalStore init error: $e');
    }
  }

  void _seedInitialData() {
    // Initial Landslide Report (e.g., Kurseong - Tindharia sector)
    _landslideReports.add(
      LandslideReport(
        id: 'ls-seed-001',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        latitude: 26.9048,
        longitude: 88.3375,
        altitude: 1450.0,
        locationDescription: 'NH-55 Tindharia Hillside, Near Old Station',
        severity: HazardSeverity.high,
        detectedFeatures: [
          LandslideFeature.tensionCrack,
          LandslideFeature.waterSeepage,
          LandslideFeature.debrisFall,
        ],
        estimatedSlopeAngle: 48.5,
        plainLanguageExplanation:
            'Tension cracks extending over 14 meters with active mud seepage identified on steep cut slope. Imminent slope failure risk if rain persists.',
        recommendedSafetyActions: [
          'Evacuate downslope residences within 100 meters.',
          'Halt heavy vehicular traffic immediately.',
          'Mark tension crack edge with high-visibility flags.',
        ],
        reporterId: 'node-field-alpha',
        syncStatus: SyncStatus.pendingSync,
        relayHops: 1,
        lastRelayPeer: 'volunteer-phone-b',
      ),
    );

    // Initial Road Blockage Report
    _roadReports.add(
      RoadReport(
        id: 'rd-seed-001',
        roadIdentifier: 'NH-55',
        sectionName: 'Pagla Jhora Chasm',
        status: RoadConditionStatus.blocked,
        obstacleType: RoadObstacleType.landslideDebris,
        latitude: 26.9215,
        longitude: 88.3142,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        estimatedClearanceTime: '4 to 6 Hours (PWD JCB deployed)',
        passableByTwoWheeler: false,
        passableBy4x4: false,
        description:
            'Heavy sludge and 3-meter boulders covering both lanes after cloudburst. Alternate route via Rohini recommended.',
        reporterId: 'pwd-patrol-07',
        syncStatus: SyncStatus.syncedToCloud,
        relayHops: 2,
        lastRelayPeer: 'node-relay-gamma',
      ),
    );

    // Road with caution
    _roadReports.add(
      RoadReport(
        id: 'rd-seed-002',
        roadIdentifier: 'SH-12',
        sectionName: 'Mirik Ridge Pass',
        status: RoadConditionStatus.caution,
        obstacleType: RoadObstacleType.rockfall,
        latitude: 26.8872,
        longitude: 88.2389,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        estimatedClearanceTime: 'Single Lane Open',
        passableByTwoWheeler: true,
        passableBy4x4: true,
        description: 'Minor gravel slip on uphill lane. Thick fog reducing visibility below 10m.',
        reporterId: 'driver-relay-19',
        syncStatus: SyncStatus.relayedViaMesh,
        relayHops: 3,
        lastRelayPeer: 'truck-unit-4',
      ),
    );
  }

  // Save Landslide Report
  Future<void> saveLandslideReport(LandslideReport report) async {
    final index = _landslideReports.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      _landslideReports[index] = report;
    } else {
      _landslideReports.insert(0, report);
    }
    await _persistLandslides();
    notifyListeners();
  }

  // Save Road Report
  Future<void> saveRoadReport(RoadReport report) async {
    final index = _roadReports.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      _roadReports[index] = report;
    } else {
      _roadReports.insert(0, report);
    }
    await _persistRoads();
    notifyListeners();
  }

  // Enqueue Mesh Packet for P2P Relay
  Future<void> enqueueMeshPacket(MeshPacket packet) async {
    if (_seenPacketIds.contains(packet.packetId)) return;
    _seenPacketIds.add(packet.packetId);
    _meshQueue.add(packet);
    await _persistMeshQueue();
    await _persistSeenPackets();
    notifyListeners();
  }

  bool hasSeenPacket(String packetId) => _seenPacketIds.contains(packetId);

  void markPacketSeen(String packetId) {
    _seenPacketIds.add(packetId);
    _persistSeenPackets();
  }

  Future<void> markLandslideSynced(String reportId) async {
    final index = _landslideReports.indexWhere((r) => r.id == reportId);
    if (index >= 0) {
      _landslideReports[index].syncStatus = SyncStatus.syncedToCloud;
      await _persistLandslides();
      notifyListeners();
    }
  }

  Future<void> markRoadSynced(String reportId) async {
    final index = _roadReports.indexWhere((r) => r.id == reportId);
    if (index >= 0) {
      _roadReports[index].syncStatus = SyncStatus.syncedToCloud;
      await _persistRoads();
      notifyListeners();
    }
  }

  Future<void> _persistLandslides() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _landslideKey,
      _landslideReports.map((r) => r.toJson()).toList(),
    );
  }

  Future<void> _persistRoads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _roadKey,
      _roadReports.map((r) => r.toJson()).toList(),
    );
  }

  Future<void> _persistMeshQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _meshQueueKey,
      _meshQueue.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> _persistSeenPackets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenPacketsKey, _seenPacketIds.toList());
  }

  Future<void> _persistAll() async {
    await _persistLandslides();
    await _persistRoads();
    await _persistMeshQueue();
    await _persistSeenPackets();
  }
}
