import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    _locale = locale;
  }

  AppLocalizations get _l10n => lookupAppLocalizations(_locale);

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }

  Future<void> scheduleExpiryNotification({
    required String ingredientId,
    required String ingredientName,
    required DateTime expiryDate,
  }) async {
    await cancelExpiryNotification(ingredientId);

    final notificationId = ingredientId.hashCode.abs();
    final l10n = _l10n;
    
    final now = DateTime.now();
    final notificationTime = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      8,
      0,
    );

    if (notificationTime.isBefore(now)) {
      final today = DateTime(now.year, now.month, now.day);
      final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
      
      if (!expiryDay.isBefore(today)) {
        await _showImmediateNotification(
          id: notificationId,
          title: l10n.notificationExpiresTitle(ingredientName),
          body: l10n.notificationExpiresBody,
        );
      }
      return;
    }

    await _notifications.zonedSchedule(
      notificationId,
      l10n.notificationExpiresTitle(ingredientName),
      l10n.notificationExpiresBody,
      tz.TZDateTime.from(notificationTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          l10n.notificationChannelName,
          channelDescription: l10n.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showTestNotification() async {
    final l10n = _l10n;
    await _showImmediateNotification(
      id: 99999,
      title: l10n.notificationTestTitle,
      body: l10n.notificationTestBody,
    );
  }

  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final l10n = _l10n;
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          l10n.notificationChannelName,
          channelDescription: l10n.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelExpiryNotification(String ingredientId) async {
    final notificationId = ingredientId.hashCode.abs();
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
