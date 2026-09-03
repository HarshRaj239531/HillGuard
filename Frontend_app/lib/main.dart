import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/local_store.dart';
import 'core/mesh/mesh_engine.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'modules/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStore = LocalStore();
  await localStore.init();

  final meshEngine = MeshEngine(localStore: localStore);
  final syncManager = SyncManager(localStore: localStore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalStore>.value(value: localStore),
        ChangeNotifierProvider<MeshEngine>.value(value: meshEngine),
        ChangeNotifierProvider<SyncManager>.value(value: syncManager),
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
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
