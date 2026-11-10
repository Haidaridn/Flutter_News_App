# Aturan Proyek News App

## Konteks

Proyek ini adalah aplikasi berita berbasis Flutter dan Dart.

Tahap front-end sudah selesai. Tahap sekarang adalah integrasi NewsAPI.org melalui `ApiNewsService`.

UI yang sudah selesai harus dipertahankan. Integrasi API dilakukan terutama pada lapisan service dan Provider tanpa merombak desain aplikasi.

Acuan utama proyek adalah `docs/PRD.md`.

## Cara Bekerja

- Baca `AGENTS.md` dan `docs/PRD.md` sebelum mengubah kode.
- Kerjakan hanya bagian yang diminta pengguna dan jangan menambahkan fitur di luar PRD.
- Jika pengguna secara eksplisit meminta integrasi NewsAPI secara lengkap, kerjakan seluruh tahap integrasi secara berurutan dari persiapan sampai pengujian.
- Jangan berhenti setelah membuat rencana jika pekerjaan masih bisa dilanjutkan dengan aman.
- Berhenti dan minta penjelasan hanya jika ada konflik dengan PRD, keputusan penting yang belum ditentukan, atau tindakan yang membutuhkan API key pengguna.
- Jangan mengubah atau menghapus pekerjaan pengguna yang tidak berkaitan dengan tugas.
- Package yang diizinkan adalah `provider`, `http`, dan `url_launcher`.
- Jangan menambahkan package lain tanpa persetujuan pengguna.
- Jangan melakukan commit atau push apabila masih ada error atau pengujian gagal.

## Struktur dan Arsitektur

- Ikuti struktur folder dalam PRD:
  - `models`
  - `services`
  - `providers`
  - `screens`
  - `widgets`
  - `theme`
- UI hanya boleh bergantung pada kelas abstrak `NewsService`.
- UI tidak boleh bergantung langsung pada `MockNewsService` maupun `ApiNewsService`.
- `MockNewsService` digunakan sebagai sumber data contoh atau pengujian.
- `ApiNewsService` digunakan untuk mengambil data sebenarnya dari NewsAPI.org.
- Pemilihan implementasi service dilakukan pada composition root, misalnya di `main.dart`.
- State jaringan dikelola melalui Provider dengan empat keadaan:
  - `loading`
  - `success`
  - `error`
  - `empty`
- `NewsProvider` harus mengubah error dari service menjadi pesan berbahasa Indonesia yang ramah pengguna.
- Bookmark disimpan di memori melalui `BookmarkProvider` tanpa penyimpanan permanen.
- Jangan merombak UI hanya untuk mengganti sumber data.

## Integrasi NewsAPI

- `ApiNewsService` harus mengimplementasikan `NewsService`.
- Gunakan endpoint HTTPS resmi NewsAPI.org.
- Kirim API key melalui header `X-Api-Key`, bukan melalui query URL.
- Baca API key menggunakan:

  ```dart
  String.fromEnvironment('NEWS_API_KEY')
  ```

## Keamanan

- API key hanya dibaca melalui `String.fromEnvironment('NEWS_API_KEY')`.
- `env.json` harus dimasukkan ke `.gitignore` dan tidak boleh di-commit.
- API key tidak boleh ditulis langsung di kode, dokumentasi, log, commit, atau chat.
- `env.example.json` hanya boleh berisi placeholder, bukan API key asli.

## Sebelum Selesai

- Jalankan `flutter analyze` dan pastikan tidak ada error.
- Jalankan pengujian yang tersedia dan jangan commit atau push jika pengujian gagal.
- Sebutkan bagian yang masih perlu diuji secara manual oleh siswa.
