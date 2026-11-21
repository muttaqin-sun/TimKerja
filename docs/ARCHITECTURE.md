# Arsitektur Aplikasi — TimKerja

Dokumen ini menjelaskan struktur arsitektur kode Flutter pada proyek **TimKerja**, pola pengelolaan *state*, alur komunikasi dengan backend Supabase, serta mekanisme sinkronisasi data *real-time* dan pengelolaan berkas.

---

## 1. Gambaran Umum Pola Arsitektur

**TimKerja** menerapkan pendekatan **Layered Architecture (3 Lapis)** yang dipadukan dengan **Centralized Reactive State Management** menggunakan `ChangeNotifier` bawaan Flutter:

```text
┌─────────────────────────────────────────────────────────────────┐
│                    1. PRESENTATION LAYER (UI)                   │
│   screens/ (BoardScreen, TaskDetailScreen, BoardChatScreen...)  │
│   widgets/ (AttachmentViewer, KanbanPreview, CustomTextField)   │
│   theme/   (AppColors, AppTextStyles, AppRadius, AppSpacing)    │
└───────────────────────────────┬─────────────────────────────────┘
                                │ ListenableBuilder / Action Calls
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                 2. STATE & DOMAIN LAYER (MEMORY)                │
│   data/app_data.dart  ──► AppDataController (ChangeNotifier)    │
│   models/             ──► BoardModel, TaskModel, Notification   │
└───────────────────────────────┬─────────────────────────────────┘
                                │ Async Service Calls
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│               3. SERVICE & INFRASTRUCTURE LAYER                 │
│   services/  ──► AuthService, ProfileService, BoardService,     │
│                  TaskService, PdfReportService                  │
│   main.dart  ──► Global SupabaseClient & Realtime Channels      │
└───────────────────────────────┬─────────────────────────────────┘
                                │ HTTPS / WebSocket (WSS)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SUPABASE BACKEND                          │
│   PostgreSQL DB  │  Supabase Auth  │  Realtime  │  Storage      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Pembagian Tanggung Jawab Tiap Lapisan

### A. Presentation Layer (`lib/screens/`, `lib/widgets/`, `lib/theme/`)
Lapisan ini hanya bertugas merender antarmuka dan menangkap interaksi pengguna tanpa menulis *query* database secara langsung:
* **Screens (`lib/screens/`)**: Terbagi menjadi alur autentikasi (`splash_screen.dart`, `sign_in_screen.dart`, `sign_up_screen.dart`), navigasi utama 4 tab (`home_tab.dart`, `tasks_tab.dart`, `notifications_tab.dart`, `profile_tab.dart`), ruang kerja kolaborasi (`board_screen.dart`, `task_detail_screen.dart`, `board_chat_screen.dart`), serta sub-modul pengaturan di `board_settings/` dan `settings/`.
* **Widgets (`lib/widgets/`)**: Komponen antarmuka yang dapat digunakan ulang, termasuk `AttachmentViewer` untuk pratinjau gambar layar penuh (*pinch-to-zoom*) dan modal unduhan dokumen.
* **Theme (`lib/theme/app_theme.dart`)**: Satu sumber kebenaran (*single source of truth*) untuk palet warna (`AppColors`), gaya tipografi (`AppTextStyles`), sudut lengkung (`AppRadius`), dan jarak tata letak (`AppSpacing`).

### B. State Management Layer (`lib/data/app_data.dart`)
Seluruh *state* sesi pengguna, daftar *board*, daftar *task*, aktivitas, dan notifikasi disimpan di dalam singleton **`AppDataController.instance`**:
* **Reaktivitas UI**: Halaman seperti `BoardScreen`, `TaskDetailScreen`, `HomeTab`, dan `TasksTab` membungkus pohon widget-nya dengan `ListenableBuilder(listenable: AppDataController.instance, ...)`. Setiap pemanggilan `notifyListeners()` otomatis merender ulang UI terkait.
* **Konsistensi Tipe Data**: Koleksi utama dideklarasikan secara eksplisit sebagai `List<Map<String, dynamic>>` (`boards` dan `tasks`), serta setiap pencarian `.firstWhere()` menggunakan `orElse: () => <String, dynamic>{}` untuk mencegah *runtime type error* pada Dart.
* **Strategi Pembaruan Data**:
  * *Optimistic Update*: Digunakan pada interaksi cepat seperti mencentang *subtask*, memindahkan kartu (*drag-and-drop*), atau mengunci *list* agar UI terasa instan sebelum *request* jaringan selesai.
  * *Verified Update*: Digunakan pada operasi destruktif atau bergantung pada ID database seperti menghapus *list* (`deleteBoardList`), membuat *task* baru (`addTask`), dan mengunggah lampiran (`uploadTaskFileAttachment`), di mana UI menunggu konfirmasi sukses dari Supabase terlebih dahulu.

### C. Service & Backend Layer (`lib/services/`)
Setiap domain data diisolasi ke dalam kelas layanan statis yang berkomunikasi dengan klien global `supabase` dari `lib/main.dart`:

| File Service | Tanggung Jawab Utama |
| :--- | :--- |
| `auth_service.dart` | Registrasi akun, login email/kata sandi, logout, dan pengecekan status sesi autentikasi. |
| `profile_service.dart` | Membaca dan memperbarui data profil pengguna pada tabel `profiles` (nama, warna avatar, foto profil, dan peran). |
| `board_service.dart` | Operasi CRUD tabel `boards`, pembuatan kode undangan unik, proses bergabung via kode, keluar dari *board*, dan pengambilan daftar anggota (`board_members`). |
| `task_service.dart` | Operasi CRUD untuk `board_lists`, `tasks`, `subtasks`, `task_comments`, serta unggah dan hapus berkas lampiran pada *bucket* Storage dan tabel `task_attachments`. |
| `pdf_report_service.dart` | Mengolah data *board* dan *task* menjadi dokumen ringkasan laporan berformat PDF. |

---

## 3. Alur Sinkronisasi Supabase Realtime

Agar perubahan dari satu anggota tim langsung muncul di layar anggota lain tanpa perlu keluar ke halaman *Home* atau melakukan *refresh* manual, aplikasi menggunakan saluran WebSocket `RealtimeChannel`:

```text
User A (Menambah/Geser List atau Task)
   │
   ▼
