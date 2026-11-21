# Skema Database & Backend Supabase — TimKerja

Dokumen ini merinci struktur database PostgreSQL, relasi antar-tabel, kebijakan keamanan **Row Level Security (RLS)**, konfigurasi **Supabase Storage**, serta saluran **Supabase Realtime** yang digunakan pada proyek **TimKerja**.

---

## 1. Diagram Relasi Antar-Tabel (ERD)

```
┌──────────────┐       ┌───────────────────┐       ┌──────────────┐
│   profiles   │◄──────│   board_members   │──────►│    boards    │
│ (auth.users) │       │ (user_id, role)   │       │ (code, etc.) │
└──────┬───────┘       └───────────────────┘       └──────┬───────┘
       │                                                  │
       │                                      ┌───────────┴───────────┐
       │                                      ▼                       ▼
       │                             ┌─────────────────┐     ┌─────────────────┐
       │                             │   board_lists   │     │      tasks      │
       │                             │ (title, locked) │     │ (cover, dates)  │
       │                             └─────────────────┘     └────────┬────────┘
       │                                                              │
       │                                     ┌────────────────────────┼────────────────────────┐
       │                                     ▼                        ▼                        ▼
       │                            ┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
       └───────────────────────────►│  task_comments  │     │     subtasks     │     │ task_attachments  │
                                    │ (user_id, text) │     │ (title, is_done) │     │ (name, url, type) │
                                    └─────────────────┘     └──────────────────┘     └───────────────────┘
```

---

## 2. Daftar Tabel Utama (Skema `public`)

### A. Tabel Inti yang Sudah Aktif

| Nama Tabel | Kolom Utama & Tipe Data | Keterangan & Relasi |
| :--- | :--- | :--- |
| **`profiles`** | `id` (`uuid`, PK, ref `auth.users`), `name` (`text`), `email` (`text`), `avatar_color` (`bigint`), `avatar_url` (`text`), `role` (`text`) | Menyimpan data profil pengguna aplikasi beserta peran global (`Pembuat Board` / `Anggota`). |
| **`boards`** | `id` (`uuid`, PK), `title` (`text`), `description` (`text`), `color` (`bigint`), `privacy` (`text`), `code` (`text`, unique), `created_by` (`uuid`, FK `profiles.id`), `created_at` (`timestamptz`) | Menyimpan informasi papan proyek beserta kode undangan unik. Pembuat otomatis ditambahkan ke `board_members` melalui *database trigger*. |
| **`board_members`** | `id` (`uuid`, PK), `board_id` (`uuid`, FK `boards.id`), `user_id` (`uuid`, FK `profiles.id`), `role` (`text`), `joined_at` (`timestamptz`) | Tabel penghubung keanggotaan pengguna pada setiap *board*. Menjadi dasar validasi akses membaca data *board* dan *task*. |
| **`board_lists`** | `id` (`uuid`, PK), `board_id` (`uuid`, FK `boards.id`), `title` (`text`), `position` (`int4`), `is_locked` (`boolean`, default `false`), `created_at` (`timestamptz`) | Menyimpan kolom-kolom Kanban pada setiap *board*, urutan posisinya, serta status kunci kolom. |
| **`tasks`** | `id` (`uuid`, PK), `board_id` (`uuid`, FK `boards.id`), `list_name` (`text`), `title` (`text`), `description` (`text`), `status` (`text`), `priority` (`text`), `position` (`int4`), `is_done` (`boolean`), `cover_color` (`bigint`), `cover_size` (`text`), `start_date` (`text`), `start_time` (`text`), `due_date` (`text`), `due_time` (`text`), `reminder` (`text`), `add_me_to_card` (`boolean`), `created_by` (`uuid`), `created_at` (`timestamptz`) | Menyimpan seluruh kartu tugas beserta kustomisasi *cover*, jadwal mulai/tenggat, pengingat, dan status penyelesaian. |
| **`subtasks`** | `id` (`uuid`, PK), `task_id` (`uuid`, FK `tasks.id` `ON DELETE CASCADE`), `title` (`text`), `is_done` (`boolean`), `created_at` (`timestamptz`) | Menyimpan item *checklist* di dalam sebuah *task*. Status *task* induk otomatis dihitung dari persentase *subtask* yang selesai. |
| **`task_comments`** | `id` (`uuid`, PK), `task_id` (`uuid`, FK `tasks.id` `ON DELETE CASCADE`), `user_id` (`uuid`, FK `profiles.id`), `text` (`text`), `created_at` (`timestamptz`) | Menyimpan riwayat diskusi/komentar pada halaman detail *task*. |
| **`task_attachments`** | `id` (`uuid`, PK), `task_id` (`uuid`, FK `tasks.id` `ON DELETE CASCADE`), `name` (`text`), `url` (`text`), `type` (`text`: `'image'`, `'file'`, `'link'`), `created_at` (`timestamptz`) | Menyimpan tautan URL maupun *Public URL* berkas/foto yang diunggah ke Supabase Storage untuk sebuah *task*. |

### B. Tabel Lanjutan (Tahap Integrasi Berikutnya)

