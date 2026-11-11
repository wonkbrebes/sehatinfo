import 'package:flutter/material.dart';
import 'models.dart';
import 'notifier.dart';

const disclaimer =
    'Konten ini bersifat edukasi dan tidak menggantikan konsultasi dengan tenaga kesehatan. '
    'Pada kondisi darurat, segera ke IGD atau hubungi layanan darurat.';
const simLabel = 'Data simulasi untuk keperluan akademik.';

const tips = [
  'Cuci tangan dengan sabun selama 20 detik.',
  'Minum air putih yang cukup sepanjang hari.',
  'Bergerak aktif minimal 150 menit per minggu.',
  'Kurangi gula, garam, dan lemak berlebih.',
  'Tidur 7 sampai 8 jam agar tubuh pulih.',
];

void go(BuildContext c, Widget w) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => w));

void note(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

// ---------------- Beranda (FR-01) ----------------
class HomePage extends StatelessWidget {
  final Store s;
  final VoidCallback onServices;
  const HomePage(this.s, {required this.onServices, super.key});

  @override
  Widget build(BuildContext c) {
    final cats = s.articles.map((a) => a.category).toSet().toList();
    final tip = tips[DateTime.now().day % tips.length];
    return Scaffold(
      appBar: AppBar(title: const Text('SehatInfo')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: Theme.of(c).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tips hari ini', style: Theme.of(c).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(tip, style: Theme.of(c).textTheme.bodyLarge),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Kategori', style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final k in cats)
            ActionChip(
                label: Text(k),
                onPressed: () => go(c, ArticlesPage(s, category: k))),
        ]),
        const SizedBox(height: 16),
        Text('Artikel terbaru', style: Theme.of(c).textTheme.titleMedium),
        for (final a in s.articles.take(3)) ArticleTile(a, s),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onServices,
          icon: const Icon(Icons.local_hospital_outlined),
          label: const Text('Cari layanan kesehatan'),
        ),
        const SizedBox(height: 12),
        Text(simLabel, style: Theme.of(c).textTheme.bodySmall),
      ]),
    );
  }
}

// ---------------- Artikel (FR-02, 03, 04) ----------------
class ArticleTile extends StatelessWidget {
  final Article a;
  final Store s;
  const ArticleTile(this.a, this.s, {super.key});

  @override
  Widget build(BuildContext c) => Card(
        child: ListTile(
          title: Text(a.title),
          subtitle: Text('${a.category}, ${a.minutes} menit baca\n${a.summary}'),
          isThreeLine: true,
          trailing: Icon(
              s.bookmarks.contains(a.id) ? Icons.bookmark : Icons.bookmark_border),
          onTap: () => go(c, ArticleDetail(s, a)),
        ),
      );
}

class ArticlesPage extends StatefulWidget {
  final Store s;
  final String? category;
  const ArticlesPage(this.s, {this.category, super.key});
  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  String q = '';
  String? cat;

  @override
  void initState() {
    super.initState();
    cat = widget.category;
  }

  @override
  Widget build(BuildContext c) {
    final s = widget.s;
    final cats = s.articles.map((a) => a.category).toSet().toList();
    final list = s.articles
        .where((a) =>
            (cat == null || a.category == cat) &&
            (q.isEmpty || '${a.title} ${a.summary}'.toLowerCase().contains(q.toLowerCase())))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Edukasi Kesehatan')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            maxLength: 50,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari artikel',
                counterText: '',
                border: OutlineInputBorder()),
            onChanged: (v) => setState(() => q = v.trim()),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final k in [null, ...cats])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                        label: Text(k ?? 'Semua'),
                        selected: cat == k,
                        onSelected: (_) => setState(() => cat = k)),
                  ),
              ]),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Artikel tidak ditemukan. Coba kata kunci lain.'))
              : ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                  for (final a in list) ArticleTile(a, s),
                ]),
        ),
      ]),
    );
  }
}

