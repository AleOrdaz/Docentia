import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef NotificationTapCallback = void Function(String? payload);

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelId = 'overdue_fees';
  static const _channelName = 'Cuotas vencidas';
  static const _overdueNotificationId = 1001;
  static const _payloadFinance = 'finance';
  static const _prefsLastNotifiedDayKey = 'docentia_overdue_local_notif_day';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  NotificationTapCallback? _onNotificationTap;
  String? _pendingPayload;
  bool _initialized = false;

  set onNotificationTap(NotificationTapCallback? callback) {
    _onNotificationTap = callback;
    final pending = _pendingPayload;
    if (callback != null && pending != null) {
      _pendingPayload = null;
      callback(pending);
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _deliverTap(response.payload);
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Avisos de cuotas vencidas para el docente',
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _deliverTap(launch!.notificationResponse?.payload);
    }
  }

  void _deliverTap(String? payload) {
    final callback = _onNotificationTap;
    if (callback == null) {
      _pendingPayload = payload;
      return;
    }
    callback(payload);
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<bool> wasNotifiedToday({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsLastNotifiedDayKey);
    return saved == _dayKey(now ?? DateTime.now());
  }

  Future<void> markNotifiedToday({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsLastNotifiedDayKey,
      _dayKey(now ?? DateTime.now()),
    );
  }

  Future<void> showOverdueFees({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Avisos de cuotas vencidas para el docente',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: _overdueNotificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: _payloadFinance,
    );
  }

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String get financePayload => _payloadFinance;
}
