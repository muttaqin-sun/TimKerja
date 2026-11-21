# Spesifikasi Fitur & Modul — TimKerja

Dokumen ini menjabarkan spesifikasi fungsional, alur interaksi pengguna, serta aturan pemrosesan data pada setiap modul aplikasi **TimKerja**.

---

## 1. Autentikasi & Manajemen Profil

* **File Terkait:** `splash_screen.dart`, `sign_in_screen.dart`, `sign_up_screen.dart`, `profile_tab.dart`, `auth_service.dart`, `profile_service.dart`
* **Alur Fungsional:**
  1. **Pengecekan Sesi Awal:** Saat aplikasi dibuka, `SplashScreen` memeriksa status sesi Supabase Auth (`currentSession`). Jika aktif, aplikasi memuat profil pengguna (`loadUserProfile`), daftar *board* (`loadUserBoards`), dan daftar tugas (`loadAllUserTasks`) sebelum masuk ke `MainNavigationScreen`.
  2. **Registrasi & Login:** Mendukung pendaftaran akun baru dan login menggunakan email serta kata sandi.
  3. **Profil & Inisial Otomatis:** Sistem secara otomatis membentuk 1–2 huruf inisial dari nama pengguna (`_getInitials`) sebagai cadangan avatar apabila `avatar_url` belum diatur.
  4. **Reset Sesi:** Saat pengguna keluar (*logout*), `AppDataController.resetUserSession()` membersihkan seluruh *state* profil, `boards`, dan `tasks` dari memori lokal agar tidak terbawa ke akun berikutnya yang login di perangkat yang sama.

---

## 2. Manajemen Board & Keanggotaan

* **File Terkait:** `home_tab.dart`, `create_board_screen.dart`, `board_settings/`, `board_service.dart`
* **Alur Fungsional:**
  1. **Pembuatan Board:** Pengguna menentukan judul, deskripsi, warna tema, dan tingkat privasi (*Private* / *Public*). Database secara otomatis menghasilkan kode undangan unik (`code`) dan mendaftarkan pembuat sebagai anggota awal di `board_members`.
  2. **Bergabung via Kode:** Pengguna lain dapat memasukkan kode *board* melalui dialog *Join Board* (`joinBoardByCode`). Sistem memvalidasi keberadaan kode dan menambahkan `user_id` ke tabel `board_members`.
  3. **Kontrol Akses & Pengaturan:** Hanya pembuat *board* (`created_by`) atau pengguna dengan peran `Pembuat Board` yang memiliki akses penuh untuk mengubah pengaturan umum, mengelola kolom *list*, atau menghapus *board* secara permanen. Anggota biasa memiliki opsi untuk keluar dari *board* (`leaveBoard`).

---

## 3. Papan Kanban & Sinkronisasi Realtime

* **File Terkait:** `board_screen.dart`, `task_service.dart`, `app_data.dart`
* **Alur Fungsional:**
  1. **Manajemen Kolom List (`board_lists`):**
     * **Tambah List:** Menyimpan kolom baru dengan nilai `position` sesuai jumlah kolom saat ini agar urutan tetap konsisten.
     * **Ubah Nama (`renameBoardList`):** Memperbarui judul di `board_lists` sekaligus menyinkronkan kolom `list_name` pada seluruh *task* di dalamnya.
     * **Kunci Kolom (`toggleListLock`):** Menandai kolom dengan `is_locked = true` sehingga kartu di dalamnya terkunci dari pemindahan atau penambahan tugas baru.
     * **Hapus List (`deleteBoardList`):** Menghapus seluruh kartu pada tabel `tasks` di dalam kolom tersebut terlebih dahulu (mencegah konflik *foreign key*), lalu menghapus baris pada `board_lists` dan memverifikasinya menggunakan `.select()`.
  2. **Interaksi Kartu Task (`Drag & Drop`):** Pengguna dapat menggeser kartu tugas antar kolom maupun mengatur ulang urutannya di dalam satu kolom (`moveTaskToList`), serta mengurutkan kartu berdasarkan status selesai (`sortTasksByStatus`).
  3. **Sinkronisasi Langsung:** `BoardScreen` membuka saluran `RealtimeChannel` pada tabel `board_lists` dan `tasks`. Setiap perubahan dari anggota tim lain otomatis memicu `loadTasksForBoard(boardId)` sehingga papan Kanban selalu mutakhir.

---

## 4. Detail Task, Subtask, Komentar & Lampiran

