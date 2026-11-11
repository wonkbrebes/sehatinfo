import 'package:flutter/material.dart';
import 'models.dart';
import 'notifier.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) => debugPrint('ERROR: ${d.exceptionAsString()}');
  try {
    await Notifier.init();
  } catch (_) {} // fallback: tips harian tetap tampil di Beranda
  final store = Store();
  await store.load();
  runApp(SehatApp(store));
}

ThemeData _theme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), brightness: b),
    );

class SehatApp extends StatelessWidget {
  final Store store;
  const SehatApp(this.store, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) => MaterialApp(
          title: 'SehatInfo',
          debugShowCheckedModeBanner: false,
          themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: Shell(store),
        ),
      );
}

class Shell extends StatefulWidget {
  final Store store;
  const Shell(this.store, {super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    if (s.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(s.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: s.load, child: const Text('Coba Lagi')),
            ]),
          ),
        ),
      );
    }
    final pages = [
      HomePage(s, onServices: () => setState(() => i = 2)),
      ArticlesPage(s),
      FacilitiesPage(s),
      ProfilePage(s),
    ];
    return Scaffold(
      body: IndexedStack(index: i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Edukasi'),
          NavigationDestination(icon: Icon(Icons.local_hospital_outlined), label: 'Layanan'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
