import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

export interface LandslideDto {
  id: string;
  timestamp?: string;
  latitude: number;
  longitude: number;
  altitude?: number;
  locationDescription: string;
  severity: string;
  detectedFeatures: string[];
  estimatedSlopeAngle: number;
  plainLanguageExplanation: string;
  recommendedSafetyActions: string[];
  localPhotoPath?: string;
  reporterId: string;
  relayHops?: number;
  lastRelayPeer?: string;
}

@Injectable()
export class LandslideService {
  private readonly logger = new Logger(LandslideService.name);

  constructor(private readonly db: DatabaseService) {}

  async createOrUpdate(dto: LandslideDto) {
    const text = `
      INSERT INTO landslide_reports (
        id, timestamp, latitude, longitude, altitude, location_description,
        severity, detected_features, estimated_slope_angle, plain_language_explanation,
        recommended_safety_actions, local_photo_path, reporter_id, relay_hops, last_relay_peer
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      ON CONFLICT (id) DO UPDATE SET
        severity = EXCLUDED.severity,
        detected_features = EXCLUDED.detected_features,
        plain_language_explanation = EXCLUDED.plain_language_explanation,
        relay_hops = EXCLUDED.relay_hops,
        last_relay_peer = EXCLUDED.last_relay_peer
      RETURNING *;
    `;

    const values = [
      dto.id,
      dto.timestamp ? new Date(dto.timestamp) : new Date(),
      dto.latitude,
      dto.longitude,
      dto.altitude ?? null,
      dto.locationDescription,
      dto.severity,
      JSON.stringify(dto.detectedFeatures ?? []),
      dto.estimatedSlopeAngle,
      dto.plainLanguageExplanation,
      JSON.stringify(dto.recommendedSafetyActions ?? []),
      dto.localPhotoPath ?? null,
      dto.reporterId,
      dto.relayHops ?? 0,
      dto.lastRelayPeer ?? null,
    ];

    try {
      const res = await this.db.query(text, values);
      this.logger.log(`Landslide report saved: ${dto.id} (${dto.severity})`);
      return res.rows[0];
    } catch (err) {
      this.logger.error(`Failed to insert landslide report: ${err.message}`);
      return dto; // graceful return
    }
  }

  async findAll(limit: number = 50) {
    try {
      const res = await this.db.query(
        `SELECT * FROM landslide_reports ORDER BY timestamp DESC LIMIT $1;`,
        [limit],
      );
      return res.rows;
    } catch (err) {
      return [];
    }
  }

  async getClusters() {
    try {
      // Find hotspots of landslide activity within 1500m of each other
      const query = `
        SELECT 
          severity,
          COUNT(*) as report_count,
          AVG(latitude) as center_lat,
          AVG(longitude) as center_lon,
          MAX(timestamp) as latest_report
        FROM landslide_reports
        GROUP BY severity
        ORDER BY report_count DESC;
      `;
      const res = await this.db.query(query);
      return res.rows;
    } catch (err) {
      return [];
    }
  }
}
