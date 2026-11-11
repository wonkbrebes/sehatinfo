import 'package:flutter_test/flutter_test.dart';
import 'package:sehatinfo/models.dart';

Facility fac({int days = 6, String open = '07:30', String close = '15:00'}) => Facility({
      'id': 'x', 'name': 'X', 'type': 'klinik', 'address': 'A', 'phone': '0',
      'km': 1, 'open': open, 'close': close, 'days': days,
      'services': ['Poli Umum'], 'schedule': ['Poli Umum: Sen-Sab'],
    });

void main() {
  test('status buka/tutup mengikuti hari dan jam', () {
    final f = fac();
    expect(f.isOpen(DateTime(2026, 11, 12, 9, 0)), true); // Kamis
    expect(f.isOpen(DateTime(2026, 11, 12, 16, 0)), false);
    expect(f.isOpen(DateTime(2026, 11, 15, 9, 0)), false); // Minggu
  });

  test('penilaian kuis', () {
    final qs = [
      for (final a in [0, 1])
        Quiz({'topic': 't', 'question': 'q', 'explanation': 'e', 'options': ['a', 'b'], 'answer': a})
    ];
    expect(scoreQuiz(qs, [0, 0]), 1);
    expect(scoreQuiz(qs, [0, 1]), 2);
  });

  test('validasi umpan balik', () {
    expect(validateFeedback(0, ''), isNotNull);
    expect(validateFeedback(5, 'a' * 301), isNotNull);
    expect(validateFeedback(5, '<script>'), isNotNull);
    expect(validateFeedback(4, 'Bagus'), isNull);
  });

  test('pemetaan kategori ke layanan', () {
    expect(serviceForCategory('Ibu dan Anak'), 'Imunisasi');
    expect(serviceForCategory('Lainnya'), 'Poli Umum');
  });
}
