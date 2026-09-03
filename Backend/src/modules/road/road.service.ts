import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

export interface RoadDto {
  id: string;
  roadIdentifier: string;
  sectionName: string;
  status: string;
  obstacleType: string;
  latitude: number;
  longitude: number;
  timestamp?: string;
  estimatedClearanceTime?: string;
  passableByTwoWheeler?: boolean;
  passableBy4x4?: boolean;
  description: string;
  reporterId: string;
  relayHops?: number;
  lastRelayPeer?: string;
}

@Injectable()
export class RoadService {
  private readonly logger = new Logger(RoadService.name);

  constructor(private readonly db: DatabaseService) {}

  async createOrUpdate(dto: RoadDto) {
    const text = `
      INSERT INTO road_reports (
        id, road_identifier, section_name, status, obstacle_type,
        latitude, longitude, timestamp, estimated_clearance_time,
        passable_by_two_wheeler, passable_by_4x4, description, reporter_id,
        relay_hops, last_relay_peer
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      ON CONFLICT (id) DO UPDATE SET
        status = EXCLUDED.status,
        estimated_clearance_time = EXCLUDED.estimated_clearance_time,
        passable_by_two_wheeler = EXCLUDED.passable_by_two_wheeler,
        passable_by_4x4 = EXCLUDED.passable_by_4x4,
        description = EXCLUDED.description,
        relay_hops = EXCLUDED.relay_hops,
        last_relay_peer = EXCLUDED.last_relay_peer
      RETURNING *;
    `;

    const values = [
      dto.id,
      dto.roadIdentifier,
      dto.sectionName,
      dto.status,
      dto.obstacleType,
      dto.latitude,
      dto.longitude,
      dto.timestamp ? new Date(dto.timestamp) : new Date(),
      dto.estimatedClearanceTime ?? null,
      dto.passableByTwoWheeler ?? false,
      dto.passableBy4x4 ?? false,
      dto.description,
      dto.reporterId,
      dto.relayHops ?? 0,
      dto.lastRelayPeer ?? null,
    ];

    try {
      const res = await this.db.query(text, values);
      this.logger.log(`Road condition report saved: ${dto.roadIdentifier} - ${dto.sectionName} (${dto.status})`);
      return res.rows[0];
    } catch (err) {
      this.logger.error(`Failed to insert road report: ${err.message}`);
      return dto;
    }
  }

  async findAll(limit: number = 50) {
    try {
      const res = await this.db.query(
        `SELECT * FROM road_reports ORDER BY timestamp DESC LIMIT $1;`,
        [limit],
      );
      return res.rows;
    } catch (err) {
      return [];
    }
  }

  /// PostGIS ST_DWithin geospatial search for road blockages near current vehicle coordinate
  async findNearby(lat: number, lon: number, radiusMeters: number = 10000) {
    const query = `
      SELECT 
        id, road_identifier, section_name, status, obstacle_type,
        latitude, longitude, timestamp, estimated_clearance_time,
        passable_by_two_wheeler, passable_by_4x4, description,
        ROUND(ST_Distance(location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)::numeric, 1) as distance_meters
      FROM road_reports
      WHERE ST_DWithin(location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography, $3)
      ORDER BY distance_meters ASC;
    `;

    try {
      const res = await this.db.query(query, [lat, lon, radiusMeters]);
      return res.rows;
    } catch (err) {
      this.logger.error(`Nearby road query error: ${err.message}`);
      return [];
    }
  }
}