Supabase PostgreSQL (INSERT / UPDATE / DELETE)
   │
   ▼ (Broadcast via publication: supabase_realtime)
RealtimeChannel ('public:board_<boardId>') di BoardScreen User B
   │
   ▼ (Trigger callback onPostgresChanges)
AppDataController.instance.loadTasksForBoard(boardId)
   │
   ▼ (Fetch ulang board_lists & tasks terbaru + notifyListeners())
UI Kanban User B otomatis ter-render ulang
```

* **Siklus Hidup Channel**: Subscription dipasang di dalam `initState()` layar aktif (seperti `BoardScreen` dan `BoardChatScreen`) menggunakan filter `board_id`, dan wajib dilepas melalui `supabase.removeChannel(...)` di dalam `dispose()` untuk mencegah kebocoran memori (*memory leak*).

---

## 4. Arsitektur Pengelolaan Berkas & Lampiran

Alur unggah dan pratinjau lampiran pada `TaskDetailScreen` memisahkan penyimpanan fisik berkas dengan metadata database serta membedakan direktori lokal saat berkas dibuka vs diunduh permanen:

1. **Alur Unggah (`Upload`)**:
   * Pengguna memilih sumber lampiran: **Kamera** (`image_picker`), **File Lokal** (`file_picker`), **Clipboard**, atau **Tautan URL**.
   * Untuk foto/file fisik, `TaskService.uploadAndAttachFile()` mengunggah berkas ke *bucket* publik **`task-attachments`** di Supabase Storage dengan jalur `<taskId>/<timestamp>.<ext>`, mengambil *Public URL*-nya, lalu mencatat metadata (`name`, `url`, `type`) ke tabel PostgreSQL `task_attachments`.
2. **Alur Pratinjau & Unduhan (`AttachmentViewer`)**:
   * **Gambar (`type == 'image'`)**: Dibuka dalam layar penuh (`_FullScreenImagePage`) dengan dukungan *pinch-to-zoom* (`InteractiveViewer`) dan tombol unduh langsung.
   * **Dokumen (`type == 'file'`)**: Membuka *bottom sheet* informasi berkas dengan dua opsi unduhan menggunakan `Dio`:
     * **Buka File**: Mengunduh berkas ke direktori *cache* sementara (`getTemporaryDirectory()`) lalu langsung membukanya via `open_filex` agar folder publik perangkat tidak penuh oleh pratinjau sementara.
     * **Download**: Mengunduh dan menyimpan berkas secara permanen ke direktori publik `/storage/emulated/0/Download` (Android) atau `getApplicationDocumentsDirectory()`.
   * **Tautan (`type == 'link'`)**: Menyalin URL langsung ke *clipboard* perangkat.