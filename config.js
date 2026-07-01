// =====================================================================================
// KONFIGURASI SUPABASE  ► isi 2 nilai ini dari:
//   Supabase Dashboard -> Project Settings -> API
//     - Project URL  (mis. https://abcd1234.supabase.co)
//     - anon public key  (JWT panjang; AMAN ditaruh di frontend)
// =====================================================================================
window.APP_CONFIG = {
  SUPABASE_URL: 'https://norqbivlzrjgaqnrpyoh.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcnFiaXZsenJqZ2FxbnJweW9oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4ODg2NTcsImV4cCI6MjA5ODQ2NDY1N30.mhXLnzV5kfoMQjYgwzL4MdhMQwCQelOjcRwG-gUD4mk',

  STATUS_OPEN: 'Belum Tindak Lanjut',
  STATUS_DONE: 'Sudah Ditindaklanjuti',

  // Lebar kode wilayah (jaga nol di depan saat menambah baris & lookup)
  CODE_WIDTHS: { kode_prov: 2, kode_kab: 4, kode_kec: 7, kode_desa: 10, kode_sls: 4, sub_sls: 2 },

  PAGE_SIZE: 50
};
