# SecureMe

**Aplikasi Mobile Perlindungan dan Pelaporan Kekerasan**

SecureMe adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu korban atau saksi kekerasan fisik, seksual, maupun kekerasan dalam rumah tangga (KDRT) agar dapat melaporkan kejadian secara cepat, aman, dan mudah. Aplikasi ini dilengkapi dengan fitur Panic Button yang dapat mengirimkan lokasi GPS pengguna secara real-time kepada pihak berwajib, serta dashboard admin untuk memantau dan mengelola laporan yang masuk.

---

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Cara Instalasi dan Menjalankan](#cara-instalasi-dan-menjalankan)
- [Konfigurasi Database Supabase](#konfigurasi-database-supabase)
- [Konfigurasi CI/CD](#konfigurasi-cicd)
- [Penggunaan Aplikasi](#penggunaan-aplikasi)
- [API Endpoints](#api-endpoints)
- [Kontribusi](#kontribusi)

---

## Fitur Utama

### Untuk Pengguna
- **Panic Button** — Tombol darurat yang mengirimkan sinyal beserta lokasi GPS pengguna secara real-time ke database. Lokasi dikonversi menjadi nama alamat lengkap menggunakan Nominatim API (OpenStreetMap) tanpa memerlukan API key berbayar.
- **Form Laporan** — Formulir pelaporan kejadian kekerasan yang mencakup jenis kekerasan, lokasi kejadian, deskripsi, lampiran bukti berupa foto atau video, serta opsi pengiriman secara anonim.
- **Riwayat Laporan** — Halaman yang menampilkan seluruh laporan yang pernah dibuat beserta status penanganannya secara real-time.
- **Pusat Edukasi** — Konten informatif mengenai jenis-jenis kekerasan, langkah hukum yang dapat ditempuh, layanan konseling gratis, dan hak-hak korban berdasarkan perundang-undangan Indonesia.
- **Kontak Darurat** — Daftar nomor kontak penting seperti Polisi (110), Ambulans (118), Komnas Perempuan, LBH APIK, dan SAPA Indonesia yang dapat dihubungi kapan saja.

### Untuk Admin
- **Dashboard Admin** — Halaman pemantauan seluruh laporan dari semua pengguna yang dilengkapi dengan statistik jumlah laporan per status.
- **Filter Laporan** — Kemampuan memfilter laporan berdasarkan status penanganan: Belum Ditangani, Sedang Ditangani, dan Sudah Ditangani.
- **Detail Laporan** — Tampilan detail lengkap setiap laporan termasuk jenis kekerasan, lokasi, identitas pelapor, dan deskripsi kejadian.
- **Update Status** — Admin dapat memperbarui status penanganan setiap laporan secara langsung dari aplikasi.
- **Login Admin** — Sistem autentikasi khusus admin yang terpisah dari pengguna biasa. Akun admin hanya dapat dibuat melalui query database Supabase.

---

## Teknologi yang Digunakan

### Frontend
| Teknologi | Versi | Kegunaan |
|---|---|---|
| Flutter | 3.22.0+ | Framework utama aplikasi mobile dan web |
| Dart | 3.0.0+ | Bahasa pemrograman frontend |
| Supabase Flutter | 2.3.0+ | Koneksi langsung ke database Supabase |
| Geolocator | 11.0.0+ | Mengambil koordinat GPS perangkat |
| HTTP | 1.2.0+ | HTTP request untuk reverse geocoding |
| Image Picker | 1.1.2+ | Memilih foto/video dari galeri |
| Shared Preferences | 2.2.2+ | Menyimpan session ID pengguna secara lokal |
| Flutter Secure Storage | 9.0.0+ | Menyimpan token autentikasi secara aman |

### Backend
| Teknologi | Versi | Kegunaan |
|---|---|---|
| NestJS | 10.0+ | Framework backend REST API |
| TypeScript | 5.0+ | Bahasa pemrograman backend |
| Supabase JS | 2.39.0+ | Koneksi backend ke database |
| JWT | — | Autentikasi dan otorisasi |
| Axios | 1.6.0+ | HTTP request untuk reverse geocoding |
| Class Validator | 0.14.0+ | Validasi input data |

### Database & Infrastructure
| Teknologi | Kegunaan |
|---|---|
| Supabase (PostgreSQL) | Database utama aplikasi berbasis cloud |
| GitHub Actions | CI/CD pipeline otomatis |
| GitHub Pages | Hosting Flutter Web |
| Nominatim API | Reverse geocoding gratis berbasis OpenStreetMap |

---

## Struktur Proyek

```
secureme/
├── .github/
│   └── workflows/
│       ├── backend.yml          # CI/CD pipeline backend
│       └── frontend.yml         # CI/CD pipeline frontend
│
├── frontend/                    # Flutter Application
│   ├── pubspec.yaml
│   ├── android/
│   │   └── app/
│   │       └── build.gradle.kts
│   ├── assets/
│   │   └── images/
│   │       └── logo.png         # Logo aplikasi (tambahkan sendiri)
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── core/
│       │   ├── constants/
│       │   │   ├── app_colors.dart
│       │   │   └── app_strings.dart
│       │   ├── services/
│       │   │   ├── supabase_service.dart
│       │   │   ├── location_service.dart
│       │   │   └── api_service.dart
│       │   └── utils/
│       │       └── validators.dart
│       ├── features/
│       │   ├── portal/
│       │   │   └── portal_page.dart
│       │   ├── admin/
│       │   │   ├── admin_login_page.dart
│       │   │   └── admin_home_page.dart
│       │   ├── panic/
│       │   │   └── panic_page.dart
│       │   ├── report/
│       │   │   ├── report_page.dart
│       │   │   └── history_page.dart
│       │   ├── education/
│       │   │   └── education_page.dart
│       │   ├── contacts/
│       │   │   └── contacts_page.dart
│       │   └── home/
│       │       └── home_shell.dart
│       └── widgets/
│           ├── custom_button.dart
│           └── status_badge.dart
│
└── backend/                     # NestJS Application
    ├── package.json
    ├── tsconfig.json
    ├── Procfile
    ├── .env.example
    └── src/
        ├── main.ts
        ├── app.module.ts
        ├── supabase/
        │   ├── supabase.module.ts
        │   └── supabase.service.ts
        ├── auth/
        │   ├── auth.module.ts
        │   ├── auth.controller.ts
        │   ├── auth.service.ts
        │   └── dto/
        │       ├── login.dto.ts
        │       └── register.dto.ts
        ├── reports/
        │   ├── reports.module.ts
        │   ├── reports.controller.ts
        │   ├── reports.service.ts
        │   └── dto/
        │       └── create-report.dto.ts
        ├── panic/
        │   ├── panic.module.ts
        │   ├── panic.controller.ts
        │   └── panic.service.ts
        └── common/
            └── jwt.guard.ts
```

---

## Prasyarat

Pastikan perangkat pengembangan kamu telah menginstal:

- **Flutter SDK** versi 3.22.0 atau lebih baru → [flutter.dev](https://flutter.dev)
- **Node.js** versi 20 atau lebih baru → [nodejs.org](https://nodejs.org)
- **Git** → [git-scm.com](https://git-scm.com)
- **Android Studio** atau **VS Code** dengan ekstensi Flutter
- Akun **Supabase** → [supabase.com](https://supabase.com)

---

## Cara Instalasi dan Menjalankan

### 1. Clone Repository

```bash
git clone https://github.com/USERNAME/SecureMe.git
cd SecureMe
```

### 2. Setup Backend

```bash
cd backend
npm install
cp .env.example .env
```

Isi file `.env` dengan nilai yang sesuai:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
JWT_SECRET=your-random-secret-key-min-32-chars
PORT=3000
```

Jalankan backend:

```bash
npm run start:dev
```

Backend akan berjalan di `http://localhost:3000`

### 3. Setup Frontend

```bash
cd frontend
flutter pub get
```

Buka file `lib/main.dart` dan isi dengan kredensial Supabase kamu:

```dart
await Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-public-key',
);
```

Jalankan aplikasi:

```bash
# Untuk menjalankan di emulator atau device fisik
flutter run

# Untuk menjalankan di browser (web)
flutter run -d chrome

# Untuk build APK
flutter build apk --release --split-per-abi
```

---

## Konfigurasi Database Supabase

### 1. Buat Project Baru di Supabase

1. Buka [supabase.com](https://supabase.com) dan buat project baru
2. Pergi ke **SQL Editor** dan jalankan script berikut

### 2. Jalankan SQL Setup

```sql
-- Tabel profil user
create table public.users (
  id uuid primary key,
  full_name text not null,
  email text not null,
  phone text,
  created_at timestamp with time zone default now()
);

-- Tabel laporan
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id text,
  type text not null,
  location text not null,
  description text not null,
  is_anonymous boolean default false,
  source text default 'Form Laporan',
  status text default 'Belum Ditangani',
  evidence_url text,
  latitude double precision,
  longitude double precision,
  reported_by text default 'Identitas Terlampir',
  created_at timestamp with time zone default now()
);

-- Tabel tracking lokasi real-time
create table public.location_tracking (
  id uuid primary key default gen_random_uuid(),
  user_id text,
  report_id uuid,
  latitude double precision not null,
  longitude double precision not null,
  recorded_at timestamp with time zone default now()
);

-- Tabel admin
create table public.admins (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  password_hash text not null,
  full_name text not null,
  created_at timestamp with time zone default now()
);

-- Matikan RLS untuk semua tabel
alter table public.users disable row level security;
alter table public.reports disable row level security;
alter table public.location_tracking disable row level security;
alter table public.admins disable row level security;

-- Insert akun admin default
insert into public.admins (email, password_hash, full_name)
values ('admin@secureme.com', 'Admin@123', 'Administrator');
```

### 3. Aktifkan Anonymous Sign-ins

1. Buka **Authentication → Providers**
2. Cari **Anonymous** dan aktifkan toggle **Enable anonymous sign-ins**
3. Klik **Save**

---

## Konfigurasi CI/CD

### GitHub Actions

Repository ini menggunakan GitHub Actions untuk CI/CD otomatis. Setiap push ke branch `master` akan memicu:

1. **Backend pipeline** — Melakukan TypeScript compilation check
2. **Frontend pipeline** — Melakukan Flutter analyze, build APK, dan deploy Flutter Web ke GitHub Pages

### Setup GitHub Secrets

Tambahkan secrets berikut di **GitHub → Settings → Secrets and variables → Actions**:

| Secret | Nilai |
|---|---|
| `SUPABASE_URL` | URL project Supabase kamu |
| `SUPABASE_SERVICE_KEY` | Service role key Supabase |
| `SUPABASE_ANON_KEY` | Anon/public key Supabase |
| `JWT_SECRET` | JWT secret yang sama dengan `.env` |
| `BACKEND_URL` | URL backend yang sudah di-deploy |

### Mengaktifkan GitHub Pages

1. Buka **Settings → Pages**
2. Pilih **Source: Deploy from a branch**
3. Pilih branch **gh-pages** dan folder **/ (root)**
4. Klik **Save**

Aplikasi web akan tersedia di:
```
https://USERNAME.github.io/SecureMe/
```

---

## Penggunaan Aplikasi

### Sebagai Pengguna

**1. Menggunakan Panic Button**
- Buka aplikasi dan pilih **Pengguna** di halaman awal
- Pastikan GPS aktif di perangkat
- Tekan tombol **PANIK** berwarna merah
- Aplikasi akan mengambil koordinat GPS dan mengirimkan sinyal darurat ke database
- Lokasi akan dikonversi menjadi nama alamat lengkap secara otomatis

**2. Membuat Laporan**
- Pilih tab **Lapor** di navigation bar bawah
- Pilih jenis kekerasan yang sesuai
- Isi lokasi kejadian dan deskripsi detail
- Lampirkan bukti foto atau video jika ada
- Aktifkan toggle anonim jika tidak ingin identitas ditampilkan
- Tekan **Kirim Laporan**

**3. Melihat Riwayat Laporan**
- Pilih tab **Riwayat** untuk melihat semua laporan yang pernah dibuat
- Setiap laporan menampilkan status terkini yang diperbarui oleh admin
- Lakukan pull-to-refresh untuk memperbarui data

### Sebagai Admin

**1. Login Admin**
- Pilih **Admin** di halaman awal
- Masukkan email dan password admin
- Email default: `admin@secureme.com`
- Password default: `Admin@123`

**2. Mengelola Laporan**
- Dashboard menampilkan statistik laporan di bagian atas
- Gunakan filter chip untuk menyaring laporan berdasarkan status
- Tekan kartu laporan untuk melihat detail lengkap
- Pilih status baru dan tekan **Simpan Perubahan** untuk memperbarui status

**3. Menambahkan Admin Baru**

Jalankan query berikut di Supabase SQL Editor:

```sql
insert into public.admins (email, password_hash, full_name)
values ('email_baru@domain.com', 'password_baru', 'Nama Admin');
```

---

## API Endpoints

Backend NestJS menyediakan endpoints berikut:

### Authentication
| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/auth/register` | Registrasi pengguna baru |
| POST | `/auth/login` | Login pengguna |

### Reports
| Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| POST | `/reports` | Membuat laporan baru | Required |
| GET | `/reports/my` | Mengambil laporan milik user | Required |
| GET | `/reports/all` | Mengambil semua laporan (admin) | Required |
| PATCH | `/reports/:id/status` | Memperbarui status laporan | Required |
| DELETE | `/reports/:id` | Menghapus laporan | Required |

### Panic
| Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| POST | `/panic/trigger` | Mengirim sinyal darurat + lokasi GPS | Required |
| POST | `/panic/update-location` | Memperbarui lokasi real-time | Required |

### Contoh Request

**Login:**
```json
POST /auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Trigger Panic:**
```json
POST /panic/trigger
Authorization: Bearer <token>
{
  "latitude": -6.21462,
  "longitude": 106.84513
}
```

**Create Report:**
```json
POST /reports
Authorization: Bearer <token>
{
  "type": "Kekerasan Fisik",
  "location": "Halte Bus Blok M",
  "description": "Deskripsi kejadian...",
  "isAnonymous": false
}
```

---

## Menambahkan Logo Aplikasi

Untuk mengganti placeholder logo dengan logo kamu sendiri:

1. Siapkan file gambar logo dalam format `.png`
2. Rename file menjadi `logo.png`
3. Letakkan file di folder `frontend/assets/images/logo.png`
4. Aplikasi akan otomatis menampilkan logo tersebut

---

## Kontak Darurat yang Tersedia

| Nama | Nomor |
|---|---|
| Polisi | 110 |
| Ambulans | 118 |
| Komnas Perempuan | 021-3903963 |
| LBH APIK Jakarta | 021-8779-0146 |
| SAPA Indonesia | 1500-454 |




## Tim Pengembang

**Software Engineering - Kelompok 7**

Stawin Revano-2802437114

Calvin Dywen-2802421002

Nabil Rafif Utomo - 2802435260

Gilbert Nicholin - 2802436925

Williams - 2802438136

---

**Mobile Hybrid Solution**

Stawin Revano-2802437114

Calvin Dywen-2802421002

Nabil Rafif Utomo - 2802435260

Gilbert Nicholin - 2802436925

Nicholas Fellian - 2802429352
