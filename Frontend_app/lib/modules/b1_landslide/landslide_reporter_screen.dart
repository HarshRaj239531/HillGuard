import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/landslide_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/mesh/mesh_engine.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/theme/app_theme.dart';
import 'landslide_evaluator.dart';

class LandslideReporterScreen extends StatefulWidget {
  const LandslideReporterScreen({super.key});

  @override
  State<LandslideReporterScreen> createState() => _LandslideReporterScreenState();
}

class _LandslideReporterScreenState extends State<LandslideReporterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController(text: 'NH-55 Tindharia Curve, Hillside');
  final _notesController = TextEditingController();

  double _slopeAngle = 42.0;
  double _crackWidth = 8.5;
  bool _hasRain = true;
  XFile? _capturedImage;

  final Set<LandslideFeature> _selectedFeatures = {
    LandslideFeature.tensionCrack,
    LandslideFeature.waterSeepage,
  };

  // Default coordinate (Darjeeling/Kurseong Himalayan belt)
  double _latitude = 26.9048;
  double _longitude = 88.3375;
  final double _altitude = 1520.0;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _capturedImage = picked;
          // When image is picked, simulate vision detection identifying crack + seepage
          _selectedFeatures.add(LandslideFeature.tensionCrack);
          _selectedFeatures.add(LandslideFeature.waterSeepage);
        });
      }
    } catch (e) {
      debugPrint('Image pick note: $e');
    }
  }

  void _submitReport() async {
    final evaluation = LandslideEvaluator.evaluate(
      features: _selectedFeatures.toList(),
      slopeAngleDegrees: _slopeAngle,
      hasRecentRainfall: _hasRain,
      crackWidthCm: _crackWidth,
    );

    final report = LandslideReport(
      id: 'ls-${const Uuid().v4().substring(0, 8)}',
      timestamp: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      altitude: _altitude,
      locationDescription: _locationController.text.trim(),
      severity: evaluation.severity,
      detectedFeatures: _selectedFeatures.toList(),
      estimatedSlopeAngle: _slopeAngle,
      plainLanguageExplanation: evaluation.plainLanguageExplanation,
      recommendedSafetyActions: evaluation.safetyActions,
      localPhotoPath: _capturedImage?.path,
      reporterId: context.read<MeshEngine>().deviceId,
      syncStatus: SyncStatus.pendingSync,
    );

    // 1. Save to Offline DB
    await context.read<LocalStore>().saveLandslideReport(report);

    // 2. Broadcast to Mesh
    if (mounted) {
      await context.read<MeshEngine>().broadcastLandslideReport(report);
    }

    // 3. Attempt Sync if internet available
    if (mounted) {
      context.read<SyncManager>().syncNow();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated,
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: evaluation.severity.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Saved locally & queued for Mesh P2P relay (${evaluation.severity.displayName})',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = LandslideEvaluator.evaluate(
      features: _selectedFeatures.toList(),
      slopeAngleDegrees: _slopeAngle,
      hasRecentRainfall: _hasRain,
      crackWidthCm: _crackWidth,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Landslide Hazard (B1)'),
        actions: [
          IconButton(
            tooltip: 'Simulate GPS Refresh',
            icon: const Icon(Icons.my_location, color: AppTheme.primary),
            onPressed: () {
              setState(() {
                _latitude = 26.9120;
                _longitude = 88.3410;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('GPS coordinates updated: 26.9120° N, 88.3410° E')),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // GPS Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.satellite_alt, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'GEOGRAPHIC PINPOINT',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                letterSpacing: 1.1,
                                color: AppTheme.primary,
                                fontSize: 12,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.severityLow.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'GPS LOCKED (±3m)',
                            style: TextStyle(color: AppTheme.severityLow, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E • Alt: ${_altitude.toStringAsFixed(0)}m',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Location / Landmark Description',
                        prefixIcon: Icon(Icons.place_outlined, size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vision ML & Photo Capture
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.camera_enhance, color: AppTheme.accentTeal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ON-DEVICE VISION SCANNER',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                letterSpacing: 1.1,
                                color: AppTheme.accentTeal,
                                fontSize: 12,
                              ),
                        ),
                        const Spacer(),
                        const Text(
                          'OFFLINE ML',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_capturedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_capturedImage!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(200),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.accentTeal),
                                ),
                                child: const Text(
                                  '✓ Vision Features Extracted',
                                  style: TextStyle(color: AppTheme.accentTeal, fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              side: const BorderSide(color: AppTheme.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detected Hazard Indicators
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OBSERVED GEOTECHNICAL INDICATORS',
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
                      children: LandslideFeature.values.map((feature) {
                        final isSelected = _selectedFeatures.contains(feature);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(feature.label),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceElevated,
                          checkmarkColor: Colors.black,
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFeatures.add(feature);
                              } else {
                                _selectedFeatures.remove(feature);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 28, color: AppTheme.borderSubtle),

                    // Slope Angle Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Slope Inclination', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          '${_slopeAngle.toStringAsFixed(0)}° Steepness',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _slopeAngle,
                      min: 15,
                      max: 75,
                      divisions: 12,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.surfaceElevated,
                      onChanged: (val) => setState(() => _slopeAngle = val),
                    ),

                    // Crack Width Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tension Crack Width', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          '${_crackWidth.toStringAsFixed(1)} cm',
                          style: const TextStyle(color: AppTheme.severityHigh, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _crackWidth,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: AppTheme.severityHigh,
                      inactiveColor: AppTheme.surfaceElevated,
                      onChanged: (val) => setState(() => _crackWidth = val),
                    ),

                    // Recent Rainfall Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Recent / Ongoing Heavy Rainfall', style: TextStyle(fontSize: 13)),
                      subtitle: const Text('Increases ground pore-water saturation', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      value: _hasRain,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _hasRain = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Real-Time Edge AI Severity Assessment Card
            Container(
              decoration: BoxDecoration(
                color: evaluation.severity.color.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: evaluation.severity.color, width: 1.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_rounded, color: evaluation.severity.color, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        evaluation.severity.displayName,
                        style: TextStyle(
                          color: evaluation.severity.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: evaluation.severity.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'RISK SCORE: ${evaluation.riskScore}/100',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Why:',
                    style: TextStyle(
                      color: evaluation.severity.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evaluation.plainLanguageExplanation,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Recommended Action:',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...evaluation.safetyActions.map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                action,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitReport,
              icon: const Icon(Icons.broadcast_on_personal),
              label: const Text('SAVE LOCALLY & BROADCAST VIA MESH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: evaluation.severity.color,
                foregroundColor: Colors.black,
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
