import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { CreateReportDto } from './dto/create-report.dto';
import { JwtGuard } from '../common/jwt.guard';

@Controller('reports')
@UseGuards(JwtGuard)
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Post()
  create(@Request() req, @Body() dto: CreateReportDto) {
    return this.reportsService.createReport(req.user.sub, dto);
  }

  @Get('my')
  getMyReports(@Request() req) {
    return this.reportsService.getUserReports(req.user.sub);
  }

  @Get('all')
  getAllReports() {
    return this.reportsService.getAllReports();
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.reportsService.updateStatus(id, status);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.reportsService.deleteReport(id);
  }
}