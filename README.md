# SehatInfo

Aplikasi mobile edukasi kesehatan dan informasi layanan (data simulasi), Tugas Project Individu IF2371054. Dibangun mengikuti dokumen PRD dan Design.

## Fitur
Beranda dan tips harian, katalog artikel dengan pencarian dan filter kategori, detail artikel dengan bookmark, direktori fasilitas dengan filter jenis dan layanan beserta status buka/tutup, detail fasilitas dan jadwal poli, kuis kesehatan, umpan balik tervalidasi, riwayat kuis, mode gelap, serta halaman tentang dan privasi.

## Menjalankan
Prasyarat: Flutter stable (Dart 3.3+).

```bash
flutter create --platforms=android --project-name sehatinfo .   # membuat folder android/ (sekali saja)
bash tool/patch_android.sh                                      # izin notifikasi + desugaring (sekali saja)
flutter pub get
flutter run
flutter test                      # unit test
flutter test integration_test    # butuh emulator/perangkat
flutter build apk --release
```

Perintah `flutter create .` tidak menimpa `lib/`, `pubspec.yaml`, atau `assets/` yang sudah ada. Jika ia mengganti `test/widget_test.dart` bawaan, hapus file tersebut.

## Struktur
- `lib/models.dart`: model, validasi, logika, dan Store (penyimpanan lokal)
- `lib/screens.dart`: seluruh layar
- `assets/data/`: data simulasi (JSON)
- `test/`: unit test logika
- `.github/workflows/ci.yml`: lint, test, build APK, rilis pada tag `v*`

## Privasi
Tidak ada backend, analytics, atau pengiriman data. Hanya favorit, skor kuis, umpan balik anonim, dan tema yang disimpan lokal.

## Pengingat harian (FR-08)
Memakai `flutter_local_notifications` (notifikasi lokal berulang harian, tanpa server). Aktifkan di Profil. Jika izin ditolak atau gagal, aplikasi menampilkan pesan dan tips harian tetap ada di Beranda.
