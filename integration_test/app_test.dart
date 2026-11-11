import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sehatinfo/main.dart';
import 'package:sehatinfo/models.dart';

Future<Store> boot(WidgetTester t) async {
  final s = Store();
  await s.load();
  await t.pumpWidget(SehatApp(s));
  await t.pumpAndSettle();
  return s;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('skenario utama: artikel, bookmark, layanan terkait, kuis', (t) async {
    await boot(t);
    await t.tap(find.text('Edukasi'));
    await t.pumpAndSettle();
    await t.tap(find.text('Jadwal Imunisasi Dasar Lengkap'));
    await t.pumpAndSettle();
    await t.tap(find.byWidgetPredicate((w) => w is IconButton && (w.tooltip ?? '').contains('favorit')));
    await t.pumpAndSettle();

    await t.ensureVisible(find.text('Kerjakan kuis'));
    await t.tap(find.text('Kerjakan kuis'));
    await t.pumpAndSettle();
    await t.tap(find.text('BCG'));
    await t.pumpAndSettle();
    expect(find.textContaining('Benar.'), findsOneWidget);
    await t.tap(find.text('Lanjut'));
    await t.pumpAndSettle();
    await t.tap(find.text('Buku KIA'));
    await t.pumpAndSettle();
    await t.tap(find.text('Lihat skor'));
    await t.pumpAndSettle();
    expect(find.text('Skor 2 dari 2'), findsOneWidget);
    await t.tap(find.text('Selesai'));
    await t.pumpAndSettle();

    await t.ensureVisible(find.text('Cari layanan terkait'));
    await t.tap(find.text('Cari layanan terkait'));
    await t.pumpAndSettle();
    expect(find.text('Puskesmas Sehat Sentosa (Simulasi)'), findsOneWidget);
    expect(find.text('RS Umum Contoh Medika (Simulasi)'), findsNothing);
    await t.tap(find.text('Puskesmas Sehat Sentosa (Simulasi)'));
    await t.pumpAndSettle();
    expect(find.text('Telepon'), findsOneWidget);
  });

  testWidgets('umpan balik kosong menampilkan pesan galat', (t) async {
    await boot(t);
    await t.tap(find.text('Profil'));
    await t.pumpAndSettle();
    await t.tap(find.text('Umpan balik'));
    await t.pumpAndSettle();
    await t.tap(find.text('Kirim umpan balik'));
    await t.pumpAndSettle();
    expect(find.text('Pilih rating 1 sampai 5 bintang.'), findsOneWidget);
  });
}
