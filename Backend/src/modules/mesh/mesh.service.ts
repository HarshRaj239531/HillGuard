import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { LandslideService } from '../landslide/landslide.service';
import { RoadService } from '../road/road.service';

export interface MeshPacketDto {
  packetId: string;
  type: string; // 'landslideReport', 'roadReport', etc.
  payload: string | Record<string, any>;
  originalSenderId: string;
  createdAt: string;
  maxTtl?: number;
  currentHop?: number;
  relayPath?: string[];
  priority?: number;
}

@Injectable()
export class MeshService {
  private readonly logger = new Logger(MeshService.name);

  constructor(
    private readonly db: DatabaseService,
    private readonly landslideService: LandslideService,
    private readonly roadService: RoadService,
  ) {}

  async ingestPacket(packet: MeshPacketDto) {
    this.logger.log(
      `Ingesting relayed mesh packet: ${packet.packetId} (Hop ${packet.currentHop}, Type: ${packet.type})`,
    );

    // 1. Log packet metadata to mesh audit table
    const logQuery = `
      INSERT INTO mesh_packet_logs (
        packet_id, type, payload, original_sender_id, created_at,
        max_ttl, current_hop, relay_path, priority
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (packet_id) DO NOTHING
      RETURNING *;
    `;

    const payloadJson =
      typeof packet.payload === 'string'
        ? packet.payload
        : JSON.stringify(packet.payload);

    try {
      await this.db.query(logQuery, [
        packet.packetId,
        packet.type,
        payloadJson,
        packet.originalSenderId,
        new Date(packet.createdAt),
        packet.maxTtl ?? 5,
        packet.currentHop ?? 0,
        JSON.stringify(packet.relayPath ?? []),
        packet.priority ?? 2,
      ]);
    } catch (err) {
      this.logger.warn(`Mesh packet log note: ${err.message}`);
    }

    // 2. Parse inner payload and upsert corresponding domain table
    try {
      const parsedData =
        typeof packet.payload === 'string'
          ? JSON.parse(packet.payload)
          : packet.payload;

      parsedData.relayHops = packet.currentHop ?? 1;
      parsedData.lastRelayPeer =
        packet.relayPath && packet.relayPath.length > 0
          ? packet.relayPath[packet.relayPath.length - 1]
          : packet.originalSenderId;

      if (packet.type === 'landslideReport') {
        await this.landslideService.createOrUpdate(parsedData);
      } else if (packet.type === 'roadReport') {
        await this.roadService.createOrUpdate(parsedData);
      }
    } catch (err) {
      this.logger.error(`Failed to route mesh payload: ${err.message}`);
    }

    return {
      status: 'ingested',
      packetId: packet.packetId,
      receivedAt: new Date().toISOString(),
    };
  }

  async getMeshStats() {
    try {
      const countRes = await this.db.query(
        `SELECT COUNT(*) as total_packets, AVG(current_hop) as avg_hops FROM mesh_packet_logs;`,
      );
      const recentRes = await this.db.query(
        `SELECT * FROM mesh_packet_logs ORDER BY received_at DESC LIMIT 10;`,
      );
      return {
        stats: countRes.rows[0],
        recentPackets: recentRes.rows,
      };
    } catch (err) {
      return { stats: { total_packets: 0, avg_hops: 0 }, recentPackets: [] };
    }
  }
}
