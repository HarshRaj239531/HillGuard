import 'dart:convert';
import 'hazard_types.dart';

class LandslideReport {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? altitude;
  final String locationDescription;
  final HazardSeverity severity;
  final List<LandslideFeature> detectedFeatures;
  final double estimatedSlopeAngle;
  final String plainLanguageExplanation;
  final List<String> recommendedSafetyActions;
  final String? localPhotoPath;
  final String reporterId;
  SyncStatus syncStatus;
  int relayHops;
  String? lastRelayPeer;

  LandslideReport({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.locationDescription,
    required this.severity,
    required this.detectedFeatures,
    required this.estimatedSlopeAngle,
    required this.plainLanguageExplanation,
    required this.recommendedSafetyActions,
    this.localPhotoPath,
    required this.reporterId,
    this.syncStatus = SyncStatus.pendingSync,
    this.relayHops = 0,
    this.lastRelayPeer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'locationDescription': locationDescription,
      'severity': severity.name,
      'detectedFeatures': detectedFeatures.map((f) => f.name).toList(),
      'estimatedSlopeAngle': estimatedSlopeAngle,
      'plainLanguageExplanation': plainLanguageExplanation,
      'recommendedSafetyActions': recommendedSafetyActions,
      'localPhotoPath': localPhotoPath,
      'reporterId': reporterId,
      'syncStatus': syncStatus.name,
      'relayHops': relayHops,
      'lastRelayPeer': lastRelayPeer,
    };
  }

  factory LandslideReport.fromMap(Map<String, dynamic> map) {
    return LandslideReport(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: map['altitude'] != null ? (map['altitude'] as num).toDouble() : null,
      locationDescription: map['locationDescription'] as String? ?? 'Hillside Sector',
      severity: HazardSeverity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => HazardSeverity.medium,
      ),
      detectedFeatures: ((map['detectedFeatures'] as List<dynamic>?) ?? [])
          .map((item) => LandslideFeature.values.firstWhere(
                (f) => f.name == item,
                orElse: () => LandslideFeature.tensionCrack,
              ))
          .toList(),
      estimatedSlopeAngle: (map['estimatedSlopeAngle'] as num?)?.toDouble() ?? 35.0,
      plainLanguageExplanation: map['plainLanguageExplanation'] as String? ?? '',
      recommendedSafetyActions: List<String>.from(map['recommendedSafetyActions'] ?? []),
      localPhotoPath: map['localPhotoPath'] as String?,
      reporterId: map['reporterId'] as String? ?? 'anonymous-volunteer',
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == map['syncStatus'],
        orElse: () => SyncStatus.pendingSync,
      ),
      relayHops: map['relayHops'] as int? ?? 0,
      lastRelayPeer: map['lastRelayPeer'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory LandslideReport.fromJson(String source) =>
      LandslideReport.fromMap(json.decode(source) as Map<String, dynamic>);
}
