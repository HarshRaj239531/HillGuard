import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/assistant/offline_assistant_engine.dart';
import 'core/location/location_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/local_store.dart';
import 'core/mesh/mesh_engine.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'modules/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  final localStore = LocalStore();
  await localStore.init();

  final meshEngine = MeshEngine(localStore: localStore);
  final syncManager = SyncManager(localStore: localStore);
  final locationService = LocationService();
  final assistantEngine = OfflineAssistantEngine();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalStore>.value(value: localStore),
        ChangeNotifierProvider<MeshEngine>.value(value: meshEngine),
        ChangeNotifierProvider<SyncManager>.value(value: syncManager),
        ChangeNotifierProvider<LocationService>.value(value: locationService),
        ChangeNotifierProvider<OfflineAssistantEngine>.value(value: assistantEngine),
      ],
      child: const HillGuardApp(),
    ),
  );
}

class HillGuardApp extends StatelessWidget {
  const HillGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HillGuard - Disaster & Road Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
