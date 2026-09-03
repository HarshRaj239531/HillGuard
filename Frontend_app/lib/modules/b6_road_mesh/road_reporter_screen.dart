import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/location/location_service.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/road_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_theme.dart';

class RoadReporterScreen extends StatefulWidget {
  const RoadReporterScreen({super.key});

  @override
  State<RoadReporterScreen> createState() => _RoadReporterScreenState();
}

class _RoadReporterScreenState extends State<RoadReporterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedRoad = 'NH-55 (Hill Cart Road)';
  final _sectionController = TextEditingController(text: 'Mile 18, Near Pagla Jhora');
  final _clearanceController = TextEditingController(text: '3 to 5 Hours (JCB clearing rock debris)');
  final _descriptionController = TextEditingController(
    text: 'Massive boulder fall blocking both uphill and downhill lanes. Debris still sliding.',
  );

  RoadConditionStatus _status = RoadConditionStatus.blocked;
  RoadObstacleType _obstacleType = RoadObstacleType.landslideDebris;
  bool _passableTwoWheeler = false;
  bool _passable4x4 = false;

  double _latitude = 26.9215;
  double _longitude = 88.3142;

  final List<String> _popularRoads = [
    'NH-55 (Hill Cart Road)',
    'NH-10 (Sevoke - Teesta - Gangtok)',
    'SH-12 (Mirik - Sukhiapokhri)',
    'Rohini Valley Bypass',
    'Pankhabari Heritage Cut',
    'Rishi Road (Kalimpong - Lava)',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<LocationService>();
      setState(() {
        _latitude = loc.currentLat;
        _longitude = loc.currentLon;
      });
    });
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _clearanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitRoadReport() async {
    final report = RoadReport(
      id: 'rd-${const Uuid().v4().substring(0, 8)}',
      roadIdentifier: _selectedRoad,
      sectionName: _sectionController.text.trim(),
      status: _status,
      obstacleType: _obstacleType,
      latitude: _latitude,
      longitude: _longitude,
      timestamp: DateTime.now(),
      estimatedClearanceTime: _clearanceController.text.trim(),
      passableByTwoWheeler: _passableTwoWheeler,
      passableBy4x4: _passable4x4,
      description: _descriptionController.text.trim(),
      reporterId: context.read<MeshEngine>().deviceId,
      syncStatus: SyncStatus.pendingSync,
    );

    // 1. Store locally in offline DB
    await context.read<LocalStore>().saveRoadReport(report);

    // 2. Transmit across Phone-to-Phone Mesh
    if (mounted) {
      await context.read<MeshEngine>().broadcastRoadReport(report);
    }

    // 3. Attempt cloud upload
    if (mounted) {
      context.read<SyncManager>().syncNow();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated,
          content: Row(
            children: [
              Icon(Icons.alt_route, color: _status.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Road condition broadcasted to $_selectedRoad mesh network!',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Road Condition (B6)'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Road Selection Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HIGHWAY / MOUNTAIN ROUTE',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 1.1,
                            color: AppTheme.primary,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRoad,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.add_road, color: AppTheme.primary, size: 20),
                      ),
                      items: _popularRoads.map((road) {
                        return DropdownMenuItem(value: road, child: Text(road));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoad = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sectionController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Specific Mile / Curve / Landmark',
                        prefixIcon: Icon(Icons.pin_drop_outlined, size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Road Status Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT PASSABILITY STATUS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 1.1,
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...RoadConditionStatus.values.map((status) {
                      final isSelected = _status == status;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? status.color.withAlpha(35) : AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? status.color : AppTheme.borderSubtle,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => setState(() => _status = status),
                          leading: Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? status.color : AppTheme.textMuted,
                            size: 20,
                          ),
                          title: Text(
                            status.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Obstacle Type & Passage Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NATURE OF OBSTRUCTION',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 1.1,
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RoadObstacleType.values.map((obs) {
                        final isSelected = _obstacleType == obs;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(obs.label),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          selectedColor: AppTheme.accentTeal,
                          backgroundColor: AppTheme.surfaceElevated,
                          side: BorderSide(
                            color: isSelected ? AppTheme.accentTeal : AppTheme.borderSubtle,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _obstacleType = obs);
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 28, color: AppTheme.borderSubtle),

                    // Vehicle passability switches
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Passable by Two-Wheelers / Motorbikes', style: TextStyle(fontSize: 13)),
                      value: _passableTwoWheeler,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _passableTwoWheeler = val ?? false),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Passable by Heavy 4x4 / Emergency Vehicles', style: TextStyle(fontSize: 13)),
                      value: _passable4x4,
                      activeColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _passable4x4 = val ?? false),
                    ),

                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _clearanceController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Clearance Duration',
                        prefixIcon: Icon(Icons.timer_outlined, size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Detailed Field Notes for Drivers',
                        prefixIcon: Icon(Icons.notes, size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitRoadReport,
              icon: const Icon(Icons.share_location),
              label: const Text('BROADCAST ROAD STATUS VIA MESH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _status.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
