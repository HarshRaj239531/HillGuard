import 'dart:convert';

enum MeshPacketType {
  landslideReport,
  roadReport,
  emergencyAlert,
  peerHeartbeat,
}

class MeshPacket {
  final String packetId;
  final MeshPacketType type;
  final String payload; // JSON serialized report or alert
  final String originalSenderId;
  final DateTime createdAt;
  final int maxTtl;
  int currentHop;
  List<String> relayPath; // Peer IDs traversed
  final int priority; // 1: Low, 2: High, 3: Critical

  MeshPacket({
    required this.packetId,
    required this.type,
    required this.payload,
    required this.originalSenderId,
    required this.createdAt,
    this.maxTtl = 5,
    this.currentHop = 0,
    List<String>? relayPath,
    this.priority = 2,
  }) : relayPath = relayPath ?? [originalSenderId];

  bool get isExpired => currentHop >= maxTtl;

  void addHop(String relayPeerId) {
    currentHop++;
    if (!relayPath.contains(relayPeerId)) {
      relayPath.add(relayPeerId);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'packetId': packetId,
      'type': type.name,
      'payload': payload,
      'originalSenderId': originalSenderId,
      'createdAt': createdAt.toIso8601String(),
      'maxTtl': maxTtl,
      'currentHop': currentHop,
      'relayPath': relayPath,
      'priority': priority,
    };
  }

  factory MeshPacket.fromMap(Map<String, dynamic> map) {
    return MeshPacket(
      packetId: map['packetId'] as String,
      type: MeshPacketType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => MeshPacketType.landslideReport,
      ),
      payload: map['payload'] as String,
      originalSenderId: map['originalSenderId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      maxTtl: map['maxTtl'] as int? ?? 5,
      currentHop: map['currentHop'] as int? ?? 0,
      relayPath: List<String>.from(map['relayPath'] ?? []),
      priority: map['priority'] as int? ?? 2,
    );
  }

  String toJson() => json.encode(toMap());
  factory MeshPacket.fromJson(String source) =>
      MeshPacket.fromMap(json.decode(source) as Map<String, dynamic>);
}
