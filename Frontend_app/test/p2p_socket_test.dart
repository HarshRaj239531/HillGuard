import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hillguard/core/models/hazard_types.dart';
import 'package:hillguard/core/models/landslide_report.dart';
import 'package:hillguard/core/models/mesh_packet.dart';

void main() {
  test('P2P Socket End-to-End Relay Test over loopback TCP', () async {
    final completer = Completer<MeshPacket>();
    const testPort = 44577;

    // Node B: Start receiver TCP Server
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, testPort);
    server.listen((clientSocket) {
      final buffer = StringBuffer();
      clientSocket.listen(
        (data) => buffer.write(utf8.decode(data)),
        onDone: () {
          final payload = buffer.toString();
          clientSocket.destroy();
          final map = json.decode(payload) as Map<String, dynamic>;
          completer.complete(MeshPacket.fromMap(map));
        },
      );
    });

    // Node A: Create Landslide Report & Mesh Packet
    final report = LandslideReport(
      id: 'ls-p2p-test-01',
      timestamp: DateTime.now(),
      latitude: 26.9048,
      longitude: 88.3375,
      locationDescription: 'P2P Test Ridge Cut',
      severity: HazardSeverity.high,
      detectedFeatures: [LandslideFeature.tensionCrack],
      estimatedSlopeAngle: 45.0,
      plainLanguageExplanation: 'P2P socket test explanation',
      recommendedSafetyActions: ['Evacuate perimeter'],
      reporterId: 'unit-node-a',
    );

    final packet = MeshPacket(
      packetId: 'pkt-p2p-test-888',
      type: MeshPacketType.landslideReport,
      payload: report.toJson(),
      originalSenderId: 'unit-node-a',
      createdAt: DateTime.now(),
    );

    // Node A: Send packet to Node B's IP and port over TCP
    final client = await Socket.connect(InternetAddress.loopbackIPv4, testPort);
    client.write(packet.toJson());
    await client.flush();
    await client.close();

    // Verify Node B received the exact packet within 3 seconds
    final receivedPacket = await completer.future.timeout(const Duration(seconds: 3));
    expect(receivedPacket.packetId, equals('pkt-p2p-test-888'));
    expect(receivedPacket.originalSenderId, equals('unit-node-a'));

    final receivedReport = LandslideReport.fromJson(receivedPacket.payload);
    expect(receivedReport.id, equals('ls-p2p-test-01'));
    expect(receivedReport.locationDescription, equals('P2P Test Ridge Cut'));
    expect(receivedReport.severity, equals(HazardSeverity.high));

    await server.close();
  });
}
