import 'dart:convert';
import 'hazard_types.dart';

class RoadReport {
  final String id;
  final String roadIdentifier; // e.g., 'NH-55', 'Hill Cart Road'
  final String sectionName; // e.g., 'Mile 12 (Tindharia Cut)'
  final RoadConditionStatus status;
  final RoadObstacleType obstacleType;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? estimatedClearanceTime;
  final bool passableByTwoWheeler;
  final bool passableBy4x4;
  final String description;
  final String? localPhotoPath;
  final String reporterId;
  SyncStatus syncStatus;
  int relayHops;
  String? lastRelayPeer;

  RoadReport({
    required this.id,
    required this.roadIdentifier,
    required this.sectionName,
    required this.status,
    required this.obstacleType,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.estimatedClearanceTime,
    this.passableByTwoWheeler = false,
    this.passableBy4x4 = false,
    required this.description,
    this.localPhotoPath,
    required this.reporterId,
    this.syncStatus = SyncStatus.pendingSync,
    this.relayHops = 0,
    this.lastRelayPeer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roadIdentifier': roadIdentifier,
      'sectionName': sectionName,
      'status': status.name,
      'obstacleType': obstacleType.name,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'estimatedClearanceTime': estimatedClearanceTime,
      'passableByTwoWheeler': passableByTwoWheeler,
      'passableBy4x4': passableBy4x4,
      'description': description,
      'localPhotoPath': localPhotoPath,
      'reporterId': reporterId,
      'syncStatus': syncStatus.name,
      'relayHops': relayHops,
      'lastRelayPeer': lastRelayPeer,
    };
  }

  factory RoadReport.fromMap(Map<String, dynamic> map) {
    return RoadReport(
      id: map['id'] as String,
      roadIdentifier: map['roadIdentifier'] as String? ?? 'Regional Road',
      sectionName: map['sectionName'] as String? ?? 'Slope Corridor',
      status: RoadConditionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoadConditionStatus.caution,
      ),
      obstacleType: RoadObstacleType.values.firstWhere(
        (o) => o.name == map['obstacleType'],
        orElse: () => RoadObstacleType.landslideDebris,
      ),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      estimatedClearanceTime: map['estimatedClearanceTime'] as String?,
      passableByTwoWheeler: map['passableByTwoWheeler'] as bool? ?? false,
      passableBy4x4: map['passableBy4x4'] as bool? ?? false,
      description: map['description'] as String? ?? '',
      localPhotoPath: map['localPhotoPath'] as String?,
      reporterId: map['reporterId'] as String? ?? 'volunteer',
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == map['syncStatus'],
        orElse: () => SyncStatus.pendingSync,
      ),
      relayHops: map['relayHops'] as int? ?? 0,
      lastRelayPeer: map['lastRelayPeer'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory RoadReport.fromJson(String source) =>
      RoadReport.fromMap(json.decode(source) as Map<String, dynamic>);
}
