import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/storage/local_store.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_theme.dart';

class MeshHudScreen extends StatelessWidget {
  const MeshHudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meshEngine = context.watch<MeshEngine>();
    final localStore = context.watch<LocalStore>();
    final syncManager = context.watch<SyncManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone-to-Phone Mesh HUD'),
        actions: [
          Switch(
            value: meshEngine.isMeshBroadcasting,
            activeThumbColor: AppTheme.meshActive,
            onChanged: (val) => meshEngine.toggleBroadcasting(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mesh Radio State Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.meshActive.withAlpha(50),
                  AppTheme.surfaceElevated,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.meshActive.withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.meshActive,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hub, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOCAL MESH ROUTER: ${meshEngine.deviceId.toUpperCase()}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meshEngine.isMeshBroadcasting
                                ? 'BLE & Wi-Fi Nearby Beacon Active • Store & Forward ON'
                                : 'Mesh Radio Muted',
                            style: TextStyle(
                              color: meshEngine.isMeshBroadcasting ? AppTheme.accentTeal : AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('DIRECT PEERS', '${meshEngine.activePeers.length}', AppTheme.primary),
                    _buildStatCol('RELAY QUEUE', '${localStore.meshQueue.length}', AppTheme.meshActive),
                    _buildStatCol(
                      'INTERNET',
                      syncManager.isOnline ? 'ONLINE' : 'OFFLINE (MESH ONLY)',
                      syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hackathon Action Demo Bar
          Card(
            color: AppTheme.surfaceElevated,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppTheme.severityMedium, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'JUDGE / DEMO INTERACTION CONTROLS',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 11,
                              color: AppTheme.severityMedium,
                              letterSpacing: 1.0,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Simulate zero-connectivity phone-to-phone data jumps or toggle internet restoration:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.meshActive,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cell_tower, size: 18),
                          label: const Text('Simulate Peer Inflow', style: TextStyle(fontSize: 12)),
                          onPressed: () async {
                            await meshEngine.simulatePeerRelayInjection();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppTheme.meshActive,
                                  content: Text('Simulated multi-hop hazard packet ingested from nearby peer!'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: syncManager.isOnline ? AppTheme.severityHigh : AppTheme.severityLow,
                            side: BorderSide(
                              color: syncManager.isOnline ? AppTheme.severityHigh : AppTheme.severityLow,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(syncManager.isOnline ? Icons.wifi_off : Icons.wifi, size: 18),
                          label: Text(
                            syncManager.isOnline ? 'Force Offline' : 'Restore Internet',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            syncManager.setSimulatedConnectivity(!syncManager.isOnline);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Active Neighbors Section
          Text(
            'ACTIVE PEER NODES IN RANGE (${meshEngine.activePeers.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 8),
          ...meshEngine.activePeers.map((peer) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.surfaceElevated,
                    child: Icon(Icons.bluetooth_audio, color: AppTheme.primary, size: 20),
                  ),
                  title: Text(peer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${peer.role} • ID: ${peer.peerId}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Text(
                      '${peer.signalStrengthDbm} dBm',
                      style: const TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              )),

          const SizedBox(height: 16),

          // Real-Time Multi-Hop Packet Relay Log
          Text(
            'MULTI-HOP PROPAGATION LOG (${meshEngine.relayLogs.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 8),
          if (meshEngine.relayLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No mesh relay events yet. Tap "Simulate Peer Inflow" above.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            )
          else
            ...meshEngine.relayLogs.map((log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: log.isIncoming ? AppTheme.meshRelay.withAlpha(120) : AppTheme.meshActive.withAlpha(120),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        log.isIncoming ? Icons.call_received : Icons.call_made,
                        color: log.isIncoming ? AppTheme.meshRelay : AppTheme.meshActive,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  log.title,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm:ss').format(log.timestamp),
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.description,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
