import { Module } from '@nestjs/common';
import { RoadController } from './road.controller';
import { RoadService } from './road.service';

@Module({
  controllers: [RoadController],
  providers: [RoadService],
  exports: [RoadService],
})
export class RoadModule {}
