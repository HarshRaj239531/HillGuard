import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/assistant/offline_assistant_engine.dart';
import '../../core/location/location_service.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/models/safe_haven.dart';
import '../../core/theme/app_theme.dart';

class HillsAssistantScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMap;

  const HillsAssistantScreen({super.key, this.onNavigateToMap});

  @override
  State<HillsAssistantScreen> createState() => _HillsAssistantScreenState();
}

class _HillsAssistantScreenState extends State<HillsAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitQuery(OfflineAssistantEngine engine, LocationService locationService) {
    final text = _queryController.text.trim();
    if (text.isEmpty) return;

    _queryController.clear();
    engine.sendUserQuery(text, userPos: locationService.currentLatLng);
    _scrollToBottom();
  }

  void _triggerSosBroadcast(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppTheme.severityCritical, size: 26),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Broadcast SOS Beacon?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'This will transmit an urgent Life-Safety Distress SOS packet across the peer-to-peer mesh radio to all nearby offline phones with your exact GPS coordinates and altitude.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.severityCritical,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final location = context.read<LocationService>();
              final mesh = context.read<MeshEngine>();

              await mesh.broadcastOfficialEmergencyAlert(
                authorityTitle: 'CITIZEN SOS DISTRESS',
                warningText: 'EMERGENCY: Citizen cut-off and requesting immediate evacuation at GPS (${location.currentLatLng.latitude.toStringAsFixed(4)}, ${location.currentLatLng.longitude.toStringAsFixed(4)}), Elev: ${location.currentAlt.toStringAsFixed(0)}m',
                targetZone: 'Immediate Mesh Vicinity',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.severityCritical,
                    content: Text('🚨 SOS Distress Packet Broadcasted across Mesh Radio!'),
                  ),
                );
              }
            },
            child: const Text('BROADCAST SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assistantEngine = context.watch<OfflineAssistantEngine>();
    final locationService = context.watch<LocationService>();
    final userPos = locationService.currentLatLng;

    final nearestHaven = SafeHaven.findNearest(userPos);
    final distKm = nearestHaven.distanceKmFrom(userPos);
    final bearing = nearestHaven.compassBearingFrom(userPos);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hills Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textPrimary),
                ),
                Text(
                  'Offline Emergency & Triage AI',
                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF059669).withAlpha(80)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Color(0xFF059669), size: 14),
                SizedBox(width: 4),
                Text(
                  '0% NET AI',
                  style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. NEAREST SAFE HAVEN & SOS HEADER CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: nearestHaven.type.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: nearestHaven.type.color.withAlpha(80)),
                      ),
                      child: Icon(nearestHaven.type.icon, color: nearestHaven.type.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NEAREST SAFE ACTION',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${distKm.toStringAsFixed(1)} km away',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF059669)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nearestHaven.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🧭 Bearing $bearing • Elev: ${nearestHaven.altitudeMeters.toStringAsFixed(0)}m',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 Safe Action: ${nearestHaven.roadAccessNotes}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                // 1-Tap SOS Beacon Button
                ElevatedButton.icon(
                  onPressed: () => _triggerSosBroadcast(context),
                  icon: const Icon(Icons.emergency_share, size: 18),
                  label: const Text('BROADCAST LIFE-SAFETY SOS OVER MESH'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),

          // 2. QUICK EMERGENCY TRIAGE CHIPS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFF1F5F9),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildTriageChip(
                    '⛈️ Cloudburst Survival',
                    'What to do in a sudden cloudburst flash flood?',
                    assistantEngine,
                    locationService,
                  ),
                  _buildTriageChip(
                    '🧗 Landslide Escape',
                    'How to escape an active landslide debris flow?',
                    assistantEngine,
                    locationService,
                  ),
                  _buildTriageChip(
                    '❄️ Hypothermia Shock',
                    'How to treat wet shivering victim and hypothermia?',
                    assistantEngine,
                    locationService,
                  ),
                  _buildTriageChip(
                    '🏥 Tourniquet & Bleeding',
                    'How to control heavy bleeding cut off from hospital?',
                    assistantEngine,
                    locationService,
                  ),
                  _buildTriageChip(
                    '🛣️ Stranded in Car',
                    'Survival protocol when trapped in car on blocked road?',
                    assistantEngine,
                    locationService,
                  ),
                  _buildTriageChip(
                    '💧 Purify Silt Water',
                    'How to purify muddy water to drink?',
                    assistantEngine,
                    locationService,
                  ),
                ],
              ),
            ),
          ),

          // 3. CONVERSATIONAL ASSISTANT FEED
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: assistantEngine.messages.length,
              itemBuilder: (context, index) {
                final msg = assistantEngine.messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          if (assistantEngine.isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(minHeight: 2, color: AppTheme.primary),
            ),

          // 4. OFFLINE INPUT QUERY BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _queryController,
                        decoration: const InputDecoration(
                          hintText: 'Ask any hill emergency or symptom...',
                          hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _submitQuery(assistantEngine, locationService),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      onPressed: () => _submitQuery(assistantEngine, locationService),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriageChip(
    String label,
    String query,
    OfflineAssistantEngine engine,
    LocationService locationService,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          engine.sendUserQuery(query, userPos: locationService.currentLatLng);
          _scrollToBottom();
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: Border.all(
            color: msg.isUser ? AppTheme.primary : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