| Nama Tabel | Modul Terkait | Kegunaan |
| :--- | :--- | :--- |
| **`messages`** | `feature/chat` | Menyimpan pesan obrolan grup per *board* (`board_id`, `user_id`, `content`, `created_at`). |
| **`polls`**, **`poll_options`**, **`poll_votes`** | `feature/poll` | Menyimpan pertanyaan polling per *board*, pilihan jawaban, dan suara anggota. |
| **`files`** & **`reports`** | `feature/storage` | Menyimpan berkas umum tingkat *board* dan arsip ekspor laporan PDF. |
| **`notifications`** | `feature/notification` | Menyimpan notifikasi aktivitas (*due date*, penugasan, komentar baru) per pengguna. |

---

## 3. Skrip SQL Skema Pendukung Task & Lampiran

Jalankan skrip berikut di **SQL Editor** Supabase untuk memastikan seluruh kolom detail *task* dan tabel pendukung tersedia:

```sql
-- 1. Pastikan kolom detail task tersedia di tabel tasks
alter table public.tasks add column if not exists cover_color bigint;
alter table public.tasks add column if not exists cover_size text default 'header';
alter table public.tasks add column if not exists start_date text;
alter table public.tasks add column if not exists start_time text;
alter table public.tasks add column if not exists due_date text;
alter table public.tasks add column if not exists due_time text;
alter table public.tasks add column if not exists reminder text default '1 hari sebelumnya';
alter table public.tasks add column if not exists add_me_to_card boolean default false;

-- 2. Pastikan kolom status kunci list tersedia
alter table public.board_lists add column if not exists is_locked boolean default false;

-- 3. Tabel metadata lampiran task
create table if not exists public.task_attachments (
  id uuid default gen_random_uuid() primary key,
  task_id uuid references public.tasks(id) on delete cascade not null,
  name text not null,
  url text not null,
  type text default 'link',
  created_at timestamptz default now()
);
```

---

## 4. Kebijakan Keamanan Row Level Security (RLS)

Untuk mencegah kebocoran data lintas *board* (misalnya tugas dari *board* pribadi muncul di akun pengguna lain yang belum bergabung menggunakan kode *board*), tabel `tasks` dibatasi menggunakan pemeriksaan keanggotaan pada `board_members`:

```sql
-- 1. Isolasi akses tabel tasks hanya untuk anggota board terkait
alter table public.tasks enable row level security;
drop policy if exists "Authenticated users full access on tasks" on public.tasks;
drop policy if exists "Members can access tasks in their boards" on public.tasks;

create policy "Members can access tasks in their boards"
on public.tasks
for all
to authenticated
using (
  exists (
    select 1 from public.board_members bm
    where bm.board_id = tasks.board_id
      and bm.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.board_members bm
    where bm.board_id = tasks.board_id
      and bm.user_id = auth.uid()
  )
);

-- 2. Kebijakan akses untuk board_lists & task_attachments
alter table public.board_lists enable row level security;
drop policy if exists "Authenticated users full access on board_lists" on public.board_lists;
create policy "Authenticated users full access on board_lists"
on public.board_lists for all to authenticated using (true) with check (true);

alter table public.task_attachments enable row level security;
drop policy if exists "Authenticated full access task_attachments" on public.task_attachments;
create policy "Authenticated full access task_attachments"
on public.task_attachments for all to authenticated using (true) with check (true);
```

---

## 5. Konfigurasi Supabase Storage

Seluruh unggahan foto kamera dan dokumen lampiran pada halaman detail tugas disimpan ke dalam *bucket* publik **`task-attachments`** dengan format jalur `<taskId>/<timestamp>.<ext>`.

```sql
-- 1. Buat Bucket publik 'task-attachments'
insert into storage.buckets (id, name, public)
values ('task-attachments', 'task-attachments', true)
on conflict (id) do nothing;

-- 2. Policy Upload, Baca Publik, dan Hapus Berkas
drop policy if exists "Authenticated upload task-attachments" on storage.objects;
create policy "Authenticated upload task-attachments"
on storage.objects for insert to authenticated
with check (bucket_id = 'task-attachments');

drop policy if exists "Public read task-attachments" on storage.objects;
create policy "Public read task-attachments"
on storage.objects for select to public
using (bucket_id = 'task-attachments');

drop policy if exists "Authenticated delete task-attachments" on storage.objects;
create policy "Authenticated delete task-attachments"
on storage.objects for delete to authenticated
using (bucket_id = 'task-attachments');
```

---

## 6. Publikasi Supabase Realtime

Tabel-tabel berikut didaftarkan ke publikasi `supabase_realtime` agar setiap operasi `INSERT`, `UPDATE`, dan `DELETE` langsung disiarkan melalui WebSocket ke aplikasi klien:

```sql
alter publication supabase_realtime add table public.board_lists;
alter publication supabase_realtime add table public.tasks;
alter publication supabase_realtime add table public.subtasks;
alter publication supabase_realtime add table public.task_comments;
alter publication supabase_realtime add table public.task_attachments;
```