import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Pengingat tips harian berbasis notifikasi lokal (tanpa server).
class Notifier {
  static final _p = FlutterLocalNotificationsPlugin();
  static const _id = 1;

  static Future<void> init() => _p.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher')));

  /// Mengembalikan false bila izin notifikasi ditolak.
  static Future<bool> enableDaily(String body) async {
    final android = _p.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    if (!granted) return false;
    await _p.periodicallyShow(
      _id,
      'Tips sehat hari ini',
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails('tips', 'Tips harian',
            channelDescription: 'Pengingat tips kesehatan harian'),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  static Future<void> disable() => _p.cancel(_id);
}
