import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/localization_service.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/landslide_report.dart';
import '../../core/models/road_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_theme.dart';
import '../assistant/hills_assistant_screen.dart';
import '../b1_landslide/landslide_reporter_screen.dart';
import '../b6_road_mesh/road_reporter_screen.dart';
import '../b6_road_mesh/route_status_board.dart';
import '../map/disaster_map_screen.dart';
import '../mesh_hud/mesh_hud_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription<String>? _alertSub;

  late final List<Widget> _pages = [
    _DashboardTab(onNavigateToTab: (index) => setState(() => _currentIndex = index)),
    const DisasterMapScreen(),
    const HillsAssistantScreen(),
    const MeshHudScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meshEngine = context.read<MeshEngine>();
      _alertSub = meshEngine.incomingAlertStream.listen((alertText) {
        if (!mounted) return;
        try {
          HapticFeedback.vibrate();
          HapticFeedback.heavyImpact();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.severityCritical,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alertText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }

  static final LocalizationService _fallbackLoc = LocalizationService();

  static LocalizationService _safeLoc(BuildContext context) {
    try {
      return Provider.of<LocalizationService>(context);
    } catch (_) {
      return _fallbackLoc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = _safeLoc(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withAlpha(25),
          elevation: 0,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined, color: AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primary),
              label: loc.t('tab_feed'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined, color: AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.map, color: AppTheme.primary),
              label: loc.t('tab_map'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.health_and_safety_outlined, color: AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.health_and_safety, color: Color(0xFFDC2626)),
              label: loc.t('tab_assistant'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.hub_outlined, color: AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.hub, color: AppTheme.meshActive),
              label: loc.t('tab_hud'),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              icon: const Icon(Icons.add_alert, size: 20),
              label: Text(loc.t('new_report_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () => _showReportTypeDialog(context),
            )
          : null,
    );
  }

  void _showReportTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'SELECT REPORT MODULE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                tileColor: AppTheme.surfaceElevated,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.severityHigh.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.landslide, color: AppTheme.severityHigh),
                ),
                title: const Text('B1: Landslide Hazard Reporter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Tension cracks, slope angles, AI geotechnical triage', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
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
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                tileColor: AppTheme.surfaceElevated,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_road, color: AppTheme.accentTeal),
                ),
                title: const Text('B6: Road Status Mesh Network', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('NH/SH blockages, rockfall, vehicle passage status', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
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
  final Function(int)? onNavigateToTab;
  const _DashboardTab({this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();
    final meshEngine = context.watch<MeshEngine>();
    final syncManager = context.watch<SyncManager>();
    final loc = _HomeScreenState._safeLoc(context);

    final landslides = localStore.landslideReports;
    final roads = localStore.roadReports;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.t('app_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
                Text(
                  loc.t('app_subtitle'),
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher (15% Belonging: EN | नेपाली | हिन्दी | বাংলা)
          PopupMenuButton<AppLanguage>(
            tooltip: 'Language / भाषा',
            initialValue: loc.currentLanguage,
            onSelected: (lang) => loc.setLanguage(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 15, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    loc.currentLanguage.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
            itemBuilder: (ctx) => AppLanguage.values.map((lang) {
              return PopupMenuItem(
                value: lang,
                child: Row(
                  children: [
                    Text(lang.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('(${lang.fullName})', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    if (lang == loc.currentLanguage) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16, color: AppTheme.primary),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 4),
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.install_mobile_rounded, size: 13),
                label: Text(loc.t('get_app'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                onPressed: () => _showInstallModal(context),
              ),
            ),
          IconButton(
            tooltip: 'Sync Queue Now',
            icon: syncManager.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Icon(Icons.sync, color: AppTheme.primary, size: 18),
                  ),
            onPressed: () => syncManager.syncNow(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0284C7).withAlpha(30),
                      const Color(0xFF38BDF8).withAlpha(15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0284C7).withAlpha(100), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.install_mobile_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Install HillGuard (Offline PWA & APK)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                          ),
                          Text(
                            'Add to Home Screen or download native APK for zero-signal operation',
                            style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => _showInstallModal(context),
                      child: const Text('Install / APK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          // Emergency Mesh Status Card (Clean Light Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: syncManager.isOnline ? AppTheme.severityLow.withAlpha(120) : AppTheme.severityHigh.withAlpha(120),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh).withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    syncManager.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syncManager.isOnline ? 'BASE STATION CONNECTED' : 'OFFLINE MODE (STORE & FORWARD)',
                        style: TextStyle(
                          color: syncManager.isOnline ? AppTheme.severityLow : AppTheme.severityHigh,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${meshEngine.activePeers.length} mesh peers (${meshEngine.physicalPeerCount} physical) • ${localStore.pendingSyncCount} pending upload',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Works Offline 25%: Stage Mode Proof Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF059669).withAlpha(90), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.airplanemode_active, color: Color(0xFF059669), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('offline_stage_mode'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669), letterSpacing: 0.5),
                      ),
                      Text(
                        loc.t('no_server_calls'),
                        style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('STAGE PROOF', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Usefulness to the Hills 25%: Real Hill Persona Quick Presets
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 15, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    loc.t('personas_title'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPersonaChip(
                      context,
                      icon: Icons.train_outlined,
                      title: loc.t('persona_railway'),
                      subtitle: loc.t('persona_railway_sub'),
                      badge: 'DHR RAILWAY',
                      color: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LandslideReporterScreen()));
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildPersonaChip(
                      context,
                      icon: Icons.directions_car_outlined,
                      title: loc.t('persona_passenger'),
                      subtitle: loc.t('persona_passenger_sub'),
                      badge: 'ROAD COMMUTER',
                      color: const Color(0xFFD97706),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteStatusBoard()));
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildPersonaChip(
                      context,
                      icon: Icons.home_work_outlined,
                      title: loc.t('persona_farmer'),
                      subtitle: loc.t('persona_farmer_sub'),
                      badge: 'LOCAL RESIDENT',
                      color: const Color(0xFF059669),
                      onTap: () {
                        onNavigateToTab?.call(2); // Jump to Hills AI tab
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Hills Assistant 🔴 (AMBITIOUS) Hero Banner Card
          GestureDetector(
            onTap: () => onNavigateToTab?.call(2), // Switch to Hills AI tab
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF2F2), Color(0xFFFFFBEB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDC2626).withAlpha(90), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              loc.t('hills_assistant_title'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('🔴 AMBITIOUS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          loc.t('hills_assistant_desc'),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFDC2626)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Two Quick Action Hero Cards (B1 + B6)
          Row(
            children: [
              // B1 Landslide Card
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1F2), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.severityHigh.withAlpha(80), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.severityHigh.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.landslide, color: AppTheme.severityHigh, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.t('b1_landslide_title'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.t('b1_landslide_sub'),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // B6 Road Mesh Card
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentTeal.withAlpha(80), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_road, color: AppTheme.accentTeal, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.t('b6_road_title'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.t('b6_road_sub'),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary Quick Actions (Route Board + Relay Down Official Warning)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.alt_route, size: 18),
                  label: Text(loc.t('route_board'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RouteStatusBoard()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.severityCritical,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.campaign, size: 18),
                  label: Text(loc.t('relay_alert'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showOfficialAlertBroadcastDialog(context),
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
                loc.t('live_feed_header'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${landslides.length + roads.length} Reports',
                      style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
                    tooltip: 'Manage Feed',
                    onSelected: (value) async {
                      if (value == 'clear_all') {
                        _confirmClearAll(context);
                      } else if (value == 'reset_demo') {
                        await context.read<LocalStore>().resetToDemoData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feed reset to clean initial demo data')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reset_demo',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt, size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Reset Demo Data', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep_outlined, size: 18, color: AppTheme.severityCritical),
                            SizedBox(width: 8),
                            Text('Delete All Reports', style: TextStyle(fontSize: 13, color: AppTheme.severityCritical)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Render Landslides with Swipe to Delete
          ...landslides.map((report) => _buildLandslideCard(context, report)),

          // Render Roads with Swipe to Delete
          ...roads.map((road) => _buildRoadCard(context, road)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Reports?'),
        content: const Text('This will delete all test landslide and road reports from your local device database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.severityCritical, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<LocalStore>().clearAllReports();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All local reports cleared')),
                );
              }
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildLandslideCard(BuildContext context, LandslideReport report) {
    return Dismissible(
      key: ValueKey(report.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 6),
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<LocalStore>().deleteLandslideReport(report.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('Deleted landslide report: ${report.locationDescription}'),
          ),
        );
      },
      child: Card(
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
                      color: report.severity.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: report.severity.color.withAlpha(80)),
                    ),
                    child: Text(
                      report.severity.displayName,
                      style: TextStyle(color: report.severity.color, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('B1 LANDSLIDE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  _buildSyncBadge(report.syncStatus, report.relayHops),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      context.read<LocalStore>().deleteLandslideReport(report.id);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report.locationDescription,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                report.plainLanguageExplanation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.borderSubtle),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${report.estimatedSlopeAngle.toStringAsFixed(0)}° Slope • ${report.detectedFeatures.length} Indicators',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget _buildRoadCard(BuildContext context, RoadReport road) {
    return Dismissible(
      key: ValueKey(road.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 6),
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<LocalStore>().deleteRoadReport(road.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('Deleted road report: ${road.roadIdentifier}'),
          ),
        );
      },
      child: Card(
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
                      color: road.status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: road.status.color.withAlpha(80)),
                    ),
                    child: Text(
                      road.status.label,
                      style: TextStyle(color: road.status.color, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    road.roadIdentifier,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  _buildSyncBadge(road.syncStatus, road.relayHops),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      context.read<LocalStore>().deleteRoadReport(road.id);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                    ),
                  ),
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
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.borderSubtle),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    road.obstacleType.label,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget _buildSyncBadge(SyncStatus status, int hops) {
    if (status == SyncStatus.syncedToCloud) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: AppTheme.severityLow, size: 14),
          SizedBox(width: 4),
          Text('Cloud Synced', style: TextStyle(color: AppTheme.severityLow, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (status == SyncStatus.relayedViaMesh) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.meshActive.withAlpha(25),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.meshActive.withAlpha(80)),
        ),
        child: Text(
          'RELAYED ($hops HOPS)',
          style: const TextStyle(color: AppTheme.meshActive, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.severityMedium.withAlpha(25),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.severityMedium.withAlpha(80)),
        ),
        child: const Text(
          'PENDING SYNC',
          style: TextStyle(color: AppTheme.severityMedium, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void _showOfficialAlertBroadcastDialog(BuildContext context) {
    final meshEngine = context.read<MeshEngine>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.campaign, color: AppTheme.severityCritical),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Relay Down: Official Alert',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Simulate receiving an official meteorological warning on a connected device and rebroadcasting it peer-to-peer down to offline phones with no signal:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              '⚠️ IMD HIGH-RISK RED ALERT:\n"Over 300mm torrential rain in 12h. Severe landslide threat across Darjeeling - Kurseong - Tindharia mountain belt. Immediate valley evacuation ordered!"',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.severityCritical, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.severityCritical,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_to_mobile, size: 18),
            label: const Text('REBROADCAST TO MESH'),
            onPressed: () async {
              Navigator.pop(ctx);
              await meshEngine.broadcastOfficialEmergencyAlert(
                authorityTitle: 'IMD / DISTRICT DISASTER AUTHORITY',
                warningText: 'Over 300mm torrential rain in 12h. High landslide hazard. Immediate slope evacuation ordered!',
                targetZone: 'Kurseong - Tindharia Basin',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.severityCritical,
                    content: Text('Official High-Risk Red Alert dispatched to offline mesh peers!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showInstallModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.install_mobile_rounded, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get HillGuard App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Text('Choose how you want to run HillGuard offline', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Option 1: Instant PWA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bolt_rounded, color: AppTheme.severityHigh, size: 20),
                      SizedBox(width: 8),
                      Text('Option 1: Instant PWA Install (No Download)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'No 60MB APK download required! Already cached on your phone or PC.\n'
                    '• On Desktop Chrome: Look at the top-right of your address bar for the "Install" icon (💻 ⬇️).\n'
                    '• On Mobile: Tap the 3 dots (⋮) in Chrome and select "Install app" or "Add to Home screen".',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Option 2: Download Native APK
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withAlpha(90)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.android_rounded, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Option 2: Download Android APK (58.8 MB)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Full native Android package with background Wi-Fi hotspot mesh scanning, hardware vibration, and offline topographic vector map.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download HillGuard-release.apk', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await launchUrl(Uri.parse('HillGuard-release.apk'), mode: LaunchMode.externalApplication);
                        } catch (_) {
                          await launchUrl(
                            Uri.parse('https://github.com/HarshRaj239531/HillGuard/raw/gh-pages/HillGuard-release.apk'),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaChip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80), width: 1.2),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
