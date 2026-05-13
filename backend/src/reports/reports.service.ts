import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateReportDto } from './dto/create-report.dto';

@Injectable()
export class ReportsService {
  constructor(private supabase: SupabaseService) {}

  async createReport(userId: string, dto: CreateReportDto) {
    const db = this.supabase.getClient();

    console.log('=== CREATE REPORT ===');
    console.log('User ID:', userId);
    console.log('DTO:', JSON.stringify(dto));

    const { data, error } = await db.from('reports').insert({
      user_id: dto.isAnonymous ? null : userId,
      type: dto.type,
      location: dto.location,
      description: dto.description,
      is_anonymous: dto.isAnonymous,
      evidence_url: dto.evidenceUrl ?? null,
      source: 'Form Laporan',
      status: 'Belum Ditangani',
    }).select().single();

    console.log('Create report error:', JSON.stringify(error));
    console.log('Create report result:', JSON.stringify(data));

    if (error) throw new Error(error.message);
    return data;
  }

  async getUserReports(userId: string) {
    const db = this.supabase.getClient();

    console.log('=== GET USER REPORTS ===');
    console.log('User ID:', userId);

    // Ambil semua laporan milik user ini (form laporan + panic button)
    const { data, error } = await db
      .from('reports')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    console.log('Get reports error:', JSON.stringify(error));
    console.log('Get reports count:', data?.length);

    if (error) throw new Error(error.message);
    return data ?? [];
  }

  async getAllReports() {
    const db = this.supabase.getClient();
    const { data, error } = await db
      .from('reports')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data ?? [];
  }

  async updateStatus(reportId: string, status: string) {
    const db = this.supabase.getClient();
    const { data, error } = await db
      .from('reports')
      .update({ status })
      .eq('id', reportId)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async deleteReport(reportId: string) {
    const db = this.supabase.getClient();
    const { error } = await db.from('reports').delete().eq('id', reportId);
    if (error) throw new Error(error.message);
    return { message: 'Laporan dihapus' };
  }
}