import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../../core/location/location_service.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/landslide_report.dart';
import '../../core/models/road_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_theme.dart';
import '../b1_landslide/landslide_reporter_screen.dart';
import '../b6_road_mesh/road_reporter_screen.dart';

class DisasterMapScreen extends StatefulWidget {
  const DisasterMapScreen({super.key});

  @override
  State<DisasterMapScreen> createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  String _filter = 'ALL'; // 'ALL', 'B1_LANDSLIDE', 'B6_ROAD'
  bool _showContours = true;
  final bool _showOnlineTiles = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mountain Hazard Epicenter (Darjeeling / Kurseong / NH-55 Sector)
  static final LatLng _mountainHazardCenter = LatLng(26.8820, 88.3150);

  // Pre-computed Vector Corridors for 100% Offline Visualization
  static final List<LatLng> _nh55Highway = [
    LatLng(26.7900, 88.3600), // Sukna
    LatLng(26.8150, 88.3580), // Rongtong
    LatLng(26.8400, 88.3500), // Chunbhatti
    LatLng(26.8550, 88.3400), // Tindharia
    LatLng(26.8720, 88.3320), // Pagla Jhora Fault
    LatLng(26.8800, 88.3050), // Mahanadi
    LatLng(26.8820, 88.2780), // Kurseong
    LatLng(26.9150, 88.2740), // Tung
    LatLng(26.9450, 88.2650), // Sonada
    LatLng(26.9950, 88.2580), // Jorebungalow
    LatLng(27.0100, 88.2550), // Ghoom
    LatLng(27.0360, 88.2627), // Darjeeling Town
  ];

  static final List<LatLng> _rohiniRoad = [
    LatLng(26.7350, 88.3800), // Matigara Plains
    LatLng(26.7800, 88.3500), // Khaprail
    LatLng(26.8100, 88.3200), // Rohini Toll
    LatLng(26.8400, 88.2950), // Rohini Viewpoint
    LatLng(26.8820, 88.2780), // Kurseong Junction
  ];

  static final List<LatLng> _nh10TeestaHighway = [
    LatLng(26.8880, 88.4730), // Sevoke Coronation Bridge
    LatLng(26.9250, 88.4600), // Kalijhora Sinking Zone
    LatLng(26.9600, 88.4500), // Birik Dara
    LatLng(26.9900, 88.4450), // Rambi
    LatLng(27.0600, 88.4300), // Teesta Bazar
    LatLng(27.0900, 88.4500), // Melli Gorge
  ];

  static final List<LatLng> _pankhabariRoad = [
    LatLng(26.7900, 88.2800), // Garidhura
    LatLng(26.8300, 88.2750), // Pankhabari
    LatLng(26.8550, 88.2720), // Makaibari Estate
    LatLng(26.8820, 88.2780), // Kurseong
  ];

