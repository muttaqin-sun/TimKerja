# Roadmap Pengembangan & Changelog — TimKerja

Dokumen ini mencatat tahapan pengembangan proyek **TimKerja** dari awal inisiasi hingga target rilis produksi, serta merangkum riwayat pembaruan fitur dan perbaikan *bug* teknis yang telah diselesaikan.

## 1. Roadmap Pengembangan Proyek

| Fase | Branch Git | Ruang Lingkup & Target Capaian | Status |
| :--- | :--- | :--- | :--- |
| **Fase 1** | `feature/auth`<br>`feature/profile` | **Fondasi, Autentikasi & Profil:** Inisialisasi proyek Flutter & Supabase, alur *Splash Screen*, registrasi & login email, manajemen sesi pengguna, serta pengelolaan profil dan inisial avatar otomatis. | Selesai |
| **Fase 2** | `feature/board` | **Manajemen Board & Keanggotaan:** Pembuatan *board* dengan warna tema & privasi, pembangkitan kode undangan unik, fitur bergabung via kode (*Join Board*), serta pengaturan umum dan daftar anggota *board*. | Selesai |
| **Fase 3** | `feature/task` | **Papan Kanban Realtime & Detail Task:** CRUD kolom *list* (tambah, ubah nama, kunci, hapus), pemindahan kartu *drag-and-drop* secara *real-time*, serta seluruh fitur `TaskDetailScreen` (*cover*, deskripsi, *start/due date*, *subtask*, komentar, dan lampiran Storage + pratinjau penuh). | Selesai |
| **Fase 4** | `feature/chat` | **Diskusi Real-time Board:** Ruang obrolan langsung per *board* (`BoardChatScreen`) menggunakan kanal WebSocket Supabase Realtime untuk komunikasi antar-anggota. | Integrasi |
| **Fase 5** | `feature/poll` | **Polling & Voting Board:** Pembuatan jajak pendapat pada pengaturan *board*, mekanisme pemungutan suara anggota, dan kalkulasi persentase hasil secara langsung. | Rencana |
| **Fase 6** | `feature/storage`<br>`feature/notification`<br>`release/v1.0.0` | **Storage Board, Laporan PDF, Notifikasi & Rilis:** Repositori berkas tingkat *board*, ekspor laporan progres ke PDF, notifikasi otomatis berbasis *database trigger*, pembersihan data *dummy*, dan rilis ke `main`. | Rencana |

---

## 2. Catatan Pembaruan & Perbaikan Teknis (Changelog)

### Pembaruan Modul Detail Task & Lampiran
* **Penyimpanan & Pratinjau Lampiran Multi-Sumber:**
  * Mengintegrasikan `image_picker` dan `file_picker` untuk mengunggah foto kamera dan berkas dokumen ke *bucket* publik Supabase Storage **`task-attachments`**, sekaligus menyimpan tautan URL ke tabel `task_attachments`.
  * Membangun komponen `AttachmentViewer` untuk menampilkan pratinjau gambar layar penuh (*pinch-to-zoom* dengan `InteractiveViewer`) lengkap dengan tombol navigasi dan unduh berlatar kontras tinggi.
  * Memisahkan perilaku unduhan dokumen pada modal pratinjau: **Buka File** menyimpan sementara ke direktori *cache* (`getTemporaryDirectory()`) lalu membukanya via `open_filex`, sedangkan **Download** menyimpan berkas secara permanen ke folder publik `Download` perangkat.
* **Sinkronisasi Lampiran Pasca Force Close:**
  * Menambahkan `TaskService.fetchTaskAttachments` dan `AppDataController.loadTaskAttachments` yang dipanggil otomatis pada `initState()` halaman `TaskDetailScreen`, serta menyertakan relasi `task_attachments(*)` di dalam `fetchAllUserTasks` agar daftar lampiran selalu termuat utuh setelah aplikasi ditutup paksa.
* **Penyederhanaan Model Keanggotaan Tugas:**
  * Menyelaraskan tampilan anggota pada halaman detail tugas agar mengambil langsung dari daftar keanggotaan *board* (`board['members']`) tanpa memisahkan peran kaku manajer, sehingga alur kolaborasi lebih ringkas dan konsisten.

### Perbaikan Bug Kritis (Bug Fixes)
* **Perbaikan Runtime Type Error pada `.firstWhere(..., orElse: ...)`:**
  * *Masalah:* Aplikasi mengalami *crash* (`type '() => Map<dynamic, dynamic>' is not a subtype of type '(() => Map<String, dynamic>)?' of 'orElse'`) saat menyimpan deskripsi, mengubah *cover*, menambah *subtask*, atau membuka *Board Chat* setelah list `boards` dan `tasks` terisi ulang dari Supabase.
  * *Solusi:* Mendeklarasikan tipe list secara eksplisit (`List<Map<String, dynamic>>`) di `AppDataController` serta menyeragamkan seluruh callback `orElse` menjadi `() => <String, dynamic>{}` di `app_data.dart`, `task_detail_screen.dart`, dan `board_chat_screen.dart`.
* **Penanganan Kebocoran Data Task Lintas Board ("Unknown Board"):**
  * *Masalah:* Saat menguji dua akun berbeda pada perangkat yang sama, tugas dari *board* pribadi milik akun pembuat muncul di tab *Tasks* akun lain dengan label `"Unknown Board"`.
  * *Solusi:* Menambahkan filter keanggotaan melalui *inner join* (`boards.board_members.user_id = userId`) pada `TaskService.fetchAllUserTasks` dan memperketat kebijakan **Row Level Security (RLS)** pada tabel `tasks` agar hanya anggota *board* terdaftar yang dapat membaca maupun mengubah data tugas.
* **Konsistensi Penghapusan Kolom List Kanban:**
  * *Masalah:* Penghapusan kolom pada papan Kanban berpotensi gagal akibat kendala relasi *foreign key* jika masih terdapat kartu tugas di dalamnya.
  * *Solusi:* Memperbarui `TaskService.deleteBoardList` agar menghapus seluruh baris `tasks` pada kolom terkait terlebih dahulu sebelum menghapus kolom di `board_lists` dan memverifikasinya menggunakan `.select()`.