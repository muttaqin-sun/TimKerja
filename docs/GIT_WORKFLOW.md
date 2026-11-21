# Panduan Git Workflow & Branching — TimKerja

Dokumen ini menetapkan standar pengelolaan kode sumber (*version control*) menggunakan model **Git Flow** pada repositori **TimKerja** agar pengembangan setiap modul terisolasi dengan aman dan riwayat perubahan tercatat rapi.

---

## 1. Struktur Hierarki Branch

```
main       ────●─────────────────────────────────────────────●────► (Rilis Stabil / Produksi)
                \                                           /
develop    ──────●───────●───────●───────●───────●─────────●──────► (Integrasi & Uji Gabungan)
                  \     / \     / \     / \     /         /
feature/auth       ●───●   \   /   \   /   \   /         /
feature/board               ●─●     \ /     \ /         /
feature/task                         ●───────●         /
release/v1.0.0                                ●───────●
```

### A. Dua Branch Utama (Permanen)
| Nama Branch | Peran & Aturan Perlindungan |
| :--- | :--- |
| **`main`** | Menyimpan kode sumber paling stabil yang telah lulus uji gabungan di `develop` dan siap dirilis atau didemonstrasikan. Dilarang melakukan *commit* langsung ke `main` kecuali melalui *merge* dari `release/*` atau `hotfix/*`. |
| **`develop`** | Cabang utama integrasi pengembangan. Seluruh cabang `feature/*` yang sudah selesai digabungkan ke sini untuk menguji kompatibilitas antar-modul sebelum masuk ke `main`. |

### B. Daftar Branch Fitur (`feature/*`)
Setiap modul fungsional dikerjakan pada cabang terpisah yang dibuat dari `develop`:

| Nama Branch | Cakupan Modul | Status |
| :--- | :--- | :--- |
| `feature/auth` | Registrasi, login email/kata sandi, manajemen sesi, dan layar splash. | Selesai |
| `feature/profile` | Pembaruan profil pengguna, foto avatar, dan inisial otomatis. | Selesai |
| `feature/board` | Pembuatan *board*, pembangkitan kode undangan, *join board*, dan pengaturan *board*. | Selesai |
| `feature/task` | Kolom Kanban, *drag-and-drop* *realtime*, serta seluruh fitur `TaskDetailScreen` (cover, jadwal, subtask, komentar, dan lampiran Storage/Viewer). | Selesai |
| `feature/chat` | Ruang diskusi *real-time* per *board* (`BoardChatScreen`). | Integrasi |
| `feature/poll` | Pembuatan jajak pendapat dan pemungutan suara anggota *board*. | Rencana |
| `feature/storage` | Manajemen berkas umum tingkat *board* (`FilesTab`) dan ekspor laporan PDF (`ReportsTab`). | Rencana |
| `feature/notification` | Pusat notifikasi aktivitas *real-time* dan pemicu otomatis database. | Rencana |

### C. Branch Pemeliharaan & Rilis (Sementara)
* **`bugfix/<nama-bug>`**: Dibuat dari `develop` untuk memperbaiki *bug* yang ditemukan saat pengujian integrasi (contoh: `bugfix/task-leakage-rls`), lalu di-*merge* kembali ke `develop`.
* **`release/<versi>`**: Dibuat dari `develop` saat seluruh fitur target sudah lengkap (contoh: `release/v1.0.0`) untuk pembersihan akhir sebelum di-*merge* ke `main` dan `develop`.
* **`hotfix/<nama-fix>`**: Dibuat langsung dari `main` hanya jika ditemukan *bug* kritis pada versi produksi yang harus segera ditambal, lalu di-*merge* ke `main` dan `develop`.

---

## 2. Alur Kerja Pengembangan Harian

### Langkah 1: Memulai Fitur Baru dari `develop`
Selalu pastikan cabang `develop` lokal sudah memuat pembaruan terbaru sebelum membuat cabang fitur baru:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<nama-fitur>
```

### Langkah 2: Menyimpan Perubahan Secara Berkala (`Commit`)
Gunakan format pesan *commit* yang deskriptif mengikuti konvensi **Conventional Commits**:

| Prefiks | Kegunaan | Contoh Pesan Commit |
| :--- | :--- | :--- |
| `feat:` | Penambahan fitur atau komponen UI baru | `feat: add full-screen image viewer and file download` |
| `fix:` | Perbaikan *bug* atau galat tipe data | `fix: filter fetchAllUserTasks by board membership userId` |
| `docs:` | Pembaruan dokumentasi proyek (`.md`) | `docs: add database schema and RLS documentation` |
| `refactor:` | Perbaikan struktur kode tanpa mengubah perilaku | `refactor: enforce Map<String, dynamic> typing in AppDataController` |
| `chore:` | Penambahan *package* atau konfigurasi proyek | `chore: add dio, path_provider, and open_filex dependencies` |

```bash
git status
git add .
git commit -m "feat: deskripsi singkat perubahan"
git push -u origin feature/<nama-fitur>
```

---

## 3. Prosedur Penggabungan (`Merge`) ke `develop` dan `main`

### A. Menggabungkan `feature/*` ke `develop`
Gunakan flag `--no-ff` (*no fast-forward*) agar riwayat penggabungan setiap fitur tetap terlihat sebagai satu simpul *merge commit* yang jelas di grafik Git:

```bash
# 1. Pindah ke develop dan perbarui dari remote
git checkout develop
git pull origin develop

# 2. Gabungkan branch fitur yang sudah selesai
git merge --no-ff feature/<nama-fitur>

# 3. Kirim hasil integrasi ke GitHub
git push origin develop
```

### B. Merilis Kode Stabil dari `develop` ke `main`
Dilakukan setelah seluruh modul terintegrasi di `develop` dan diuji tanpa galat:

```bash
git checkout main
git pull origin main
git merge --no-ff develop
git tag -a v1.0.0 -m "Rilis versi 1.0.0 TimKerja"
git push origin main --tags
```

---

## 4. Penanganan Merge Conflict

Apabila muncul peringatan **`CONFLICT (content): Merge conflict in <nama-file>`** saat menjalankan `git merge`:

1. Buka file yang ditandai konflik di VS Code.
2. Tinjau blok penanda `<<<<<<< HEAD` (kode di `develop`) dan `======= ... >>>>>>> feature/...` (kode dari cabang fitur).
3. Pilih atau gabungkan bagian kode yang benar dan pastikan penanda konflik (`<<<<<<<`, `=======`, `>>>>>>>`) telah dihapus seluruhnya.
4. Simpan file, jalankan `flutter analyze` untuk memastikan tidak ada galat sintaks, lalu selesaikan *merge*:

```bash
git add .
git commit -m "chore: resolve merge conflict on <nama-file>"
git push origin develop
```