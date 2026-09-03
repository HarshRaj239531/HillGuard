import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { DatabaseModule } from './database/database.module';
import { LandslideModule } from './modules/landslide/landslide.module';
import { RoadModule } from './modules/road/road.module';
import { MeshModule } from './modules/mesh/mesh.module';
import { AlertsModule } from './modules/alerts/alerts.module';

@Module({
  imports: [
    DatabaseModule,
    LandslideModule,
    RoadModule,
    MeshModule,
    AlertsModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
