import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/services/local_notification_service.dart';
import 'package:waqty_user_application/core/services/push_router.dart';
import 'package:waqty_user_application/features/splash/data/repo/app_gate_repo.dart';
import 'package:waqty_user_application/firebase_options.dart';

/// **معالج رسايل الخلفية.**
///
/// ⚠ لازم يبقى **دالة عليا** (top-level) و`@pragma('vm:entry-point')` —
/// أندرويد بيشغّل عزلة داردت جديدة تمامًا للرسالة دي، ومابيقدرش يوصل
/// لدالة جوّه كلاس.
///
/// وبيفضل فاضي بقصد: أندرويد بيرسم الإشعار بنفسه في الخلفية، والتوجيه
/// بيحصل لما العميل يدوس (`onMessageOpenedApp`). أي شغل هنا بيتنفّذ في
/// عزلة مالهاش شجرة widgets ولا `navigatorKey`.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) debugPrint('push في الخلفية: ${message.data}');
}

/// إشعارات الـpush — **نص الأبلكيشن كامل**.
///
/// ## الحالة
///
/// | الطرف | الحالة |
/// |---|---|
/// | تسجيل التوكن | ✅ `POST /api/v1/app/device-token` |
/// | استقبال الرسايل | ✅ مقدمة · خلفية · مقفول |
/// | رسم إشعار المقدمة | ✅ `LocalNotificationService` |
/// | التوجيه للشاشة | ✅ `PushRouter` — مختبَر |
/// | **إعداد Firebase** | ❌ `firebase_options.dart` لسه فاضي |
/// | **مرسل الباك-إند** | ❌ مفيش `app/Listeners` ولا مرسل FCM |
///
/// الأبلكيشن **بيقلع ويشتغل عادي من غير الاتنين** — [init] بترجع من غير ما
/// تعمل حاجة لو `DefaultFirebaseOptions.isConfigured` بـ`false`.
///
/// ## ليه ده مهم أكتر من إشعار عادي
///
/// **فلوين بتوقيت محدود بيعتمدوا عليه:** إعادة توزيع الحجز (مهلة ١٥ دقيقة،
/// ٣ محاولات) وعرض قايمة الانتظار (٥ دقايق). العميل اللي بيعرف بالمهلة
/// بالصدفة لما يفتح الأبلكيشن، المهلة عنده مالهاش معنى — والفرع بيستنتج
/// إن الفيتشر مش شغالة.
class FirebaseNotificationService {
  const FirebaseNotificationService._();

  /// اشتغلت خلاص؟ — الأبلكيشن بيقلع مرة واحدة بس دي حماية من النداء المكرر.
  static bool _ready = false;

  /// **بتشتغل كلها أو مابتعملش حاجة.**
  ///
  /// ⚠ **الفشل بيتبلع بالكامل.** الإشعارات إضافة مش شرط تشغيل: مشروع
  /// Firebase مش متظبط، أو صلاحية مرفوضة، أو جهاز من غير Google Play —
  /// كلهم أسباب مشروعة، ومفيش واحد فيهم يستاهل إن الأبلكيشن مايقلعش.
  static Future<void> init(AppGateRepo repo) async {
    if (_ready) return;

    if (!DefaultFirebaseOptions.isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'FirebaseNotificationService: الإشعارات مطفية — '
          'شغّل `flutterfire configure` وامل firebase_options.dart.',
        );
      }
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await LocalNotificationService.init();

      final messaging = FirebaseMessaging.instance;

      // ⚠ **أندرويد ١٣+ محتاج صلاحية.** من غيرها التوكن بيتولّد والرسايل
      // بتوصل بس **مفيش إشعار بيتعرض** — أسوأ حالة: كل حاجة شكلها شغّالة
      // والعميل مش شايف حاجة.
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      // الأبلكيشن مفتوح → أندرويد مابيرسمش، فبنرسم إحنا.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // الأبلكيشن في الخلفية والعميل داس الإشعار.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => PushRouter.open(message.data),
      );

      // ⚠ **الأبلكيشن كان مقفول خالص والعميل فتحه من الإشعار.**
      //
      // الحالة دي مابتعديش على `onMessageOpenedApp` — لازم تتسأل مرة
      // واحدة عند الإقلاع، وإلا الدوسة بتفتح الرئيسية وخلاص.
      final initial = await messaging.getInitialMessage();
      if (initial != null) PushRouter.open(initial.data);

      await _registerToken(repo, messaging);

      // ⚠ **التوكن بيتغيّر.** أندرويد بيدوّره لما الأبلكيشن يتنصّب من
      // جديد أو الداتا تتمسح. من غير السطر ده، السيرفر بيفضل ماسك توكن
      // ميت والإشعارات تقف من غير أي علامة.
      messaging.onTokenRefresh.listen((token) => repo.registerDeviceToken(token));

      _ready = true;
    } catch (error) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: فشل — $error');
    }
  }

  static Future<void> _registerToken(
    AppGateRepo repo,
    FirebaseMessaging messaging,
  ) async {
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;

    await repo.registerDeviceToken(token);
  }

  /// رسالة والأبلكيشن مفتوح — بنرسمها بإيدنا.
  static void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;

    // ⚠ **رسالة داتا-فقط مابتترسمش.** السيرفر ممكن يبعت حمولة من غير
    // `notification` عشان الأبلكيشن يتصرّف من غير ما يزعج العميل — نحترم
    // ده بدل ما نخترع عنوان.
    if (notification == null) return;

    LocalNotificationService.show(
      title: notification.title ?? 'واقتي',
      body: notification.body ?? '',
      payload: message.data,
    );
  }
}
