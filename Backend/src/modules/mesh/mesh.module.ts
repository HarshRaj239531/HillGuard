import { Module } from '@nestjs/common';
import { MeshController } from './mesh.controller';
import { MeshService } from './mesh.service';
import { LandslideModule } from '../landslide/landslide.module';
import { RoadModule } from '../road/road.module';

@Module({
  imports: [LandslideModule, RoadModule],
  controllers: [MeshController],
  providers: [MeshService],
  exports: [MeshService],
})
export class MeshModule {}
