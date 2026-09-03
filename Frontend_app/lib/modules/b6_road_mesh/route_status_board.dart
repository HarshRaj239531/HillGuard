import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/hazard_types.dart';
import '../../core/models/road_report.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_theme.dart';

class CorridorSummary {
  final String roadName;
  final RoadConditionStatus overallStatus;
  final String latestSection;
  final String summaryText;
  final bool passableTwoWheeler;
  final bool passable4x4;
  final String? estimatedClearance;
  final int totalReports;
  final DateTime lastUpdated;

  CorridorSummary({
    required this.roadName,
    required this.overallStatus,
    required this.latestSection,
    required this.summaryText,
    required this.passableTwoWheeler,
    required this.passable4x4,
    this.estimatedClearance,
    required this.totalReports,
    required this.lastUpdated,
  });
}

class RouteStatusBoard extends StatelessWidget {
  const RouteStatusBoard({super.key});

  static List<CorridorSummary> computeCorridorSummaries(List<RoadReport> reports) {
    final Map<String, List<RoadReport>> grouped = {};
    for (final r in reports) {
      grouped.putIfAbsent(r.roadIdentifier, () => []).add(r);
    }

    // Standard list of primary mountain arteries
    final standardRoads = [
      'NH-55 (Hill Cart Road)',
      'NH-10 (Sevoke - Teesta - Gangtok)',
      'Rohini Valley Bypass',
      'SH-12 (Mirik - Sukhiapokhri)',
      'Pankhabari Heritage Cut',
      'Rishi Road (Kalimpong - Lava)',
    ];

    final summaries = <CorridorSummary>[];

    for (final roadName in standardRoads) {
      final roadReports = grouped[roadName] ?? [];
      if (roadReports.isEmpty) {
        // Default clear status when no obstructions reported
        summaries.add(
          CorridorSummary(
            roadName: roadName,
            overallStatus: RoadConditionStatus.clear,
            latestSection: 'Entire Highway',
            summaryText: 'No active obstructions reported. Traffic flowing normally.',
            passableTwoWheeler: true,
            passable4x4: true,
            totalReports: 0,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        // Sort newest first
        roadReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final latest = roadReports.first;

        // Overall status is worst status reported on that road
        RoadConditionStatus worst = RoadConditionStatus.clear;
        for (final r in roadReports) {
          if (r.status == RoadConditionStatus.blocked) {
            worst = RoadConditionStatus.blocked;
            break;
          } else if (r.status == RoadConditionStatus.partiallyBlocked) {
            worst = RoadConditionStatus.partiallyBlocked;
          } else if (r.status == RoadConditionStatus.hazardous && worst == RoadConditionStatus.clear) {
            worst = RoadConditionStatus.hazardous;
          }
        }

        summaries.add(
          CorridorSummary(
            roadName: roadName,
            overallStatus: worst,
            latestSection: latest.sectionName,
            summaryText: latest.description,
            passableTwoWheeler: latest.passableByTwoWheeler,
            passable4x4: latest.passableBy4x4,
            estimatedClearance: latest.estimatedClearanceTime,
            totalReports: roadReports.length,
            lastUpdated: latest.timestamp,
          ),
        );
      }
    }

    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final localStore = context.watch<LocalStore>();
    final summaries = computeCorridorSummaries(localStore.roadReports);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Route Status Board (B6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(60)),
            ),
            child: const Center(
              child: Text(
                'LIVE MESH SYNC',
                style: TextStyle(color: AppTheme.accentTeal, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header description card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(80), width: 1.2),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.alt_route, color: AppTheme.accentTeal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'HIMALAYAN HIGHWAY ARTERY BOARD',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, color: AppTheme.accentTeal),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Crowd-sourced road statuses summarized on-device from peer-to-peer mesh packets.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'MAJOR CORRIDOR STATUSES',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),

          ...summaries.map((summary) => _buildCorridorCard(context, summary)),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCorridorCard(BuildContext context, CorridorSummary summary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: summary.overallStatus.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: summary.overallStatus.color.withAlpha(90)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        summary.overallStatus == RoadConditionStatus.clear
                            ? Icons.check_circle
                            : summary.overallStatus == RoadConditionStatus.blocked
                                ? Icons.block
                                : Icons.warning_rounded,
                        color: summary.overallStatus.color,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        summary.overallStatus.label,
                        style: TextStyle(color: summary.overallStatus.color, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.roadName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${summary.totalReports} reports',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Section: ${summary.latestSection}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              summary.summaryText,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.borderSubtle),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  summary.passableTwoWheeler ? Icons.check_circle : Icons.cancel,
                  color: summary.passableTwoWheeler ? AppTheme.severityLow : AppTheme.severityCritical,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  summary.passableTwoWheeler ? '2-Wheelers OK' : 'No 2-Wheelers',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 14),
                Icon(
                  summary.passable4x4 ? Icons.check_circle : Icons.cancel,
                  color: summary.passable4x4 ? AppTheme.severityLow : AppTheme.severityCritical,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  summary.passable4x4 ? '4x4 OK' : 'No 4x4',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                if (summary.estimatedClearance != null)
                  Text(
                    'Clear: ${summary.estimatedClearance}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.severityMedium, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
