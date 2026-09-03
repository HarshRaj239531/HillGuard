import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

export interface SafeHavenDto {
  id: string;
  name: string;
  type: string;
  latitude: number;
  longitude: number;
  altitudeMeters: number;
  locality: string;
  capacity: number;
  medicalCapabilities: string[];
  emergencyRadioFreq: string;
  roadAccessNotes: string;
}

@Injectable()
export class SafeHavenService {
  private readonly logger = new Logger(SafeHavenService.name);

  constructor(private readonly db: DatabaseService) {}

  async createOrUpdate(dto: SafeHavenDto) {
    const text = `
      INSERT INTO safe_havens (
        id, name, type, latitude, longitude, altitude_meters,
        locality, capacity, medical_capabilities, emergency_radio_freq, road_access_notes
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        type = EXCLUDED.type,
        capacity = EXCLUDED.capacity,
        medical_capabilities = EXCLUDED.medical_capabilities,
        emergency_radio_freq = EXCLUDED.emergency_radio_freq,
        road_access_notes = EXCLUDED.road_access_notes
      RETURNING *;
    `;

    const values = [
      dto.id,
      dto.name,
      dto.type,
      dto.latitude,
      dto.longitude,
      dto.altitudeMeters,
      dto.locality,
      dto.capacity,
      JSON.stringify(dto.medicalCapabilities ?? []),
      dto.emergencyRadioFreq,
      dto.roadAccessNotes,
    ];

    try {
      const res = await this.db.query(text, values);
      this.logger.log(`Safe Haven registered: ${dto.name} (${dto.type})`);
      return res.rows[0];
    } catch (err) {
      this.logger.error(`Failed to register safe haven: ${err.message}`);
      return dto;
    }
  }

  async findAll() {
    try {
      const res = await this.db.query(`SELECT * FROM safe_havens ORDER BY name ASC;`);
      return res.rows;
    } catch (err) {
      return [];
    }
  }

  /// Geospatial PostGIS calculation for the closest medical / shelter safe haven
  async findNearest(lat: number, lon: number) {
    const query = `
      SELECT 
        id, name, type, latitude, longitude, altitude_meters, locality,
        capacity, medical_capabilities, emergency_radio_freq, road_access_notes,
        ROUND(ST_Distance(location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography)::numeric, 1) as distance_meters
      FROM safe_havens
      ORDER BY distance_meters ASC
      LIMIT 1;
    `;

    try {
      const res = await this.db.query(query, [lat, lon]);
      return res.rows[0] ?? null;
    } catch (err) {
      this.logger.error(`Nearest safe haven query error: ${err.message}`);
      return null;
    }
  }
}
