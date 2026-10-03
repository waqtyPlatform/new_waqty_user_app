import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/services/local_notification_service.dart';
import 'package:waqty_user_application/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_isSupportedNotificationPlatform) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.initializedNotification();
  await FirebaseNotificationService.showRemoteMessage(message);
}

class FirebaseNotificationService {
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _openedMessageSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || !_isSupportedNotificationPlatform) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await LocalNotificationService.initializedNotification();
    await _requestPermission();
    await _setForegroundPresentationOptions();

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedMessageSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );

    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((_) {});
  }

  Future<String?> getCurrentFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 5),
      );
      if (token == null || token.length > 255) return null;
      return token;
    } catch (_) {
      return null;
    }
  }

  static Future<void> showRemoteMessage(RemoteMessage message) async {
    if (!_shouldShowLocalRemoteMessage) return;

    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        message.data['notification_title']?.toString() ??
        '';
    final body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['notification_body']?.toString() ??
        '';

    await LocalNotificationService.showNotification(
      title: title,
      body: body,
      payload: message.data,
    );
  }

  Future<void> _requestPermission() async {
    try {
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true)
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> _setForegroundPresentationOptions() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (_) {}
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        message.notification != null) {
      return;
    }
    await showRemoteMessage(message);
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    // Notification tap navigation will be handled later by notification types.
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _openedMessageSubscription?.cancel();
  }
}

bool get _isSupportedNotificationPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool get _shouldShowLocalRemoteMessage {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
