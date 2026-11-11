import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Article {
  final String id, title, category, summary, content, source, updated;
  final int minutes;
  Article(Map<String, dynamic> j)
      : id = j['id'],
        title = j['title'],
        category = j['category'],
        summary = j['summary'],
        content = j['content'],
        source = j['source'],
        updated = j['updated'],
        minutes = j['minutes'];
}

class Facility {
  final String id, name, type, address, phone, open, close;
  final int days;
  final double km;
  final List<String> services, schedule;
  Facility(Map<String, dynamic> j)
      : id = j['id'],
        name = j['name'],
        type = j['type'],
        address = j['address'],
        phone = j['phone'],
        open = j['open'],
        close = j['close'],
        days = j['days'],
        km = (j['km'] as num).toDouble(),
        services = List<String>.from(j['services']),
        schedule = List<String>.from(j['schedule']);

  static int _m(String s) {
    final p = s.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// Status buka/tutup berdasarkan hari (1=Senin) dan jam.
  bool isOpen(DateTime now) {
    if (now.weekday > days) return false;
    final t = now.hour * 60 + now.minute;
    return t >= _m(open) && t < _m(close);
  }

  String get hours {
    final d = days >= 7 ? 'Setiap hari' : (days == 6 ? 'Sen-Sab' : 'Sen-Jum');
    return '$d $open-$close';
  }
}

class Quiz {
  final String topic, question, explanation;
  final List<String> options;
  final int answer;
  Quiz(Map<String, dynamic> j)
      : topic = j['topic'],
        question = j['question'],
        explanation = j['explanation'],
        options = List<String>.from(j['options']),
        answer = j['answer'];
}

int scoreQuiz(List<Quiz> qs, List<int> picks) {
  var s = 0;
  for (var i = 0; i < qs.length && i < picks.length; i++) {
    if (picks[i] == qs[i].answer) s++;
  }
  return s;
}

/// Validasi formulir umpan balik (FR-09). Mengembalikan pesan galat atau null.
String? validateFeedback(int rating, String comment) {
  if (rating < 1 || rating > 5) return 'Pilih rating 1 sampai 5 bintang.';
  if (comment.length > 300) return 'Komentar maksimal 300 karakter.';
  if (comment.contains('<') || comment.contains('>')) {
    return 'Karakter < dan > tidak diperbolehkan.';
  }
  return null;
}

/// Layanan yang relevan untuk kategori artikel (tombol "Cari Layanan Terkait").
String serviceForCategory(String c) => const {
      'Ibu dan Anak': 'Imunisasi',
      'Gizi': 'Gizi',
      'Kesehatan Mental': 'Kesehatan Jiwa',
      'P3K': 'IGD',
    }[c] ??
    'Poli Umum';

class Store extends ChangeNotifier {
  List<Article> articles = [];
  List<Facility> facilities = [];
  List<Quiz> quizzes = [];
  Set<String> bookmarks = {};
  List<String> results = [];
  List<String> feedbacks = [];
  bool dark = false;
  bool reminder = false;
  String? error;
  SharedPreferences? _p;

  Future<void> load() async {
    error = null;
    try {
      Future<List<dynamic>> j(String n) async =>
          jsonDecode(await rootBundle.loadString('assets/data/$n.json'));
      articles = (await j('articles')).map((e) => Article(e)).toList();
      facilities = (await j('facilities')).map((e) => Facility(e)).toList();
      quizzes = (await j('quizzes')).map((e) => Quiz(e)).toList();
    } catch (_) {
      error = 'Data gagal dimuat. Periksa aplikasi lalu coba lagi.';
    }
    try {
      _p = await SharedPreferences.getInstance();
      bookmarks = (_p!.getStringList('bm') ?? []).toSet();
      results = _p!.getStringList('res') ?? [];
      feedbacks = _p!.getStringList('fb') ?? [];
      dark = _p!.getBool('dark') ?? false;
      reminder = _p!.getBool('rem') ?? false;
    } catch (_) {}
    notifyListeners();
  }

  void toggleBookmark(String id) {
    bookmarks.contains(id) ? bookmarks.remove(id) : bookmarks.add(id);
    _p?.setStringList('bm', bookmarks.toList());
    notifyListeners();
  }

  void setDark(bool v) {
    dark = v;
    _p?.setBool('dark', v);
    notifyListeners();
  }

  void setReminder(bool v) {
    reminder = v;
    _p?.setBool('rem', v);
    notifyListeners();
  }

  void addResult(String r) {
    results.insert(0, r);
    _p?.setStringList('res', results);
    notifyListeners();
  }

  void addFeedback(int rating, String comment) {
    feedbacks.insert(0, '$rating|$comment'); // anonim, hanya lokal
    _p?.setStringList('fb', feedbacks);
    notifyListeners();
  }
}
