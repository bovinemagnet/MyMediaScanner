import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps [FlutterLocalNotificationsPlugin] to provide a simple API for
/// scheduling and cancelling overdue loan notifications.
///
/// Gracefully degrades on platforms where local notifications are not
/// supported.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  NotificationService.withPlugin(FlutterLocalNotificationsPlugin plugin)
      : _plugin = plugin;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  /// Initialises the notification plugin. Must be called before scheduling.
  Future<void> initialise() async {
    if (_initialised) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(settings);
      _initialised = true;
    } catch (_) {
      // Gracefully degrade on unsupported platforms.
    }
  }

  /// Shows a notification immediately. For scheduled notifications,
  /// the app checks overdue status on startup and shows as needed.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialised) return;

    const androidDetails = AndroidNotificationDetails(
      'overdue_loans',
      'Overdue Loans',
      channelDescription: 'Notifications for overdue lending items',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // Gracefully degrade.
    }
  }

  /// Cancels a previously shown notification.
  Future<void> cancelNotification(int id) async {
    if (!_initialised) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {
      // Gracefully degrade.
    }
  }

  /// Cancels all notifications.
  Future<void> cancelAll() async {
    if (!_initialised) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Gracefully degrade.
    }
  }
}