* **File Terkait:** `task_detail_screen.dart`, `attachment_viewer.dart`, `task_service.dart`, `app_data.dart`
* **Alur Fungsional:**
  1. **Cover Kartu (`setTaskCover`):** Mendukung 10 pilihan warna preset dengan dua mode tampilan: *Header* (mewarnai `AppBar`) dan *Full* (menambahkan *banner* warna penuh di bagian atas layar detail).
  2. **Status Penyelesaian & Deskripsi:** Lingkaran centang di samping judul mengubah status `isDone` (`To Do` $\leftrightarrow$ `Done`). Kolom deskripsi dilengkapi tombol konfirmasi simpan (`✓`) dan batal (`✕`) yang muncul otomatis saat kolom mendapat fokus.
  3. **Jadwal & Pengingat:** Mendukung pengaturan `Start date` dan `Due date` (pilihan cepat maupun pemilih tanggal/waktu kustom), opsi pengingat (*reminder*), serta opsi *Add me to the card*.
  4. **Checklist Subtask & Kalkulasi Status Otomatis:**
     * Pengguna dapat menambah, mencentang, dan menghapus *subtask*.
     * Fungsi `_updateTaskStatus()` secara otomatis menghitung status *task* induk berdasarkan progres *subtask*:
       * `0` selesai $\rightarrow$ **To Do** (`isDone = false`)
       * Sebagian selesai $\rightarrow$ **In Progress** (`isDone = false`)
       * Semua selesai $\rightarrow$ **Done** (`isDone = true`)
  5. **Anggota & Komentar:**
     * Daftar **Anggota** menampilkan seluruh anggota aktif yang tergabung di *board* terkait (`board['members']`).
     * Kolom **Komentar** menyimpan pesan ke tabel `task_comments` beserta identitas pengirim dan menggulirkan layar otomatis (*auto-scroll*) ke komentar terbaru.
  6. **Lampiran Multi-Sumber & Pratinjau (`task_attachments` & `AttachmentViewer`):**
     * **Sinkronisasi Otomatis:** Saat `TaskDetailScreen` dibuka, `loadTaskAttachments(taskId)` menarik data terbaru dari Supabase agar lampiran tetap tampil meskipun aplikasi baru dibuka ulang setelah *force close*.
     * **4 Sumber Input:**
       * *Take photo* (`image_picker`): Mengambil foto kamera dan mengunggahnya ke *bucket* `task-attachments` dengan tipe `'image'`.
       * *File* (`file_picker`): Memilih dokumen/gambar lokal dan mengunggahnya ke Storage dengan tipe `'image'` atau `'file'`.
       * *Clipboard* & *Attach a link*: Menyimpan tautan URL langsung ke database dengan tipe `'link'`.
     * **Aksi Ketuk & Tekan Lama:**
       * Ketuk **Gambar (`image`)**: Membuka `_FullScreenImagePage` berlatar hitam dengan dukungan *pinch-to-zoom* (`InteractiveViewer`) dan tombol unduh kontras di pojok kanan atas.
       * Ketuk **Dokumen (`file`)**: Membuka *bottom sheet* pratinjau berkas dengan dua opsi unduhan menggunakan `Dio`: **Buka File** (menyimpan ke direktori *cache* sementara via `getTemporaryDirectory()` lalu membukanya dengan `open_filex`) dan **Download** (menyimpan permanen ke folder `Download` publik HP).
       * Ketuk **Tautan (`link`)**: Menyalin URL ke *clipboard* perangkat.
       * Tekan lama (*Long Press*) pada kartu lampiran mana pun akan memunculkan dialog konfirmasi penghapusan.

---

## 5. Rekap Tugas Lintas Board & Beranda

* **File Terkait:** `home_tab.dart`, `tasks_tab.dart`, `task_service.dart`
* **Alur Fungsional:**
  * `HomeTab` menampilkan daftar *board* yang diikuti pengguna, pintasan tugas yang jatuh tempo hari ini (`todayTasks`), serta log aktivitas terbaru (`recentActivities`).
  * `TasksTab` menampilkan seluruh tugas pengguna dari berbagai *board*. Pengambilan data (`fetchAllUserTasks`) difilter menggunakan *inner join* terhadap `board_members` berdasarkan `userId` aktif sehingga tugas dari *board* pribadi milik pengguna lain tidak pernah bocor.

---

## 6. Diskusi Board (Chat) & Modul Lanjutan

| Modul | File Terkait | Spesifikasi Alur |
| :--- | :--- | :--- |
| **Board Chat** | `board_chat_screen.dart` | Ruang diskusi *real-time* per *board* dengan gelembung pesan pengirim/penerima dan identifikasi anggota board. |
| **Polling & Voting** | `board_settings/polling_tab.dart`, `create_poll_screen.dart` | Pembuatan jajak pendapat dengan beberapa opsi jawaban, mekanisme 1 suara per anggota, penutupan polling, dan perhitungan persentase suara. |
| **Berkas & Laporan PDF** | `board_settings/files_tab.dart`, `reports_tab.dart`, `pdf_report_service.dart` | Repositori berkas tingkat *board* dan pembangkitan laporan rekap progres tugas dalam format dokumen PDF siap unduh. |
| **Notifikasi** | `notifications_tab.dart` | Pengelompokan notifikasi berdasarkan kategori (*Due Dates*, *Assignments*, *Mentions*), status baca, dan penghapusan notifikasi. |