  static final List<LatLng> _teestaRiver = [
    LatLng(27.1200, 88.4700),
    LatLng(27.0900, 88.4500),
    LatLng(27.0600, 88.4300),
    LatLng(26.9900, 88.4450),
    LatLng(26.9250, 88.4600),
    LatLng(26.8880, 88.4730),
    LatLng(26.8400, 88.5100),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateDistanceKm(LatLng p1, LatLng p2) {
    const double r = 6371; // Earth radius in km
    final double dLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final double dLon = (p2.longitude - p1.longitude) * math.pi / 180;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180) *
            math.cos(p2.latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  void _centerOnUserGps(LatLng userPos) {
    _mapController.move(userPos, 14.0);
  }

  void _centerOnHazardZone() {
    _mapController.move(_mountainHazardCenter, 12.0);
  }

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();
    final locationService = context.watch<LocationService>();

    final userPos = locationService.currentLatLng;
    final landslides = localStore.landslideReports;
    final roads = localStore.roadReports;

    // Check road statuses for dynamic coloring
    bool nh55Blocked = roads.any((r) => r.roadIdentifier.contains('NH-55') && r.status == RoadConditionStatus.blocked);
    bool rohiniBlocked = roads.any((r) => r.roadIdentifier.contains('Rohini') && r.status == RoadConditionStatus.blocked);
    bool nh10Blocked = roads.any((r) => r.roadIdentifier.contains('NH-10') && r.status == RoadConditionStatus.blocked);

    final markers = <Marker>[];
    final polylines = <Polyline>[];
    final polygons = <Polygon>[];

    // ==========================================
    // 1. OFFLINE VECTOR MOUNTAIN CORRIDORS
    // ==========================================

    // Natural Drainage: Teesta River
    polylines.add(
      Polyline(
        points: _teestaRiver,
        strokeWidth: 4.0,
        color: const Color(0xFF60A5FA),
      ),
    );

    // NH-55 (Hill Cart Road) - Main Artery
    polylines.add(
      Polyline(
        points: _nh55Highway,
        strokeWidth: 5.5,
        color: nh55Blocked ? const Color(0xFFDC2626) : const Color(0xFF334155),
        borderStrokeWidth: 2.0,
        borderColor: Colors.white,
      ),
    );

    // Rohini Valley Bypass
    polylines.add(
      Polyline(
        points: _rohiniRoad,
        strokeWidth: 4.5,
        color: rohiniBlocked ? const Color(0xFFDC2626) : const Color(0xFF059669),
        borderStrokeWidth: 1.5,
        borderColor: Colors.white,
      ),
    );

    // NH-10 Teesta Canyon Corridor
    polylines.add(
      Polyline(
        points: _nh10TeestaHighway,
        strokeWidth: 4.5,
        color: nh10Blocked ? const Color(0xFFDC2626) : const Color(0xFF475569),
        borderStrokeWidth: 1.5,
        borderColor: Colors.white,
      ),
    );

    // Pankhabari Road
    polylines.add(
      Polyline(
        points: _pankhabariRoad,
        strokeWidth: 3.5,
        color: const Color(0xFF64748B),
        borderStrokeWidth: 1.0,
        borderColor: Colors.white,
      ),
    );

    // ==========================================
    // 2. HIGH-RISK GEOTECHNICAL BASIN POLYGONS
    // ==========================================
    polygons.add(
      Polygon(
        points: [
          LatLng(26.8780, 88.3300),
          LatLng(26.8680, 88.3420),
          LatLng(26.8620, 88.3350),
          LatLng(26.8720, 88.3220),
        ],
        color: const Color(0x22DC2626),
        borderColor: const Color(0x99DC2626),
        borderStrokeWidth: 2.0,
      ),
    );

    // If User is in another region (e.g. testing in Patna/Delhi), draw dynamic connection
    final double distToHills = _calculateDistanceKm(userPos, _mountainHazardCenter);
    if (distToHills > 10.0) {
      // Connect User position to the nearest reported hazard
      if (landslides.isNotEmpty) {
        final nearest = landslides.first;
        polylines.add(
          Polyline(
            points: [userPos, LatLng(nearest.latitude, nearest.longitude)],
            strokeWidth: 2.0,
            color: const Color(0x660284C7),
          ),
        );
      }
    }

    // ==========================================
    // 3. USER REAL GPS MARKER (PULSING TACTICAL BEACON)
    // ==========================================
    markers.add(
      Marker(
        point: userPos,
        width: 70,
        height: 70,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44 * _pulseAnimation.value,
                  height: 44 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(180),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    // ==========================================
    // 4. RICH HAZARD MARKERS (B1 & B6)
    // ==========================================
    if (_filter == 'ALL' || _filter == 'B1_LANDSLIDE') {
      for (final report in landslides) {
        final pos = LatLng(report.latitude, report.longitude);
        final dist = _calculateDistanceKm(userPos, pos);
        final isCritical = report.severity == HazardSeverity.critical;

        markers.add(
          Marker(
            point: pos,
            width: 72,
            height: 72,
            child: GestureDetector(
              onTap: () => _showLandslideDetail(context, report),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: report.severity.color, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isCritical ? 'CRITICAL' : (dist < 5 ? '${dist.toStringAsFixed(1)}km' : report.severity.displayName),
                      style: TextStyle(
                        color: report.severity.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: report.severity.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: report.severity.color.withAlpha(140),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (_filter == 'ALL' || _filter == 'B6_ROAD') {
      for (final road in roads) {
        final pos = LatLng(road.latitude, road.longitude);
        final isBlocked = road.status == RoadConditionStatus.blocked;

        markers.add(
          Marker(
            point: pos,
            width: 76,
            height: 76,
            child: GestureDetector(
              onTap: () => _showRoadDetail(context, road),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: road.status.color, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      road.roadIdentifier.split(' ').first,
                      style: TextStyle(
                        color: road.status.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: road.status.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: road.status.color.withAlpha(140),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      isBlocked ? Icons.block : Icons.alt_route,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Layer: Offline Topographic Canvas (Always active in background)
          Positioned.fill(
            child: CustomPaint(
              painter: _TacticalTopoBackgroundPainter(
                drawContours: _showContours,
              ),
            ),
          ),

          // 2. FlutterMap: Vector Roads, Watershed Polygons, Concentric Rings & Pins
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: landslides.isNotEmpty
                  ? LatLng(landslides.first.latitude, landslides.first.longitude)
                  : userPos,
              initialZoom: 12.5,
              minZoom: 6,
              maxZoom: 18,
            ),
            children: [
              // Online Tile Layer (Tries to load if internet available, otherwise transparent fallback)
              if (_showOnlineTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hillguard.app',
                  tileProvider: NetworkTileProvider(),
                  errorImage: const AssetImage('assets/icons/offline_tile_fallback.png'),
                ),

              // Watershed High-Risk Zones
              PolygonLayer(polygons: polygons),

              // Vector Mountain Road Network (Rendered completely offline with zero internet!)
              PolylineLayer(polylines: polylines),

              // Concentric GPS Radar Distance Rings (500m, 1.5km, 3km)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userPos,
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppTheme.primary.withAlpha(12),
                    borderColor: AppTheme.primary.withAlpha(90),
                    borderStrokeWidth: 1.2,
                  ),
                  CircleMarker(
                    point: userPos,
                    radius: 1500,
                    useRadiusInMeter: true,
                    color: Colors.transparent,
                    borderColor: AppTheme.accentTeal.withAlpha(60),
                    borderStrokeWidth: 1.0,
                  ),
                  CircleMarker(
                    point: userPos,
                    radius: 3000,
                    useRadiusInMeter: true,
                    color: Colors.transparent,
                    borderColor: AppTheme.meshActive.withAlpha(50),
                    borderStrokeWidth: 1.0,
                  ),
                ],
              ),

              // Interactive Hazard & GPS Markers
              MarkerLayer(markers: markers),
            ],
          ),

          // 3. Top Floating Telemetry HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GPS Status & Quick Telemetry
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(245),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          locationService.hasGpsFix ? Icons.gps_fixed : Icons.gps_not_fixed,
                          color: locationService.hasGpsFix ? AppTheme.severityLow : AppTheme.severityMedium,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'GPS: ${userPos.latitude.toStringAsFixed(4)}° N, ${userPos.longitude.toStringAsFixed(4)}° E • Alt: ${locationService.currentAlt.toStringAsFixed(0)}m',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Offline GIS Mode Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0284C7).withAlpha(80)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_off_rounded, size: 11, color: Color(0xFF0284C7)),
                              SizedBox(width: 4),
                              Text(
                                'OFFLINE GIS',
                                style: TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(245),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'All Hazards (${landslides.length + roads.length})'),
                          _buildFilterChip('B1_LANDSLIDE', 'Landslides (${landslides.length})'),
                          _buildFilterChip('B6_ROAD', 'Road Blocks (${roads.length})'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Tactical Quick Navigation Toolbar
          Positioned(
            right: 14,
            bottom: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Jump: Mountain Hazard Zone
                FloatingActionButton.small(
                  heroTag: 'fab_hazards',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFDC2626),
                  tooltip: 'Jump to Hazard Zone',
                  onPressed: _centerOnHazardZone,
                  child: const Icon(Icons.terrain_rounded, size: 20),
                ),
                const SizedBox(height: 10),

                // Quick Jump: My Live GPS
                FloatingActionButton.small(
                  heroTag: 'fab_my_gps',
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  tooltip: 'Center My GPS',
                  onPressed: () => _centerOnUserGps(userPos),
                  child: const Icon(Icons.my_location, size: 20),
                ),
                const SizedBox(height: 10),

                // Toggle Offline Contours
                FloatingActionButton.small(
                  heroTag: 'fab_contours',
                  backgroundColor: _showContours ? AppTheme.primary : Colors.white,
                  foregroundColor: _showContours ? Colors.white : AppTheme.textSecondary,
                  tooltip: 'Toggle Contours',
                  onPressed: () {
                    setState(() => _showContours = !_showContours);
                  },
                  child: const Icon(Icons.layers_outlined, size: 20),
                ),
              ],
            ),
          ),

          // 5. Offline Mountain Corridor Legend (Bottom-Left)
          Positioned(
            left: 14,
            bottom: 84,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 14, height: 4, color: nh55Blocked ? const Color(0xFFDC2626) : const Color(0xFF334155)),
                      const SizedBox(width: 6),
                      Text(
                        'NH-55 (${nh55Blocked ? 'BLOCKED' : 'PASSABLE'})',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: nh55Blocked ? const Color(0xFFDC2626) : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 14, height: 4, color: const Color(0xFF059669)),
                      const SizedBox(width: 6),
                      const Text(
                        'Rohini Bypass (OPEN)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 14, height: 4, color: const Color(0xFF60A5FA)),
                      const SizedBox(width: 6),
                      const Text('Teesta River Basin', style: TextStyle(fontSize: 10, color: Color(0xFF2563EB))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. Floating Action Buttons: Quick Report
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LandslideReporterScreen()),
                      );
                    },
                    icon: const Icon(Icons.landslide_outlined, size: 18),
                    label: const Text('Report Landslide (B1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoadReporterScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_road, size: 18),
                    label: const Text('Report Road (B6)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _filter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primary,
        backgroundColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
          ),
        ),
        onSelected: (selected) {
          if (selected) setState(() => _filter = filterKey);
        },
      ),
    );
  }

  void _showLandslideDetail(BuildContext context, LandslideReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: report.severity.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: report.severity.color.withAlpha(80)),
                    ),
                    child: Text(
                      report.severity.displayName,
                      style: TextStyle(color: report.severity.color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MESH HOPS: ${report.relayHops}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${report.estimatedSlopeAngle.toStringAsFixed(0)}° Slope',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.locationDescription,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                report.plainLanguageExplanation,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text(
                'ACTION CHECKLIST:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 6),
              ...report.recommendedSafetyActions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.severityHigh, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(action, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoadDetail(BuildContext context, RoadReport road) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: road.status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: road.status.color.withAlpha(80)),
                    ),
                    child: Text(
                      road.status.label,
                      style: TextStyle(color: road.status.color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(road.roadIdentifier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(road.sectionName, style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(road.description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    road.passableByTwoWheeler ? Icons.check_circle : Icons.cancel,
                    color: road.passableByTwoWheeler ? AppTheme.severityLow : AppTheme.severityCritical,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    road.passableByTwoWheeler ? 'Passable by 2-Wheeler' : 'No 2-Wheelers',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    road.passableBy4x4 ? Icons.check_circle : Icons.cancel,
                    color: road.passableBy4x4 ? AppTheme.severityLow : AppTheme.severityCritical,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    road.passableBy4x4 ? 'Passable by 4x4' : 'No 4x4',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              if (road.estimatedClearanceTime != null && road.estimatedClearanceTime!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Est. Clearance: ${road.estimatedClearanceTime}', style: const TextStyle(color: AppTheme.severityMedium, fontSize: 12)),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Custom Offline Tactical Topographic Canvas
/// Generates elevation contours, relief grid lines, and mountain valley shading
/// so the screen NEVER looks like a blank grey void when internet is 0%.
class _TacticalTopoBackgroundPainter extends CustomPainter {
  final bool drawContours;

  _TacticalTopoBackgroundPainter({required this.drawContours});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft Alpine Cartography Base Fill
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9); // Crisp Slate-100
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Coordinate Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    const double gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (!drawContours) return;

    // 3. Isometric Topographic Contour Curves
    final contourPaint = Paint()
      ..color = const Color(0xFFCBD5E1) // Slate-300
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final indexContourPaint = Paint()
      ..color = const Color(0xFF94A3B8) // Slate-400 (Index contour)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final centers = [
      Offset(size.width * 0.35, size.height * 0.30), // Pagla Jhora peak
      Offset(size.width * 0.70, size.height * 0.65), // Tindharia ridge
      Offset(size.width * 0.20, size.height * 0.75), // Rohini valley
    ];

    for (int c = 0; c < centers.length; c++) {
      final center = centers[c];
      for (int i = 1; i <= 6; i++) {
        final radiusX = i * 45.0 + (c * 10);
        final radiusY = i * 32.0 + (c * 8);

        final path = Path();
        for (double t = 0; t <= 360; t += 10) {
          final rad = t * math.pi / 180;
          final wobble = math.sin(rad * 3 + (i * 0.5)) * 6.0;
          final x = center.dx + (radiusX + wobble) * math.cos(rad);
          final y = center.dy + (radiusY + wobble) * math.sin(rad);

          if (t == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();

        final paintToUse = (i % 3 == 0) ? indexContourPaint : contourPaint;
        canvas.drawPath(path, paintToUse);
      }
    }

    // 4. Tactical Radar Crosshairs in Corner
    final tacticalPaint = Paint()
      ..color = const Color(0x330284C7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final radarCenter = Offset(size.width - 45, 120);
    canvas.drawCircle(radarCenter, 24, tacticalPaint);
    canvas.drawCircle(radarCenter, 12, tacticalPaint);
    canvas.drawLine(Offset(radarCenter.dx - 28, radarCenter.dy), Offset(radarCenter.dx + 28, radarCenter.dy), tacticalPaint);
    canvas.drawLine(Offset(radarCenter.dx, radarCenter.dy - 28), Offset(radarCenter.dx, radarCenter.dy + 28), tacticalPaint);
  }

  @override
  bool shouldRepaint(covariant _TacticalTopoBackgroundPainter oldDelegate) {
    return oldDelegate.drawContours != drawContours;
  }
}
