# Web App Anomali – Versi Supabase + GitHub Pages

Versi **statis**: frontend (HTML) di GitHub Pages, data di **Supabase** (Postgres).
Dibuka **sama di semua HP** (tidak ada masalah akun Google seperti Apps Script).

Fitur sama: **Petugas** (baca semua + filter s/d Sub SLS, edit Approve/Perbaikan/Ada Galat/Catatan),
**Admin** (login + upload snapshot per Tahap dgn pencocokan), **Monitoring**.

## Isi folder
| File | Fungsi |
|------|--------|
| `schema.sql`  | Buat tabel `anomali` + `petugas`, view, keamanan (RLS). |
| `config.js`   | Isi URL & anon key Supabase Anda. |
| `index.html`  | Aplikasi. |

---

## Langkah pasang

### 1. Buat project Supabase
1. Daftar di https://supabase.com (gratis) → **New project** (pilih region Singapore).
2. Tunggu project siap.

### 2. Buat tabel & keamanan
1. Menu **SQL Editor → New query**.
2. Tempel seluruh isi `schema.sql` → **Run**.

### 3. Impor data dari Google Sheets
1. Di Google Sheets, **File → Download → CSV** untuk sheet **Anomali Usaha** dan **Nama Petugas**
   (unduh per-sheet).
2. Supabase → **Table Editor** → tabel **`anomali`** → tombol **Insert → Import data from CSV** →
   unggah CSV Anomali Usaha. **Petakan kolom** CSV ke kolom tabel:
   `Nama Usaha→nama_usaha`, `Kode SLS→kode_sls`, `Sub SLS→sub_sls`, `Assignment ID→assignment_id`,
   `Nama Anomali→nama_anomali`, `Tindak Lanjut→tindak_lanjut`, `Tahap→tahap`, `Link Fasih→link_fasih`, dst.
   (Kolom `id` biarkan kosong — terisi otomatis.)
3. Ulangi untuk tabel **`petugas`** dengan CSV Nama Petugas
   (`idsubsls→idsubsls`, `nama sls→nama_sls`, `nama pic→nama_pic`, `nama pml→nama_pml`, `nama ppl→nama_ppl`, …).

> Penting: pastikan kode `kode_sls`/`sub_sls` tetap ada **nol di depan** (0001, 01). CSV menyimpannya
> sebagai teks; kolom tabel juga `text`, jadi aman. `idsubsls` = kode_desa+kode_sls+sub_sls (16 digit).

### 4. Buat akun ADMIN
**Authentication → Users → Add user**: isi email (mis. `bpsbuleleng5108@gmail.com`) + password.
Lalu **Authentication → Providers → Email**: matikan **Confirm email** agar bisa langsung login.

### 5. Isi `config.js`
**Project Settings → API**, salin:
- **Project URL** → `SUPABASE_URL`
- **anon public** key → `SUPABASE_ANON_KEY`  (kunci ini memang aman ditaruh di frontend)

### 6. Hosting di GitHub Pages
1. Buat repo GitHub baru → unggah `index.html` + `config.js`.
2. Repo → **Settings → Pages** → Source: **Deploy from a branch** → branch `main`, folder `/root` → Save.
3. Setelah beberapa menit muncul URL `https://<user>.github.io/<repo>/` → bagikan ini ke petugas.

---

## Cara pakai
- **Petugas**: buka link, tanpa login. Cari/filter, lalu isi Approve PML, Perbaikan oleh PPL, Catatan.
  (Ada Galat hanya bisa diisi admin.)
- **Admin**: klik **🔑 Admin** → email & password akun Supabase → menu Upload & Monitoring muncul.
- **Upload**: pilih Tahap → pilih file → **Analisa** → **Terapkan**.

## Keamanan (ringkas)
- Petugas (anon) hanya boleh **mengubah 3 kolom** (`approve_pml`, `perbaikan_ppl`, `catatan`) — diatur RLS
  + hak kolom di `schema.sql`. Tidak bisa menambah/menghapus baris atau mengubah `ada_galat`/lokasi.
- Admin (login) punya akses penuh (tambah baris, tandai selesai, isi `ada_galat`).

## Catatan
- Semua data di sheet lama tetap ada; versi Apps Script (folder `apps-script/`) tidak diubah.
- Bila ingin membatasi baris per petugas (login per orang), beri tahu — bisa ditambahkan lewat Supabase Auth + RLS.
