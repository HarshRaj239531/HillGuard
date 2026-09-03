import { Module } from '@nestjs/common';
import { SafeHavenController } from './safe-haven.controller';
import { SafeHavenService } from './safe-haven.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [SafeHavenController],
  providers: [SafeHavenService],
  exports: [SafeHavenService],
})
export class SafeHavenModule {}
