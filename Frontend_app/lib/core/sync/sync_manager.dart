import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/hazard_types.dart';
import '../models/mesh_packet.dart';
import '../storage/local_store.dart';

class SyncManager extends ChangeNotifier {
  final LocalStore localStore;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/api', // Docker/Local NestJS backend endpoint
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  bool _isOnline = false;
  bool _isSyncing = false;
  String _lastSyncMessage = 'Ready';
  DateTime? _lastSyncTime;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get lastSyncMessage => _lastSyncMessage;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncManager({required this.localStore}) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet,
      );
      final wasOffline = !_isOnline;
      _isOnline = hasConnection;
      notifyListeners();

      if (wasOffline && _isOnline) {
        // Automatically attempt flush when internet connectivity returns!
        syncNow();
      }
    });

    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      _isOnline = results.any(
        (r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet,
      );
      notifyListeners();
    });
  }

  void setSimulatedConnectivity(bool online) {
    _isOnline = online;
    notifyListeners();
    if (_isOnline) {
      syncNow();
    }
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _lastSyncMessage = 'Syncing offline reports & mesh packets...';
    notifyListeners();

    int syncedLandslides = 0;
    int syncedRoads = 0;
    int syncedPackets = 0;

    try {
      // 1. Sync Pending Landslide Reports
      final pendingLandslides = localStore.landslideReports
          .where((r) => r.syncStatus != SyncStatus.syncedToCloud)
          .toList();

      for (final report in pendingLandslides) {
        try {
          await _dio.post('/reports/landslide', data: report.toMap());
          await localStore.markLandslideSynced(report.id);
          syncedLandslides++;
        } catch (e) {
          // If server is not responding, simulate graceful offline retention
          debugPrint('SyncManager backend upload note: $e');
        }
      }

      // 2. Sync Pending Road Reports
      final pendingRoads = localStore.roadReports
          .where((r) => r.syncStatus != SyncStatus.syncedToCloud)
          .toList();

      for (final report in pendingRoads) {
        try {
          await _dio.post('/reports/road', data: report.toMap());
          await localStore.markRoadSynced(report.id);
          syncedRoads++;
        } catch (e) {
          debugPrint('SyncManager road report upload note: $e');
        }
      }

      // 3. Sync Mesh Packets (Relayed reports gathered from peer phones)
      final queue = List<MeshPacket>.from(localStore.meshQueue);
      for (final packet in queue) {
        try {
          await _dio.post('/mesh/ingest', data: packet.toMap());
          syncedPackets++;
        } catch (e) {
          debugPrint('SyncManager mesh packet upload note: $e');
        }
      }

      _lastSyncTime = DateTime.now();
      _lastSyncMessage =
          'Sync completed. Uploaded $syncedLandslides landslides, $syncedRoads road alerts, $syncedPackets mesh packets.';
    } catch (e) {
      _lastSyncMessage = 'Sync paused: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