class ArticleDetail extends StatelessWidget {
  final Store s;
  final Article a;
  const ArticleDetail(this.s, this.a, {super.key});

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: s,
        builder: (_, __) {
          final qs = s.quizzes.where((q) => q.topic == a.category).toList();
          final saved = s.bookmarks.contains(a.id);
          return Scaffold(
            appBar: AppBar(title: Text(a.category), actions: [
              IconButton(
                tooltip: saved ? 'Hapus dari favorit' : 'Simpan ke favorit',
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () {
                  s.toggleBookmark(a.id);
                  note(c, saved ? 'Dihapus dari favorit' : 'Disimpan ke favorit');
                },
              ),
            ]),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              Text(a.title, style: Theme.of(c).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('${a.minutes} menit baca, diperbarui ${a.updated}',
                  style: Theme.of(c).textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(a.content, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 16),
              Text('Sumber: ${a.source}', style: Theme.of(c).textTheme.bodySmall),
              const SizedBox(height: 8),
              Card(
                  color: Theme.of(c).colorScheme.tertiaryContainer,
                  child: const Padding(padding: EdgeInsets.all(12), child: Text(disclaimer))),
              const SizedBox(height: 8),
              if (qs.isNotEmpty)
                FilledButton.icon(
                    onPressed: () => go(c, QuizPage(s, a.category, qs)),
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Kerjakan kuis')),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                  onPressed: () => go(c, FacilitiesPage(s, service: serviceForCategory(a.category))),
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: const Text('Cari layanan terkait')),
            ]),
          );
        },
      );
}

// ---------------- Layanan (FR-05, 06) ----------------
const typeLabel = {'puskesmas': 'Puskesmas', 'klinik': 'Klinik', 'rs': 'Rumah Sakit'};

class FacilitiesPage extends StatefulWidget {
  final Store s;
  final String? service;
  const FacilitiesPage(this.s, {this.service, super.key});
  @override
  State<FacilitiesPage> createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  String? type, service;

  @override
  void initState() {
    super.initState();
    service = widget.service;
  }

