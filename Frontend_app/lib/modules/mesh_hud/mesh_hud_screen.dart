import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/storage/local_store.dart';
import '../../core/mesh/mesh_engine.dart';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mesh Network HUD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Switch(
            value: meshEngine.isMeshBroadcasting,
            activeThumbColor: AppTheme.meshActive,
            activeTrackColor: AppTheme.meshActive.withAlpha(40),
            onChanged: (val) => meshEngine.toggleMeshBroadcasting(),
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
              gradient: const LinearGradient(
                colors: [Color(0xFFF5F3FF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.meshActive.withAlpha(90), width: 1.2),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
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
                                ? 'UDP Beacon & TCP Sockets Active • Store & Forward ON'
                                : 'Mesh Radio Muted',
                            style: TextStyle(
                              color: meshEngine.isMeshBroadcasting ? AppTheme.meshActive : AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('P2P PEERS', '${meshEngine.physicalPeerCount}', AppTheme.severityLow),
                    _buildStatCol('SIM PEERS', '${meshEngine.activePeers.length - meshEngine.physicalPeerCount}', AppTheme.primary),
                    _buildStatCol('QUEUE', '${localStore.meshQueue.length}', AppTheme.meshActive),
                    _buildStatCol(
                      'NET',
                      syncManager.isOnline ? 'ONLINE' : 'OFFLINE',
                      syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Real Device Offline Hotspot Instructions Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDFA), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(90), width: 1.2),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.wifi_tethering, color: AppTheme.accentTeal, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ZERO-INTERNET PHONE PAIRING',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Turn ON Portable Hotspot on Phone A (no SIM/cellular data required).\n'
                  '2. Connect Phone B to Phone A\'s Wi-Fi network.\n'
                  '3. Both phones auto-discover over UDP 44555 and transfer B1 & B6 reports in real-time over TCP 44556 sockets!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hackathon Action Demo Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.severityMedium.withAlpha(90), width: 1.2),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
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
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulate peer packets on demand or toggle connectivity states:',
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
                        icon: const Icon(Icons.downloading, size: 18),
                        label: const Text('Simulate Inflow', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          await meshEngine.simulatePeerRelayInjection();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mesh packet injected & relayed through local store!'),
                                duration: Duration(seconds: 2),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(syncManager.isOnline ? Icons.wifi_off : Icons.wifi, size: 18),
                        label: Text(
                          syncManager.isOnline ? 'Cut Internet' : 'Restore Net',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 20),

          // Active Peer List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISCOVERED PEER NODES (${meshEngine.activePeers.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 1.1,
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${meshEngine.physicalPeerCount} Physical Wi-Fi',
                style: const TextStyle(color: AppTheme.severityLow, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...meshEngine.activePeers.map((peer) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: peer.isPhysical ? AppTheme.severityLow.withAlpha(120) : AppTheme.borderSubtle,
                    width: peer.isPhysical ? 1.5 : 1,
                  ),
                ),
                color: peer.isPhysical ? const Color(0xFFF0FDF4) : AppTheme.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: peer.isPhysical ? AppTheme.severityLow.withAlpha(25) : AppTheme.surfaceElevated,
                    child: Icon(
                      peer.isPhysical ? Icons.wifi_tethering : Icons.bluetooth_audio,
                      color: peer.isPhysical ? AppTheme.severityLow : AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          peer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (peer.isPhysical)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.severityLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PHYSICAL',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text('${peer.role} • ID: ${peer.peerId}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Text(
                      '${peer.signalStrengthDbm} dBm',
                      style: TextStyle(
                        color: peer.isPhysical ? AppTheme.severityLow : AppTheme.primary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // Real-Time Multi-Hop Packet Relay Log
          Text(
            'MULTI-HOP PROPAGATION LOG (${meshEngine.relayLogs.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          if (meshEngine.relayLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: const Text('No mesh relay events yet. Tap "Simulate Inflow" above.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            )
          else
            ...meshEngine.relayLogs.map((log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: log.isIncoming ? AppTheme.meshRelay.withAlpha(80) : AppTheme.meshActive.withAlpha(80),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (log.isIncoming ? AppTheme.meshRelay : AppTheme.meshActive).withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          log.isIncoming ? Icons.call_received : Icons.call_made,
                          color: log.isIncoming ? AppTheme.meshRelay : AppTheme.meshActive,
                          size: 16,
                        ),
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
                            const SizedBox(height: 3),
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
          const SizedBox(height: 80),
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
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
