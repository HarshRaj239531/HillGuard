import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum HazardSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case HazardSeverity.low:
        return 'LOW RISK';
      case HazardSeverity.medium:
        return 'MEDIUM RISK';
      case HazardSeverity.high:
        return 'HIGH RISK';
      case HazardSeverity.critical:
        return 'CRITICAL EVACUATION';
    }
  }

  Color get color {
    switch (this) {
      case HazardSeverity.low:
        return AppTheme.severityLow;
      case HazardSeverity.medium:
        return AppTheme.severityMedium;
      case HazardSeverity.high:
        return AppTheme.severityHigh;
      case HazardSeverity.critical:
        return AppTheme.severityCritical;
    }
  }
}

enum LandslideFeature {
  tensionCrack('Tension Cracks on Crown / Slope'),
  waterSeepage('Fresh Water Seepage / Mud Flow'),
  debrisFall('Recent Rockfall / Rolling Debris'),
  slopeBulge('Toe Bulging / Ground Swelling'),
  tiltedTrees('Tilted Trees / Bent Utility Poles'),
  wallDeformation('Cracked Retaining Wall / Culvert');

  final String label;
  const LandslideFeature(this.label);
}

enum RoadConditionStatus {
  clear('Open / Normal', AppTheme.severityLow),
  caution('Passable with Caution', AppTheme.severityMedium),
  partiallyBlocked('Single Lane / Restricted', AppTheme.severityHigh),
  blocked('Completely Blocked', AppTheme.severityCritical),
  hazardous('Severe Active Hazard', AppTheme.severityCritical);

  final String label;
  final Color color;
  const RoadConditionStatus(this.label, this.color);
}

enum RoadObstacleType {
  landslideDebris('Landslide / Soil Debris'),
  rockfall('Fallen Boulders / Rockfall'),
  fallenTree('Fallen Tree / Power Cables'),
  roadCaveIn('Road Subsidence / Cave-in'),
  waterlogged('Flash Flood / Mud Wash'),
  bridgeStructuralIssue('Bridge Damage / Pier Shift');

  final String label;
  const RoadObstacleType(this.label);
}

enum SyncStatus {
  pendingSync,
  relayedViaMesh,
  syncedToCloud,
}
