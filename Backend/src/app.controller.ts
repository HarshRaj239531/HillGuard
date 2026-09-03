import { Controller, Get } from '@nestjs/common';
import { DatabaseService } from './database/database.service';

@Controller()
export class AppController {
  constructor(private readonly db: DatabaseService) {}

  @Get('health')
  async getHealth() {
    try {
      const res = await this.db.query('SELECT postgis_full_version();');
      return {
        status: 'healthy',
        database: 'connected',
        postgis: res.rows[0]?.postgis_full_version || 'active',
        timestamp: new Date().toISOString(),
        uptimeSeconds: Math.floor(process.uptime()),
      };
    } catch (err) {
      return {
        status: 'degraded',
        database: 'disconnected',
        error: err.message,
        timestamp: new Date().toISOString(),
      };
    }
  }
}
