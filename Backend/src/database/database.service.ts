import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { Pool, QueryResult, QueryResultRow } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(DatabaseService.name);
  private pool: Pool;

  async OnModuleInit() {
    await this.onModuleInit();
  }

  async onModuleInit() {
    const connectionString =
      process.env.DATABASE_URL ||
      'postgresql://hillguard:hillguard_secure_pwd@localhost:5432/hillguard_db';

    this.logger.log(`Initializing PostGIS connection pool...`);
    this.pool = new Pool({
      connectionString,
      max: 15,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    });

    try {
      const client = await this.pool.connect();
      const res = await client.query('SELECT postgis_full_version();');
      client.release();
      this.logger.log(`PostGIS database online: ${res.rows[0].postgis_full_version}`);
    } catch (err) {
      this.logger.warn(`Initial database connection note: ${err.message}. Retrying on query.`);
    }
  }

  async onModuleDestroy() {
    if (this.pool) {
      await this.pool.end();
    }
  }

  async query<T extends QueryResultRow = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    return this.pool.query<T>(text, params);
  }
}
