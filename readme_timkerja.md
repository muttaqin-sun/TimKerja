# TimKerja

**TimKerja** adalah aplikasi manajemen proyek dan kolaborasi tim berbasis Kanban yang dibangun menggunakan **Flutter** dan **Supabase**. Aplikasi ini dirancang untuk mempermudah pengelolaan papan proyek (*board*), pembagian kolom kerja (*list*), pelacakan tugas (*task*) secara *real-time*, diskusi tim, serta pengelolaan berkas lampiran.

---

## Fitur Utama & Status Pengembangan

| Modul | Status | Deskripsi Fungsional |
| :--- | :---: | :--- |
| **Autentikasi & Profil** | Selesai | Registrasi, login email/kata sandi, pembaruan profil pengguna, inisial avatar otomatis, dan manajemen sesi. |
| **Manajemen Board** | Selesai | Pembuatan *board* dengan warna & privasi, pembangkitan kode unik *board*, bergabung ke *board* via kode, pengaturan *board*, serta manajemen anggota. |
| **Kanban Board & Realtime** | Selesai | Pembuatan, pengubahan nama, penguncian (*lock*), pengurutan, dan penghapusan kolom *list*; pemindahan *task* antar kolom (*drag-and-drop*) yang tersinkronisasi secara *real-time* via Supabase Realtime. |
| **Detail Task & Lampiran** | Selesai | Kustomisasi warna/ukuran *cover*, status selesai, deskripsi, *start date* & *due date* + pengingat, *checklist* subtask otomatis, komentar, serta lampiran (kamera, unggah file ke Supabase Storage, *clipboard*, dan tautan URL) lengkap dengan pratinjau layar penuh & unduhan lokal. |
| **Diskusi / Board Chat** | Integrasi | Ruang obrolan khusus per *board* menggunakan kanal Supabase Realtime. |
| **Polling & Voting** | Dalam Rencana | Pembuatan jajak pendapat dan pemungutan suara anggota *board* secara langsung. |
| **Notifikasi & Laporan PDF** | Dalam Rencana | Pusat notifikasi aktivitas *real-time* dan ekspor ringkasan progres *board* ke format PDF. |

---

## Teknologi & Package Utama

* **Framework UI:** Flutter (Dart SDK)
* **Backend & Database:** Supabase (PostgreSQL, Auth, Realtime, Storage)
* **Package Terpasang:**
  * `supabase_flutter` — Klien utama untuk autentikasi, *query* database, *storage*, dan *realtime listener*.
  * `image_picker` — Pengambilan foto langsung dari kamera perangkat untuk lampiran *task*.
  * `file_picker` — Pemilihan dokumen/berkas lokal untuk diunggah ke Supabase Storage.
  * `dio` — Pengunduhan berkas lampiran dengan pelacakan progres (*byte progress*).
  * `path_provider` — Akses direktori *cache* sementara dan folder penyimpanan perangkat.
  * `open_filex` — Membuka berkas unduhan (PDF, dokumen, gambar) menggunakan aplikasi penampil bawaan perangkat.
  * `percent_indicator` — Komponen indikator progres melingkar (`0% – 100%`) untuk proses unggah berkas.

---

## Struktur Direktori Proyek

```text
lib/
├── main.dart                     # Titik masuk aplikasi & inisialisasi Supabase
├── data/
│   └── app_data.dart             # State management terpusat (AppDataController)
├── models/
│   ├── board_model.dart          # Model data board
│   ├── notification_model.dart   # Model data notifikasi
│   └── task_model.dart           # Model data task
├── services/
│   ├── auth_service.dart         # Layanan autentikasi pengguna
│   ├── profile_service.dart      # Layanan baca/ubah profil
│   ├── board_service.dart        # Layanan CRUD board & keanggotaan
│   ├── task_service.dart         # Layanan CRUD list, task, subtask, komentar & storage
│   └── pdf_report_service.dart   # Layanan pembuatan laporan PDF
├── screens/
│   ├── splash_screen.dart        # Layar pembuka & pengecekan sesi login
│   ├── sign_in_screen.dart       # Halaman masuk
│   ├── sign_up_screen.dart       # Halaman pendaftaran
│   ├── main_navigation_screen.dart # Navigasi bawah utama
│   ├── home_tab.dart             # Ringkasan board & tugas hari ini
│   ├── tasks_tab.dart            # Daftar seluruh tugas pengguna lintas board
│   ├── notifications_tab.dart    # Pusat notifikasi
│   ├── profile_tab.dart          # Profil & menu pengaturan akun
│   ├── create_board_screen.dart  # Form pembuatan board baru
│   ├── board_screen.dart         # Papan Kanban utama (Realtime)
│   ├── board_chat_screen.dart    # Halaman chat internal board
│   ├── task_detail_screen.dart   # Halaman detail lengkap tugas
│   ├── board_settings/           # Pengaturan board (general, lists, members, polling, files, reports)
│   └── settings/                 # Pengaturan akun, tampilan, bantuan, & tentang aplikasi
├── theme/
│   └── app_theme.dart            # Definisi warna, tipografi, radius, dan spasi global
└── widgets/
    ├── attachment_viewer.dart    # Full-screen image viewer & modal unduh dokumen
    └── ...                       # Komponen UI reusable lainnya
```

---

## Panduan Instalasi & Menjalankan Proyek

### 1. Prasyarat
* Flutter SDK (disarankan versi stabil terbaru)
* Akun dan proyek aktif di [Supabase](https://supabase.com)
* Android Studio / VS Code dengan perangkat fisik atau emulator

### 2. Konfigurasi Lokal
1. **Clone repositori dan pindah ke branch integrasi:**
   ```bash
   git clone https://github.com/muttaqin-sun/TimKerja.git
   cd TimKerja
   git checkout develop
   ```
2. **Pasang seluruh dependensi Flutter:**
   ```bash
   flutter pub get
   ```
3. **Konfigurasi Kredensial Supabase:**
   Pastikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` pada inisialisasi di `lib/main.dart` telah disesuaikan dengan kredensial proyek Supabase milikmu.
4. **Siapkan Skema Database & Storage:**
   Jalankan skrip tabel, *Row Level Security (RLS)*, publikasi *Realtime*, serta buat *bucket* publik `task-attachments` di **SQL Editor** Supabase (detail lengkap tersedia di [`docs/DATABASE_SUPABASE.md`](docs/DATABASE_SUPABASE.md)).
5. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---

## Dokumentasi Teknis Terkait

Dokumentasi proyek dipisahkan berdasarkan perannya di dalam folder `docs/`:
1. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — Arsitektur lapisan UI, *state management*, dan *service*.
2. [`docs/DATABASE_SUPABASE.md`](docs/DATABASE_SUPABASE.md) — Skema tabel PostgreSQL, *policy* RLS, Storage, dan Realtime.
3. [`docs/MODULES_SPEC.md`](docs/MODULES_SPEC.md) — Spesifikasi alur kerja setiap fitur aplikasi.
4. [`docs/GIT_WORKFLOW.md`](docs/GIT_WORKFLOW.md) — Aturan *branching* Git Flow (`main`, `develop`, `feature/*`).
5. [`docs/ROADMAP_CHANGELOG.md`](docs/ROADMAP_CHANGELOG.md) — Peta jalan pengembangan dan catatan riwayat perbaikan.