import { Controller, Post, Get, Body } from '@nestjs/common';
import { MeshService, MeshPacketDto } from './mesh.service';

@Controller('mesh')
export class MeshController {
  constructor(private readonly meshService: MeshService) {}

  @Post('ingest')
  async ingestPacket(@Body() packet: MeshPacketDto) {
    return this.meshService.ingestPacket(packet);
  }

  @Get('stats')
  async getMeshStats() {
    return this.meshService.getMeshStats();
  }
}
