import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/location/location_service.dart';
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
  bool _offlineTacticalMode = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _centerOnUserGps(LatLng userPos) {
    _mapController.move(userPos, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();
    final locationService = context.watch<LocationService>();

    final userPos = locationService.currentLatLng;
    final landslides = localStore.landslideReports;
    final roads = localStore.roadReports;

    final markers = <Marker>[];

    // 1. Add User Real GPS Marker
    markers.add(
      Marker(
        point: userPos,
        width: 60,
        height: 60,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 38 * _pulseAnimation.value,
                  height: 38 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
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

    // 2. Add Landslide Markers
    if (_filter == 'ALL' || _filter == 'B1_LANDSLIDE') {
      for (final report in landslides) {
        markers.add(
          Marker(
            point: LatLng(report.latitude, report.longitude),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _showLandslideDetail(context, report),
              child: Container(
                decoration: BoxDecoration(
                  color: report.severity.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: report.severity.color.withAlpha(150),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.black, size: 24),
              ),
            ),
          ),
        );
      }
    }

    // 3. Add Road Blockage Markers
    if (_filter == 'ALL' || _filter == 'B6_ROAD') {
      for (final road in roads) {
        markers.add(
          Marker(
            point: LatLng(road.latitude, road.longitude),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _showRoadDetail(context, road),
              child: Container(
                decoration: BoxDecoration(
                  color: road.status.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: road.status.color.withAlpha(150),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.block, color: Colors.white, size: 22),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map with Dark Tile Styling & Vector Accuracy Circles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userPos,
              initialZoom: 13.0,
              minZoom: 8,
              maxZoom: 18,
            ),
            children: [
              if (!_offlineTacticalMode)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hillguard.app',
                  fallbackUrl: '',
                ),
              // Concentric GPS Distance Rings (500m, 1km, 2km, 5km) for mountain awareness
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userPos,
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppTheme.primary.withAlpha(15),
                    borderColor: AppTheme.primary.withAlpha(80),
                    borderStrokeWidth: 1.0,
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
                    borderColor: AppTheme.meshActive.withAlpha(40),
                    borderStrokeWidth: 1.0,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Offline Tactical Grid Overlay (When tiles are unavailable without internet)
          if (_offlineTacticalMode)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TacticalGridPainter(),
                ),
              ),
            ),

          // Top Floating Bar: GPS Fix Status & Filters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Live GPS telemetry badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGlass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
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
                        // Offline Tactical Mode Toggle
                        GestureDetector(
                          onTap: () {
                            setState(() => _offlineTacticalMode = !_offlineTacticalMode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  _offlineTacticalMode
                                      ? 'Offline Vector Tactical Mode ON (0% Internet)'
                                      : 'Online Tile Mode ON',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _offlineTacticalMode ? AppTheme.primary : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _offlineTacticalMode ? 'TACTICAL' : 'TILES',
                              style: TextStyle(
                                color: _offlineTacticalMode ? Colors.black : AppTheme.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter Chips Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'All Hazards'),
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

          // Snap to My GPS Button
          Positioned(
            right: 16,
            bottom: 90,
            child: FloatingActionButton.small(
              backgroundColor: AppTheme.surfaceElevated,
              foregroundColor: AppTheme.primary,
              tooltip: 'Snap to My GPS Location',
              onPressed: () {
                _centerOnUserGps(userPos);
                locationService.refreshLocation();
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Bottom Quick Action Buttons
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.severityHigh,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.landslide, size: 20),
                    label: const Text('Report Landslide (B1)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LandslideReporterScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add_road, size: 20),
                    label: const Text('Report Road (B6)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoadReporterScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.surfaceElevated,
        onSelected: (selected) {
          if (selected) setState(() => _filter = key);
        },
      ),
    );
  }

  void _showLandslideDetail(BuildContext context, LandslideReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.meshActive.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.meshActive.withAlpha(80)),
                    ),
                    child: Text(
                      'MESH HOPS: ${report.relayHops}',
                      style: const TextStyle(color: AppTheme.meshActive, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${report.estimatedSlopeAngle.toStringAsFixed(0)}° Slope',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.locationDescription,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                report.plainLanguageExplanation,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text('Life-Safety Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
              const SizedBox(height: 6),
              ...report.recommendedSafetyActions.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $a', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showRoadDetail(BuildContext context, RoadReport road) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
              if (road.estimatedClearanceTime != null) ...[
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

class _TacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x2200E5FF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Tactical crosshairs
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Range rings
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 80, paint);
    canvas.drawCircle(center, 160, paint);
    canvas.drawCircle(center, 240, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
