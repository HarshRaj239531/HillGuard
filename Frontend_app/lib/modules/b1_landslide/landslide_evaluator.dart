import '../../core/models/hazard_types.dart';

class EvaluationResult {
  final HazardSeverity severity;
  final int riskScore; // 0 to 100
  final String primaryFactor;
  final String plainLanguageExplanation;
  final List<String> safetyActions;

  EvaluationResult({
    required this.severity,
    required this.riskScore,
    required this.primaryFactor,
    required this.plainLanguageExplanation,
    required this.safetyActions,
  });
}

class LandslideEvaluator {
  /// Deterministic safety evaluation combining detected vision features and slope geometry.
  /// Guarantees zero-cloud offline reliability.
  static EvaluationResult evaluate({
    required List<LandslideFeature> features,
    required double slopeAngleDegrees,
    required bool hasRecentRainfall,
    required double? crackWidthCm,
  }) {
    int score = 10; // baseline

    // 1. Slope inclination weighting
    if (slopeAngleDegrees >= 45) {
      score += 25;
    } else if (slopeAngleDegrees >= 35) {
      score += 15;
    } else if (slopeAngleDegrees >= 25) {
      score += 8;
    }

    // 2. Feature contributions
    final hasCrack = features.contains(LandslideFeature.tensionCrack);
    final hasSeepage = features.contains(LandslideFeature.waterSeepage);
    final hasDebris = features.contains(LandslideFeature.debrisFall);
    final hasBulge = features.contains(LandslideFeature.slopeBulge);
    final hasTiltedTrees = features.contains(LandslideFeature.tiltedTrees);
    final hasWallDamage = features.contains(LandslideFeature.wallDeformation);

    if (hasCrack) {
      final width = crackWidthCm ?? 5.0;
      if (width > 10.0) {
        score += 35;
      } else {
        score += 20;
      }
    }

    if (hasSeepage) {
      score += 20;
    }

    if (hasBulge) {
      score += 25; // Toe bulging signifies active shearing plane
    }

    if (hasDebris) {
      score += 15;
    }

    if (hasTiltedTrees) {
      score += 12;
    }

    if (hasWallDamage) {
      score += 18;
    }

    if (hasRecentRainfall) {
      score += 15; // Pore water pressure multiplier
    }

    // Cap score at 100
    if (score > 100) score = 100;

    // Severity categorization
    final HazardSeverity severity;
    if (score >= 80) {
      severity = HazardSeverity.critical;
    } else if (score >= 55) {
      severity = HazardSeverity.high;
    } else if (score >= 30) {
      severity = HazardSeverity.medium;
    } else {
      severity = HazardSeverity.low;
    }

    // Plain-language explanation generation
    final explanation = _generateExplanation(
      severity: severity,
      hasCrack: hasCrack,
      hasSeepage: hasSeepage,
      hasBulge: hasBulge,
      hasDebris: hasDebris,
      slopeAngle: slopeAngleDegrees,
      hasRain: hasRecentRainfall,
    );

    // Recommended actions
    final actions = _generateActions(severity, hasCrack, hasBulge);

    final primaryFactor = hasBulge
        ? 'Active Basal Shearing / Toe Bulge'
        : hasCrack
            ? 'Open Crown Tension Cracks'
            : hasSeepage
                ? 'High Hydraulic Pore Pressure'
                : 'Steep Unstable Overburden';

    return EvaluationResult(
      severity: severity,
      riskScore: score,
      primaryFactor: primaryFactor,
      plainLanguageExplanation: explanation,
      safetyActions: actions,
    );
  }

  static String _generateExplanation({
    required HazardSeverity severity,
    required bool hasCrack,
    required bool hasSeepage,
    required bool hasBulge,
    required bool hasDebris,
    required double slopeAngle,
    required bool hasRain,
  }) {
    final buffer = StringBuffer();

    switch (severity) {
      case HazardSeverity.critical:
        buffer.write('IMMINENT SLOPE COLLAPSE RISK. ');
        break;
      case HazardSeverity.high:
        buffer.write('HIGH SLOPE INSTABILITY DETECTED. ');
        break;
      case HazardSeverity.medium:
        buffer.write('MODERATE HAZARD WARNING. ');
        break;
      case HazardSeverity.low:
        buffer.write('LOW APPARENT HAZARD. ');
        break;
    }

    if (hasCrack && hasSeepage) {
      buffer.write(
        'The simultaneous presence of tension fissures and groundwater seepage indicates rapid internal shearing and water lubrication along the slip plane. ',
      );
    } else if (hasCrack) {
      buffer.write(
        'Open tension cracks indicate the upper slope crown is pulling away under gravitational stress. ',
      );
    } else if (hasBulge) {
      buffer.write(
        'Toe ground bulging signals that the underlying soil mass is actively pushing outward. ',
      );
    }

    if (slopeAngle >= 40) {
      buffer.write('The steep incline (${slopeAngle.toStringAsFixed(0)}°) severely amplifies velocity upon release. ');
    }

    if (hasRain) {
      buffer.write('Recent precipitation has saturated the overburden, lowering shear resistance.');
    }

    return buffer.toString();
  }

  static List<String> _generateActions(
    HazardSeverity severity,
    bool hasCrack,
    bool hasBulge,
  ) {
    if (severity == HazardSeverity.critical) {
      return [
        'EVACUATE IMMEDIATELY: Move uphill or sideways out of the fall line.',
        'Do not traverse under the slope under any circumstances.',
        'Alert downhill dwellings and initiate siren/whistle warnings.',
        'Report blockage to District Emergency Operations Centre (DEOC).',
      ];
    } else if (severity == HazardSeverity.high) {
      return [
        'Establish a 100-meter safety barrier above and below.',
        'Divert all pedestrian and vehicular traffic.',
        'Inspect drainage culverts for sudden blockage or muddy outflow.',
        'Broadcast alert across the mesh network to nearby phones.',
      ];
    } else if (severity == HazardSeverity.medium) {
      return [
        'Monitor crack width at regular 2-hour intervals.',
        'Avoid parking vehicles near the retaining wall or cut face.',
        'Prepare emergency grab-bag and maintain battery charge.',
      ];
    } else {
      return [
        'Keep surface drains cleared of fallen leaves and soil debris.',
        'Report any new weeping holes or water bubbling to authorities.',
      ];
    }
  }
}
