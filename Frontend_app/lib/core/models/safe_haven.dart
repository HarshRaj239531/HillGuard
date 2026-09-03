import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum SafeHavenType {
  subDivisionalHospital,
  primaryHealthCentre,
  disasterReliefShelter,
  emergencyRescuePost,
}

extension SafeHavenTypeExtension on SafeHavenType {
  String get displayName {
    switch (this) {
      case SafeHavenType.subDivisionalHospital:
        return 'Sub-Divisional Hospital';
      case SafeHavenType.primaryHealthCentre:
        return 'Primary Health Centre (PHC)';
      case SafeHavenType.disasterReliefShelter:
        return 'Disaster Safe Haven / Shelter';
      case SafeHavenType.emergencyRescuePost:
        return 'Emergency Relief & Police Post';
    }
  }

  IconData get icon {
    switch (this) {
      case SafeHavenType.subDivisionalHospital:
        return Icons.local_hospital_rounded;
      case SafeHavenType.primaryHealthCentre:
        return Icons.medical_services_rounded;
      case SafeHavenType.disasterReliefShelter:
        return Icons.roofing_rounded;
      case SafeHavenType.emergencyRescuePost:
        return Icons.shield_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SafeHavenType.subDivisionalHospital:
        return const Color(0xFF059669); // Emerald 600
      case SafeHavenType.primaryHealthCentre:
        return const Color(0xFF0D9488); // Teal 600
      case SafeHavenType.disasterReliefShelter:
        return const Color(0xFF2563EB); // Blue 600
      case SafeHavenType.emergencyRescuePost:
        return const Color(0xFF7C3AED); // Violet 600
    }
  }
}

class SafeHaven {
  final String id;
  final String name;
  final SafeHavenType type;
  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final String locality;
  final int capacity;
  final List<String> medicalCapabilities;
  final String emergencyRadioFreq;
  final String roadAccessNotes;

  const SafeHaven({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.locality,
    required this.capacity,
    required this.medicalCapabilities,
    required this.emergencyRadioFreq,
    required this.roadAccessNotes,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  double distanceKmFrom(LatLng userPos) {
    const double r = 6371; // Earth radius km
    final double dLat = (latitude - userPos.latitude) * math.pi / 180;
    final double dLon = (longitude - userPos.longitude) * math.pi / 180;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(userPos.latitude * math.pi / 180) *
            math.cos(latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  String compassBearingFrom(LatLng userPos) {
    final double y = math.sin((longitude - userPos.longitude) * math.pi / 180) *
        math.cos(latitude * math.pi / 180);
    final double x = math.cos(userPos.latitude * math.pi / 180) *
            math.sin(latitude * math.pi / 180) -
        math.sin(userPos.latitude * math.pi / 180) *
            math.cos(latitude * math.pi / 180) *
            math.cos((longitude - userPos.longitude) * math.pi / 180);
    double bearing = math.atan2(y, x) * 180 / math.pi;
    bearing = (bearing + 360) % 360;

    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final int index = ((bearing + 22.5) / 45).floor() % 8;
    return '${directions[index]} (${bearing.toStringAsFixed(0)}°)';
  }

  // Pre-mapped Safe Havens across mountain valleys (Darjeeling / Kurseong / Teesta & Regional Hubs)
  static final List<SafeHaven> regionalSafeHavens = [
    SafeHaven(
      id: 'haven-001',
      name: 'Kurseong Sub-Divisional Hospital',
      type: SafeHavenType.subDivisionalHospital,
      latitude: 26.8845,
      longitude: 28.2812,
      altitudeMeters: 1480,
      locality: 'Kurseong Town Centre',
      capacity: 120,
      medicalCapabilities: [
        'Trauma Surgery',
        'High-Pressure Oxygen Supply',
        'Hypothermia Rewarming Ward',
        'Blood Bank',
        '24x7 Emergency Doctors',
      ],
      emergencyRadioFreq: 'VHF 154.600 MHz (Hospital Channel 1)',
      roadAccessNotes: 'Approachable via Rohini Road even when NH-55 Pagla Jhora is blocked.',
    ),
    SafeHaven(
      id: 'haven-002',
      name: 'Tindharia Railway Community Shelter & PHC',
      type: SafeHavenType.primaryHealthCentre,
      latitude: 26.8560,
      longitude: 88.3390,
      altitudeMeters: 856,
      locality: 'Tindharia Mid-Slopes',
      capacity: 85,
      medicalCapabilities: [
        'First-Aid Triage',
        'Burn & Fracture Splinting',
        'IV Fluids & Dehydration Packs',
        'Oxygen Concentrator',
      ],
      emergencyRadioFreq: 'VHF 154.250 MHz',
      roadAccessNotes: 'Situated on stable rock spur above the Tindharia railway workshop.',
    ),
    SafeHaven(
      id: 'haven-003',
      name: 'Makaibari Community Relief Safe Haven',
      type: SafeHavenType.disasterReliefShelter,
      latitude: 26.8520,
      longitude: 88.2710,
      altitudeMeters: 1250,
      locality: 'Makaibari Lower Valley',
      capacity: 250,
      medicalCapabilities: [
        'Emergency Thermal Blankets',
        'Potable Water Filtration Unit',
        'Dry Food Stock (7 Days)',
        'Basic Trauma Dressing',
      ],
      emergencyRadioFreq: 'PMR446 Channel 7 / 446.08125 MHz',
      roadAccessNotes: 'Direct access via Pankhabari Heritage Cut. Zero subsidence risk.',
    ),
    SafeHaven(
      id: 'haven-004',
      name: 'Sukna Army Base Hospital & Relief Staging',
      type: SafeHavenType.subDivisionalHospital,
      latitude: 26.7920,
      longitude: 88.3620,
      altitudeMeters: 165,
      locality: 'Sukna Plains Foothills',
      capacity: 350,
      medicalCapabilities: [
        'Air-Evacuation Helipad',
        'ICU & Ventilators',
        'Orthopedic Reconstruction',
        'NDRF Staging Battalion',
      ],
      emergencyRadioFreq: 'VHF 155.100 MHz (Military Disaster Net)',
      roadAccessNotes: 'All-weather plains access. Serves as primary casualty evacuation point.',
    ),
    SafeHaven(
      id: 'haven-005',
      name: 'Teesta Low Dam Safe Refuge & SDRF Outpost',
      type: SafeHavenType.emergencyRescuePost,
      latitude: 26.9280,
      longitude: 88.4620,
      altitudeMeters: 210,
      locality: 'Kalijhora Canyon Floor',
      capacity: 90,
      medicalCapabilities: [
        'River Rescue Boats (Zodiacs)',
        'Spinal Immobilization Boards',
        'Crush Injury Medication',
        'Satellite Phone Uplink',
      ],
      emergencyRadioFreq: 'VHF 152.850 MHz (SDRF River Net)',
      roadAccessNotes: 'Located 40m above river high-water line on engineered concrete abutment.',
    ),
  ];

  static SafeHaven findNearest(LatLng userPos) {
    SafeHaven nearest = regionalSafeHavens.first;
    double minDistance = nearest.distanceKmFrom(userPos);

    for (final haven in regionalSafeHavens) {
      final dist = haven.distanceKmFrom(userPos);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = haven;
      }
    }
    return nearest;
  }
}
