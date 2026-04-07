import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  // Initialise asynchronously; callers should await initialise() on first use
  // or the service gracefully degrades if not yet initialised.
  service.initialise();
  return service;
});
