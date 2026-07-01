-- =====================================================================================
-- PEMERIKSAAN KUALITAS DATA – Skema Supabase (Postgres)
-- Jalankan di Supabase Dashboard -> SQL Editor -> New query -> Run.
-- =====================================================================================

-- ---------- 1. TABEL DATA ANOMALI ----------
create table if not exists public.anomali (
  id            bigint generated always as identity primary key,
  no            int,
  tahap         text,                                   -- '1', '2', '3', ...
  nama_usaha    text,
  kode_prov     text, nama_prov text,
  kode_kab      text, nama_kab  text,
  kode_kec      text, nama_kec  text,
  kode_desa     text, nama_desa text,
  kode_sls      text, sub_sls   text,
  assignment_id text,
  nama_anomali  text,
  tindak_lanjut text default 'Belum Tindak Lanjut',
  id_petugas    text, email_petugas text, link_fasih text,
  pml           text, ppl text,
  approve_pml   text,   -- 1=Sudah, 0=Belum
  perbaikan_ppl text,   -- 1=Sesuai Lapangan, 2=Perbaikan Isian, 0=Belum
  ada_galat     text,   -- 0=Iya, 1=Tidak  (khusus admin)
  catatan       text,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index if not exists anomali_key_idx  on public.anomali (assignment_id, nama_anomali);
create index if not exists anomali_loc_idx  on public.anomali (kode_desa, kode_sls, sub_sls);

-- ---------- 2. TABEL NAMA PETUGAS (lookup by idsubsls) ----------
create table if not exists public.petugas (
  idsubsls       text primary key,      -- kode_desa + kode_sls + sub_sls (16 digit)
  nama_kecamatan text,
  nama_desa      text,
  nama_sls       text,
  kdsubsls       text,
  nama_pic       text,
  nama_pml       text,
  nama_ppl       text
);

-- ---------- 3. TRIGGER updated_at ----------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists trg_anomali_touch on public.anomali;
create trigger trg_anomali_touch before update on public.anomali
  for each row execute function public.touch_updated_at();

-- ---------- 4. VIEW gabungan (data + nama sls/pic/pml/ppl) ----------
-- security_invoker: hormati RLS pemanggil (butuh Postgres 15+, default di Supabase baru).
create or replace view public.anomali_view
  with (security_invoker = true) as
select
  a.*,
  p.nama_sls,
  p.nama_pic,
  coalesce(nullif(a.pml,''), p.nama_pml) as pml_nama,
  coalesce(nullif(a.ppl,''), p.nama_ppl) as ppl_nama
from public.anomali a
left join public.petugas p
  on p.idsubsls = coalesce(a.kode_desa,'') || coalesce(a.kode_sls,'') || coalesce(a.sub_sls,'');

-- =====================================================================================
-- 5. KEAMANAN: RLS + hak kolom
--    - anon (petugas, tanpa login): boleh SELECT; boleh UPDATE hanya 3 kolom editable.
--    - authenticated (admin login): akses penuh (insert/update/delete).
-- =====================================================================================
alter table public.anomali enable row level security;
alter table public.petugas enable row level security;

-- Bersihkan policy lama bila re-run
drop policy if exists anomali_sel      on public.anomali;
drop policy if exists anomali_upd_anon on public.anomali;
drop policy if exists anomali_all_auth on public.anomali;
drop policy if exists petugas_sel      on public.petugas;
drop policy if exists petugas_all_auth on public.petugas;

-- SELECT untuk semua
create policy anomali_sel on public.anomali for select to anon, authenticated using (true);
create policy petugas_sel on public.petugas for select to anon, authenticated using (true);

-- UPDATE oleh anon (kolom dibatasi lewat GRANT di bawah)
create policy anomali_upd_anon on public.anomali for update to anon using (true) with check (true);

-- Admin (login) penuh
create policy anomali_all_auth on public.anomali for all to authenticated using (true) with check (true);
create policy petugas_all_auth on public.petugas for all to authenticated using (true) with check (true);

-- Hak kolom: anon hanya boleh ubah 3 kolom ini (BUKAN ada_galat / status / lokasi)
revoke all on public.anomali from anon;
grant  select on public.anomali to anon;
grant  update (approve_pml, perbaikan_ppl, catatan) on public.anomali to anon;
grant  select on public.petugas to anon;
grant  select on public.anomali_view to anon, authenticated;

-- Admin penuh
grant select, insert, update, delete on public.anomali to authenticated;
grant select, insert, update, delete on public.petugas to authenticated;

-- =====================================================================================
-- 6. IMPOR DATA (lakukan lewat Table Editor -> Import data from CSV)
--    a) Ekspor sheet "Anomali Usaha"  -> CSV -> impor ke tabel  public.anomali
--    b) Ekspor sheet "Nama Petugas"   -> CSV -> impor ke tabel  public.petugas
--    Pastikan kolom kode (kode_sls, sub_sls, dst.) tetap TEKS dengan nol di depan (0001, 01).
-- =====================================================================================

-- Buat user ADMIN: Dashboard -> Authentication -> Users -> Add user
--   Email    : bpsbuleleng5108@gmail.com   (atau email lain)
--   Password : (isi)                         -> pakai ini untuk login di halaman Admin.
--   Matikan "Confirm email" agar bisa langsung login (Authentication -> Providers -> Email).
