import { IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreateReportDto {
  @IsString()
  type: string;

  @IsString()
  location: string;

  @IsString()
  description: string;

  @IsBoolean()
  isAnonymous: boolean;

  @IsOptional()
  @IsString()
  evidenceUrl?: string;
}