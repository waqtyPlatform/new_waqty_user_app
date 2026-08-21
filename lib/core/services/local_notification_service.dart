import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:waqty_user_application/core/services/push_router.dart';

/// رسم الإشعار **وقت ما الأبلكيشن مفتوح**.
///
/// ## ليه محتاجينه أصلاً
///
/// أندرويد **مابيعرضش** إشعار FCM لما الأبلكيشن يبقى في المقدمة — الرسالة
/// بتوصل لـ`onMessage` وخلاص. لو مارسمناهاش بنفسنا، العميل اللي فاتح
/// الأبلكيشن على شاشة تانية مش هياخد باله إن فيه اقتراح بديل بمهلة ١٥
/// دقيقة.
///
/// ودي بالظبط الحالة اللي بتحصل كتير: العميل بيفتح الأبلكيشن يشوف حجزه،
/// والفرع بيقترح البديل في نفس اللحظة.
class LocalNotificationService {
  const LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// **قناة واحدة بأولوية عالية.**
  ///
  /// ⚠ الإشعارات اللي الأبلكيشن بيبعتها كلها **بتوقيت محدود** (مهلة
  /// إعادة التوزيع ١٥ دقيقة، وعرض قايمة الانتظار ٥). قناة بأولوية واطية
  /// معناها إن أندرويد يأجّلها — وإشعار مهلة بيوصل متأخر مالوش لازمة.
  ///
  /// لو اتضاف نوع مش عاجل (عروض تسويقية مثلاً) بياخد قناته لوحده عشان
  /// العميل يقدر يقفله من غير ما يقفل المهم.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'waqty_bookings',
    'حجوزاتك',
    description: 'تغييرات على حجزك ومواعيد قايمة الانتظار',
    importance: Importance.high,
  );

  static String get channelId => _channel.id;

  static bool _ready = false;

  static Future<void> init() async {
    if (_ready) return;

    await _plugin.initialize(
      const InitializationSettings(
        // `@mipmap/ic_launcher` أيقونة الأبلكيشن — موجودة في كل مشروع
        // فلاتر، فمفيش أصل جديد لازم يتضاف.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      // الدوس على الإشعار وهو معروض من الأبلكيشن نفسه.
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _ready = true;
  }

  /// بيرسم إشعار من حمولة FCM.
  ///
  /// [payload] بيتخزّن كنص JSON عشان [_onTap] يقدر يوجّه بيه بعدين —
  /// الـplugin بيسمح بنص واحد بس.
  static Future<void> show({
    required String title,
    required String body,
    Map<String, dynamic> payload = const {},
  }) async {
    if (!_ready) await init();

    await _plugin.show(
      // معرّف فريد بس مش متزايد للأبد — الثواني كافية والتكرار في نفس
      // الثانية بيستبدل إشعار، وده مقبول.
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(payload),
    );
  }

  static void _onTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      PushRouter.open(decoded);
    } catch (error) {
      // حمولة مكسورة مش سبب لكراش — الإشعار اتعرض والدوسة مابتعملش حاجة.
      if (kDebugMode) debugPrint('LocalNotificationService: حمولة مكسورة $error');
    }
  }
}