  @override
  Widget build(BuildContext c) {
    final s = widget.s;
    final now = DateTime.now();
    final services = (s.facilities.expand((f) => f.services).toSet().toList())..sort();
    final list = s.facilities
        .where((f) => (type == null || f.type == type) && (service == null || f.services.contains(service)))
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    Widget chips(List<String?> vals, String? sel, void Function(String?) on, [String Function(String)? lbl]) =>
        SizedBox(
          height: 48,
          child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final v in vals)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                        label: Text(v == null ? 'Semua' : (lbl?.call(v) ?? v)),
                        selected: sel == v,
                        onSelected: (_) => setState(() => on(v))),
                  ),
              ]),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Layanan Kesehatan')),
      body: Column(children: [
        chips([null, ...typeLabel.keys], type, (v) => type = v, (v) => typeLabel[v]!),
        chips([null, ...services], service, (v) => service = v),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(simLabel, style: Theme.of(c).textTheme.bodySmall))),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Belum ada fasilitas dengan filter ini. Ubah filter Anda.'))
              : ListView(padding: const EdgeInsets.all(12), children: [
                  for (final f in list)
                    Card(
                      child: ListTile(
                        title: Text(f.name),
                        subtitle: Text('${typeLabel[f.type]}, ${f.km} km\n${f.hours}'),
                        isThreeLine: true,
                        trailing: f.isOpen(now)
                            ? const Chip(avatar: Icon(Icons.check_circle, size: 18), label: Text('Buka'))
                            : const Chip(avatar: Icon(Icons.cancel_outlined, size: 18), label: Text('Tutup')),
                        onTap: () => go(c, FacilityDetail(f)),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class FacilityDetail extends StatelessWidget {
  final Facility f;
  const FacilityDetail(this.f, {super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Detail Fasilitas')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(f.name, style: Theme.of(c).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(simLabel, style: Theme.of(c).textTheme.bodySmall),
          const SizedBox(height: 12),
          ListTile(leading: const Icon(Icons.place_outlined), title: Text(f.address), subtitle: Text('${f.km} km (jarak simulasi)')),
          ListTile(leading: const Icon(Icons.schedule), title: Text(f.hours), subtitle: Text(f.isOpen(DateTime.now()) ? 'Sedang buka' : 'Sedang tutup')),
          ListTile(leading: const Icon(Icons.phone_outlined), title: Text(f.phone)),
          const SizedBox(height: 8),
          Text('Layanan', style: Theme.of(c).textTheme.titleMedium),
          Wrap(spacing: 8, children: [for (final v in f.services) Chip(label: Text(v))]),
          const SizedBox(height: 12),
          Text('Jadwal poli', style: Theme.of(c).textTheme.titleMedium),
          for (final v in f.schedule) ListTile(dense: true, leading: const Icon(Icons.event_note_outlined), title: Text(v)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: () => note(c, 'Simulasi: memanggil ${f.phone}'), icon: const Icon(Icons.call), label: const Text('Telepon'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => note(c, 'Simulasi: membuka petunjuk arah'), icon: const Icon(Icons.directions), label: const Text('Petunjuk arah'))),
          ]),
        ]),
      );
}

// ---------------- Kuis (FR-07) ----------------
class QuizPage extends StatefulWidget {
  final Store s;
  final String topic;
  final List<Quiz> qs;
  const QuizPage(this.s, this.topic, this.qs, {super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int i = 0;
  int? pick;
  final picks = <int>[];
  bool done = false;

  void next() {
    picks.add(pick!);
    if (i == widget.qs.length - 1) {
      widget.s.addResult('${widget.topic}: ${scoreQuiz(widget.qs, picks)}/${widget.qs.length}');
      setState(() => done = true);
    } else {
      setState(() {
        i++;
        pick = null;
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    final qs = widget.qs;
    if (done) {
      return Scaffold(
        appBar: AppBar(title: Text('Hasil kuis: ${widget.topic}')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Skor ${scoreQuiz(qs, picks)} dari ${qs.length}', style: Theme.of(c).textTheme.headlineMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Selesai')),
          ]),
        ),
      );
    }
    final q = qs[i];
    return Scaffold(
      appBar: AppBar(title: Text('Kuis: ${widget.topic}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        LinearProgressIndicator(value: (i + 1) / qs.length),
        const SizedBox(height: 16),
        Text('Soal ${i + 1} dari ${qs.length}', style: Theme.of(c).textTheme.bodySmall),
        Text(q.question, style: Theme.of(c).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (var k = 0; k < q.options.length; k++)
          Card(
            color: pick == null ? null : (k == q.answer ? Colors.green.withAlpha(70) : (k == pick ? Colors.red.withAlpha(70) : null)),
            child: ListTile(
              title: Text(q.options[k]),
              trailing: pick == null ? null : (k == q.answer ? const Icon(Icons.check_circle) : (k == pick ? const Icon(Icons.cancel) : null)),
              onTap: pick == null ? () => setState(() => pick = k) : null,
            ),
          ),
        if (pick != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${pick == q.answer ? "Benar." : "Kurang tepat."} ${q.explanation}'),
          ),
        FilledButton(onPressed: pick == null ? null : next, child: Text(i == qs.length - 1 ? 'Lihat skor' : 'Lanjut')),
        const SizedBox(height: 8),
        Text(disclaimer, style: Theme.of(c).textTheme.bodySmall),
      ]),
    );
  }
}

// ---------------- Profil, Bookmark, Umpan Balik, Tentang (FR-09, 10, 12) ----------------
class ProfilePage extends StatelessWidget {
  final Store s;
  const ProfilePage(this.s, {super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Profil dan Pengaturan')),
        body: ListView(children: [
          SwitchListTile(title: const Text('Mode gelap'), value: s.dark, onChanged: s.setDark),
          SwitchListTile(
            title: const Text('Pengingat tips harian'),
            subtitle: const Text('Satu notifikasi setiap hari'),
            value: s.reminder,
            onChanged: (v) async {
              var ok = true;
              try {
                if (v) {
                  ok = await Notifier.enableDaily(tips[DateTime.now().day % tips.length]);
                } else {
                  await Notifier.disable();
                }
              } catch (_) {
                ok = false;
              }
              if (ok) {
                s.setReminder(v);
              } else if (c.mounted) {
                note(c, 'Pengingat tidak dapat diaktifkan. Periksa izin notifikasi.');
              }
            },
          ),
          ListTile(leading: const Icon(Icons.bookmark_outline), title: const Text('Artikel favorit'), subtitle: Text('${s.bookmarks.length} tersimpan'), onTap: () => go(c, BookmarksPage(s))),
          ExpansionTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat kuis'),
            children: s.results.isEmpty
                ? [const ListTile(title: Text('Belum ada kuis. Kerjakan kuis dari halaman artikel.'))]
                : [for (final r in s.results) ListTile(dense: true, title: Text(r))],
          ),
          ListTile(leading: const Icon(Icons.rate_review_outlined), title: const Text('Umpan balik'), onTap: () => go(c, FeedbackPage(s))),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Tentang dan privasi'), onTap: () => go(c, const AboutPage())),
        ]),
      );
}

class BookmarksPage extends StatelessWidget {
  final Store s;
  const BookmarksPage(this.s, {super.key});

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: s,
        builder: (_, __) {
          final list = s.articles.where((a) => s.bookmarks.contains(a.id)).toList();
          return Scaffold(
            appBar: AppBar(title: const Text('Artikel favorit')),
            body: list.isEmpty
                ? const Center(child: Text('Belum ada favorit. Ketuk ikon bookmark pada artikel.'))
                : ListView(padding: const EdgeInsets.all(12), children: [for (final a in list) ArticleTile(a, s)]),
          );
        },
      );
}

class FeedbackPage extends StatefulWidget {
  final Store s;
  const FeedbackPage(this.s, {super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final ctrl = TextEditingController();
  String? err;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void submit() {
    final e = validateFeedback(rating, ctrl.text.trim());
    setState(() => err = e);
    if (e == null) {
      widget.s.addFeedback(rating, ctrl.text.trim());
      note(context, 'Terima kasih atas masukan Anda.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Umpan balik')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Seberapa membantu aplikasi ini?'),
          Row(children: [
            for (var k = 1; k <= 5; k++)
              IconButton(
                tooltip: '$k bintang',
                icon: Icon(k <= rating ? Icons.star : Icons.star_border),
                onPressed: () => setState(() => rating = k),
              ),
          ]),
          TextField(
            controller: ctrl,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(labelText: 'Komentar (opsional)', border: const OutlineInputBorder(), errorText: err),
          ),
          const SizedBox(height: 8),
          const Text('Masukan disimpan anonim hanya di perangkat Anda.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: submit, child: const Text('Kirim umpan balik')),
        ]),
      );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext c) {
    Widget h(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 4), child: Text(t, style: Theme.of(c).textTheme.titleMedium));
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang dan privasi')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('SehatInfo adalah prototipe akademik (IF2371054) untuk edukasi kesehatan dan informasi layanan.'),
        h('Data yang disimpan'),
        const Text('Favorit artikel, riwayat skor kuis, umpan balik anonim, dan pilihan tema. Semua hanya di perangkat Anda dan tidak dikirim ke mana pun.'),
        h('Data yang tidak dikumpulkan'),
        const Text('Nama, nomor telepon, NIK, lokasi, atau data medis pribadi. Tidak ada pelacakan maupun iklan.'),
        h('Data simulasi'),
        const Text('Seluruh fasilitas, jadwal, dan jarak adalah data contoh. Konten edukasi merupakan ringkasan dari sumber resmi dan dapat tidak mutakhir.'),
        h('Keterbatasan'),
        const Text('Tidak terhubung ke sistem rumah sakit, tidak melakukan diagnosis, dan tidak menyediakan pendaftaran antrean nyata.'),
        h('Peringatan medis'),
        const Text(disclaimer),
      ]),
    );
  }
}
