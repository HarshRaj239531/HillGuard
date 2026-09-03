import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('HillGuard-Bootstrap');
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  });

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');

  logger.log(`===================================================`);
  logger.log(`🛡️ HillGuard PostGIS & Mesh Gateway online on port ${port}`);
  logger.log(`📡 Landslide Hazard API:   http://localhost:${port}/api/reports/landslide`);
  logger.log(`🛣️ Road Condition Mesh API: http://localhost:${port}/api/reports/road`);
  logger.log(`📍 Nearby ST_DWithin:       http://localhost:${port}/api/reports/road/nearby`);
  logger.log(`⚡ Mesh Ingest Gateway:     http://localhost:${port}/api/mesh/ingest`);
  logger.log(`===================================================`);
}
bootstrap();
