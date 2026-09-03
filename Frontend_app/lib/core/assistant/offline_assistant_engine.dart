import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/safe_haven.dart';
import 'emergency_knowledge_base.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final EmergencyProtocol? protocolCard;
  final SafeHaven? safeHavenCard;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.protocolCard,
    this.safeHavenCard,
  });
}

class OfflineAssistantEngine extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  OfflineAssistantEngine() {
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    _messages.add(
      ChatMessage(
        text: '🛡️ **HillGuard Emergency AI Companion (Active Offline)**\n\n'
            'I provide instant, step-by-step guidance when you are cut off from network signals. You can ask me about:\n'
            '• **Cloudbursts & Flash Flood Survival**\n'
            '• **Escaping Active Landslides**\n'
            '• **Hypothermia & Cold Exposure Shock**\n'
            '• **Remote Mountain First-Aid (Tourniquet, Fractures)**\n'
            '• **Stranded in Vehicle on Blocked Road**\n'
            '• **Nearest Open Hospital or PHC**\n\n'
            '*What emergency are you facing right now?*',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendUserQuery(String query, {required LatLng userPos}) async {
    if (query.trim().isEmpty) return;

    final trimmed = query.trim();
    _messages.add(ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()));
    notifyListeners();

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final reply = _generateOnDeviceResponse(trimmed, userPos);
    _messages.add(reply);

    _isProcessing = false;
    notifyListeners();
  }

  ChatMessage _generateOnDeviceResponse(String query, LatLng userPos) {
    final lower = query.toLowerCase();

    // Check 1: Inquiries about Hospital, PHC, Shelter, Safe Zone
    if (lower.contains('hospital') ||
        lower.contains('phc') ||
        lower.contains('doctor') ||
        lower.contains('shelter') ||
        lower.contains('safe place') ||
        lower.contains('nearest') ||
        lower.contains('where to go')) {
      final nearest = SafeHaven.findNearest(userPos);
      final distKm = nearest.distanceKmFrom(userPos);
      final bearing = nearest.compassBearingFrom(userPos);

      return ChatMessage(
        text: '🏥 **NEAREST SAFE HAVEN LOCATED (0% Internet Needed)**\n\n'
            'The closest medical and relief staging facility is:\n'
            '**${nearest.name}** (${nearest.type.displayName})\n\n'
            '📍 **Distance:** ${distKm.toStringAsFixed(1)} km away\n'
            '🧭 **Direction:** Bearing $bearing\n'
            '⛰️ **Altitude:** ${nearest.altitudeMeters.toStringAsFixed(0)} m\n'
            '📻 **Emergency Radio:** ${nearest.emergencyRadioFreq}\n\n'
            '**Access Route Notes:** ${nearest.roadAccessNotes}\n\n'
            '**Key Capabilities:**\n'
            '${nearest.medicalCapabilities.map((c) => '• $c').join('\n')}',
        isUser: false,
        timestamp: DateTime.now(),
        safeHavenCard: nearest,
      );
    }

    // Check 2: Match against Curated Medical & Geotechnical Protocols
    final protocol = EmergencyKnowledgeBase.findBestMatch(query);

    if (protocol != null) {
      final buffer = StringBuffer();
      buffer.writeln('🚨 **${protocol.title.toUpperCase()}**');
      buffer.writeln('*${protocol.category}* • **On-Device Protocol**\n');
      buffer.writeln('**IMMEDIATE LIFE-SAFETY ACTIONS (DO THIS NOW):**');
      for (int i = 0; i < protocol.immediateActionSteps.length; i++) {
        buffer.writeln('${i + 1}. ${protocol.immediateActionSteps[i]}');
      }

      if (protocol.criticalWarnings.isNotEmpty) {
        buffer.writeln('\n⚠️ **CRITICAL HAZARD WARNINGS:**');
        for (final w in protocol.criticalWarnings) {
          buffer.writeln('• $w');
        }
      }

      if (protocol.whatNotToDo.isNotEmpty) {
        buffer.writeln('\n❌ **WHAT NOT TO DO (AVOID FATAL MISTAKES):**');
        for (final n in protocol.whatNotToDo) {
          buffer.writeln('• $n');
        }
      }

      buffer.writeln('\n🔬 **Medical / Engineering Rationale:** ${protocol.medicalRationale}');

      return ChatMessage(
        text: buffer.toString(),
        isUser: false,
        timestamp: DateTime.now(),
        protocolCard: protocol,
      );
    }

    // Default Fallback
    return ChatMessage(
      text: '🛡️ **Emergency Assistance Guidance**\n\n'
          'I am operating fully offline without internet. Please check:\n'
          '1. **Find High Ground:** Move away from valley streams and loose slopes.\n'
          '2. **Seek Shelter:** Look at the **Nearest Safe Haven** card above for the closest PHC or relief hall.\n'
          '3. **Broadcast SOS:** Tap the red **Emergency SOS Beacon** to alert nearby mesh phones.\n\n'
          'You can ask: *"How to stop arterial bleeding"*, *"What to do in cloudburst"*, or *"How to treat hypothermia"*.',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  void clearChat() {
    _messages.clear();
    _addInitialGreeting();
    notifyListeners();
  }
}
