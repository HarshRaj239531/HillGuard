import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { RoadService, RoadDto } from './road.service';

@Controller('reports/road')
export class RoadController {
  constructor(private readonly roadService: RoadService) {}

  @Post()
  async createReport(@Body() dto: RoadDto) {
    return this.roadService.createOrUpdate(dto);
  }

  @Get()
  async getAllReports(@Query('limit') limit?: string) {
    const lim = limit ? parseInt(limit, 10) : 50;
    return this.roadService.findAll(lim);
  }

  @Get('nearby')
  async getNearbyReports(
    @Query('lat') lat: string,
    @Query('lon') lon: string,
    @Query('radius') radius?: string,
  ) {
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lon);
    const radiusMeters = radius ? parseFloat(radius) : 10000;
    return this.roadService.findNearby(latitude, longitude, radiusMeters);
  }
}
