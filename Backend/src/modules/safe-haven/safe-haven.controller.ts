import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { SafeHavenService, SafeHavenDto } from './safe-haven.service';

@Controller('safe-havens')
export class SafeHavenController {
  constructor(private readonly safeHavenService: SafeHavenService) {}

  @Post()
  async registerSafeHaven(@Body() dto: SafeHavenDto) {
    return this.safeHavenService.createOrUpdate(dto);
  }

  @Get()
  async getAllSafeHavens() {
    return this.safeHavenService.findAll();
  }

  @Get('nearest')
  async getNearestSafeHaven(@Query('lat') lat: string, @Query('lon') lon: string) {
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lon);
    return this.safeHavenService.findNearest(latitude, longitude);
  }
}
