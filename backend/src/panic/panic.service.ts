import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import axios from 'axios';

@Injectable()
export class PanicService {
  constructor(private supabase: SupabaseService) {}

  async triggerPanic(userId: string, latitude: number, longitude: number) {
    const db = this.supabase.getClient();

    console.log('=== PANIC TRIGGERED ===');
    console.log('User ID:', userId);
    console.log('Lat:', latitude, 'Lng:', longitude);

    // Reverse geocode pakai Nominatim (OpenStreetMap) — gratis
    let locationName = `${latitude}, ${longitude}`;
    try {
      const geoRes = await axios.get(
        `https://nominatim.openstreetmap.org/reverse?lat=${latitude}&lon=${longitude}&format=json`,
        { headers: { 'User-Agent': 'SecureMeApp/1.0' } },
      );
      locationName = geoRes.data.display_name ?? locationName;
      console.log('Location name:', locationName);
    } catch (geoErr) {
      console.log('Geocoding gagal, pakai koordinat:', String(geoErr));
    }

    const { data: report, error } = await db.from('reports').insert({
      user_id: userId,
      type: 'Darurat',
      location: locationName,
      latitude,
      longitude,
      description: 'Pengguna menekan tombol PANIK dan membutuhkan bantuan segera.',
      is_anonymous: false,
      source: 'Panic Button',
      status: 'Belum Ditangani',
    }).select().single();

    console.log('Insert report error:', JSON.stringify(error));
    console.log('Insert report result:', JSON.stringify(report));

    if (error) throw new Error(error.message);

    await db.from('location_tracking').insert({
      user_id: userId,
      report_id: report.id,
      latitude,
      longitude,
    });

    return {
      message: 'Sinyal darurat berhasil dikirim',
      report,
      locationName,
    };
  }

  async updateLocation(userId: string, reportId: string, latitude: number, longitude: number) {
    const db = this.supabase.getClient();
    await db.from('location_tracking').insert({
      user_id: userId,
      report_id: reportId,
      latitude,
      longitude,
    });
    return { message: 'Lokasi diperbarui' };
  }
}