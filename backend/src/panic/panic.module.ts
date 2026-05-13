import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PanicController } from './panic.controller';
import { PanicService } from './panic.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [ConfigModule, AuthModule],
  controllers: [PanicController],
  providers: [PanicService],
})
export class PanicModule {}