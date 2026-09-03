import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
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

class _DisasterMapScreenState extends State<DisasterMapScreen> {
  final MapController _mapController = MapController();
  String _filter = 'ALL'; // 'ALL', 'B1_LANDSLIDE', 'B6_ROAD'

  // Center on Darjeeling / Kurseong / NH-55 mountain corridor
  final LatLng _initialCenter = const LatLng(26.9100, 88.3250);

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();

    final landslides = localStore.landslideReports;
    final roads = localStore.roadReports;

    final markers = <Marker>[];

    // Add Landslide Markers
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

    // Add Road Blockage Markers
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
          // Flutter Map with Dark Tile Styling
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12.5,
              minZoom: 9,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hillguard.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Top Floating Filter Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.layers, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
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
                      foregroundColor: Colors.black,
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
          color: isSelected ? Colors.black : AppTheme.textPrimary,
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
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.severity.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.severity.displayName,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.meshActive.withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.meshActive),
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
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: road.status.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      road.status.label,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
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
