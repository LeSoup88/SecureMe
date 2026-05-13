import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { PanicService } from './panic.service';
import { JwtGuard } from '../common/jwt.guard';

@Controller('panic')
@UseGuards(JwtGuard)
export class PanicController {
  constructor(private panicService: PanicService) {}

  @Post('trigger')
  trigger(
    @Request() req,
    @Body('latitude') latitude: number,
    @Body('longitude') longitude: number,
  ) {
    return this.panicService.triggerPanic(req.user.sub, latitude, longitude);
  }

  @Post('update-location')
  updateLocation(
    @Request() req,
    @Body('reportId') reportId: string,
    @Body('latitude') latitude: number,
    @Body('longitude') longitude: number,
  ) {
    return this.panicService.updateLocation(req.user.sub, reportId, latitude, longitude);
  }
}