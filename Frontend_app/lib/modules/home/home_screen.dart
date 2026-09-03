import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/landslide_report.dart';
import '../../core/models/road_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_theme.dart';
import '../b1_landslide/landslide_reporter_screen.dart';
import '../b6_road_mesh/road_reporter_screen.dart';
import '../map/disaster_map_screen.dart';
import '../mesh_hud/mesh_hud_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const DisasterMapScreen(),
    const MeshHudScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withAlpha(50),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primary),
            label: 'Field Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primary),
            label: 'Disaster Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub, color: AppTheme.meshActive),
            label: 'Mesh HUD',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_alert),
              label: const Text('New Field Report', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _showReportTypeDialog(context),
            )
          : null,
    );
  }

  void _showReportTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELECT REPORT MODULE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.severityHigh.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.landslide, color: AppTheme.severityHigh),
                ),
                title: const Text('B1: Landslide Hazard Reporter', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Slope tension cracks, mud seepage, AI severity analysis', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LandslideReporterScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_road, color: AppTheme.accentTeal),
                ),
                title: const Text('B6: Road Status Mesh Network', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('NH/SH blockages, rockfall, passability for vehicles', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoadReporterScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();
    final meshEngine = context.watch<MeshEngine>();
    final syncManager = context.watch<SyncManager>();

    final landslides = localStore.landslideReports;
    final roads = localStore.roadReports;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HillGuard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  'Unified Disaster & Road Mesh',
                  style: TextStyle(fontSize: 10, color: AppTheme.primary.withAlpha(200)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sync Queue Now',
            icon: syncManager.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Icon(Icons.sync, color: AppTheme.primary),
            onPressed: () => syncManager.syncNow(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Mesh Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: syncManager.isOnline ? AppTheme.surfaceElevated : AppTheme.severityHigh.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: syncManager.isOnline ? AppTheme.borderSubtle : AppTheme.severityHigh,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  syncManager.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syncManager.isOnline ? 'CLOUD SYNC ONLINE' : 'OFFLINE (STORE & MESH FORWARD ACTIVE)',
                        style: TextStyle(
                          color: syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meshEngine.activePeers.length} BLE peers connected • ${localStore.pendingSyncCount} reports in sync queue',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Two Quick Action Hero Cards (B1 + B6)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LandslideReporterScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.severityHigh.withAlpha(40), AppTheme.surfaceElevated],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.severityHigh.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.landslide, color: AppTheme.severityHigh, size: 28),
                        const SizedBox(height: 12),
                        const Text(
                          'B1 Landslide',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Crack / slope vision scan & safety triage',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoadReporterScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentTeal.withAlpha(40), AppTheme.surfaceElevated],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentTeal.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.add_road, color: AppTheme.accentTeal, size: 28),
                        const SizedBox(height: 12),
                        const Text(
                          'B6 Road Mesh',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Report blockage & relay over phone mesh',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Unified Field Reports Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNIFIED FIELD INTELLIGENCE FEED',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                '${landslides.length + roads.length} Reports',
                style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Render Landslides
          ...landslides.map((report) => _buildLandslideCard(report)),

          // Render Roads
          ...roads.map((road) => _buildRoadCard(road)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLandslideCard(LandslideReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.severity.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.severity.displayName,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Text('B1 HAZARD', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                _buildSyncBadge(report.syncStatus, report.relayHops),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.locationDescription,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              report.plainLanguageExplanation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${report.estimatedSlopeAngle.toStringAsFixed(0)}° Slope • ${report.detectedFeatures.length} Features',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(report.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadCard(RoadReport road) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: road.status.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    road.status.label,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  road.roadIdentifier,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                _buildSyncBadge(road.syncStatus, road.relayHops),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              road.sectionName,
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              road.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  road.obstacleType.label,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(road.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncBadge(SyncStatus status, int hops) {
    if (status == SyncStatus.syncedToCloud) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_done, color: AppTheme.severityLow, size: 14),
          SizedBox(width: 4),
          Text('Cloud Synced', style: TextStyle(color: AppTheme.severityLow, fontSize: 10)),
        ],
      );
    } else if (status == SyncStatus.relayedViaMesh) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.meshActive.withAlpha(40),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.meshActive),
        ),
        child: Text(
          'RELAYED ($hops HOPS)',
          style: const TextStyle(color: AppTheme.meshActive, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.severityMedium.withAlpha(40),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'PENDING SYNC',
          style: TextStyle(color: AppTheme.severityMedium, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}
