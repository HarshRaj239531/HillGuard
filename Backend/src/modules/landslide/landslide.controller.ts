import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { LandslideService, LandslideDto } from './landslide.service';

@Controller('reports/landslide')
export class LandslideController {
  constructor(private readonly landslideService: LandslideService) {}

  @Post()
  async createReport(@Body() dto: LandslideDto) {
    return this.landslideService.createOrUpdate(dto);
  }

  @Get()
  async getAllReports(@Query('limit') limit?: string) {
    const lim = limit ? parseInt(limit, 10) : 50;
    return this.landslideService.findAll(lim);
  }

  @Get('clusters')
  async getClusters() {
    return this.landslideService.getClusters();
  }
}
