import { Injectable, UnauthorizedException, ConflictException, InternalServerErrorException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { SupabaseService } from '../supabase/supabase.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private supabase: SupabaseService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const db = this.supabase.getClient();

    console.log('=== REGISTER ATTEMPT ===');
    console.log('Email:', dto.email);

    const { data: authData, error: authError } = await db.auth.signUp({
      email: dto.email,
      password: dto.password,
    });

    console.log('Supabase signUp result:', JSON.stringify(authData));
    console.log('Supabase signUp error:', JSON.stringify(authError));

    if (authError) throw new ConflictException(authError.message);
    if (!authData.user) throw new ConflictException('Registrasi gagal, user null');

    console.log('User ID:', authData.user.id);

    const { error: insertError } = await db.from('users').insert({
      id: authData.user.id,
      full_name: dto.fullName,
      email: dto.email,
      phone: dto.phone,
    });

    console.log('Insert error:', JSON.stringify(insertError));

    if (insertError) {
      console.error('Insert to users table failed:', insertError.message);
      // Tetap return success karena auth sudah berhasil
    }

    return { message: 'Registrasi berhasil' };
  }

  async login(dto: LoginDto) {
    const db = this.supabase.getClient();

    console.log('=== LOGIN ATTEMPT ===');
    console.log('Email:', dto.email);

    const { data, error } = await db.auth.signInWithPassword({
      email: dto.email,
      password: dto.password,
    });

    console.log('Login error:', JSON.stringify(error));

    if (error) throw new UnauthorizedException('Email atau password salah');

    const { data: userData, error: userError } = await db
      .from('users')
      .select('*')
      .eq('id', data.user.id)
      .single();

    console.log('User data:', JSON.stringify(userData));
    console.log('User fetch error:', JSON.stringify(userError));

    const secret = this.configService.get<string>('JWT_SECRET')
      ?? 'secureme_secret_key';

    const token = this.jwtService.sign(
      { sub: data.user.id, email: data.user.email },
      { secret },
    );

    return { token, user: userData };
  }
}