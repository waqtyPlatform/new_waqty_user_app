import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/my_app.dart';

/// وجهة إشعار — راوت وأرجومنتس.
class PushDestination {
  final String route;
  final Map<String, dynamic> arguments;

  const PushDestination(this.route, [this.arguments = const {}]);
}

/// **بيحوّل حمولة الإشعار لراوت.**
///
/// ## ⚠ الجزء ده شغّال، والإرسال لأ
///
/// مفيش مرسل push في المنظومة كلها:
///
///  • `AppDeviceToken` بتتجمع من `POST /api/v1/app/device-token` و**محدش
///    بيقراها** — مفيش `app/Listeners` ولا `EventServiceProvider`.
///  • `BookingReassignmentLifecycleEvent` بيتبعت بفلاجات `notifyCustomer`
///    في الفراغ.
///  • الأبلكيشن مافيهوش `firebase_core` ولا `google-services.json` —
///    وإضافتهم محتاجة مشروع Firebase حقيقي.
///
/// فالكلاس ده **جاهز ومختبَر ومش متنادى**. لما المرسل ينزل، الربط بيبقى
/// سطر واحد: `FirebaseMessaging.onMessageOpenedApp.listen((m) =>
/// PushRouter.destinationOf(m.data))`.
///
/// ## ليه اتكتب دلوقتي مش وقتها
///
/// الفلوين اللي محتاجين push (**إعادة التوزيع بمهلة ١٥ دقيقة**، وقايمة
/// الانتظار بمهلة ٥) اتبنوا في المراحل اللي فاتت وبيتعوّضوا ببانرات
/// وإعادة تحميل عند فتح الأبلكيشن. لما المرسل يوصل، اللي ناقص هو الربط
/// بس — والقواعد اللي هنا (أنهي نوع بيروح فين) هي الجزء اللي بيتنسى.
class PushRouter {
  const PushRouter._();

  /// بيقرا `type` من الحمولة ويرجّع الوجهة، أو `null` لو النوع مش معروف.
  ///
  /// ⚠ **النوع المش معروف بيرجّع `null` مش الرئيسية.** إشعار من نسخة
  /// سيرفر أحدث بيفتح شاشة عشوائية أوحش من إنه مايفتحش حاجة — العميل
  /// ياخد باله إن الأبلكيشن محتاج تحديث بدل ما يفتكر إن الإشعار غلط.
  static PushDestination? destinationOf(Map<String, dynamic> payload) {
    final type = payload['type']?.toString() ?? '';
    final uuid = payload['uuid']?.toString() ?? '';

    return switch (type) {
      // اقتراح بديل لحجز — **أهم إشعار في الأبلكيشن**، المهلة ١٥ دقيقة.
      'booking_reassignment' ||
      'reassignment_proposal' => const PushDestination(
        Routes.reassignmentScreen,
      ),

      // عرض ميعاد من قايمة الانتظار — المهلة ٥ دقايق.
      // مفيش راوت مستقل: القايمة بتتفتح من تبويب الحجوزات.
      'waitlist_offer' || 'waitlist' => const PushDestination(
        Routes.buttonNavigationBarScreen,
        {'initialIndex': 2},
      ),

      // تغيير في حجز (تأكيد · إلغاء · تذكير).
      'booking' || 'booking_status' => uuid.isEmpty
          ? null
          : PushDestination(Routes.bookingDetailsScreen, {'bookingUuid': uuid}),

      _ => null,
    };
  }

  /// **بيفتح الشاشة اللي الإشعار بيشاور عليها.**
  ///
  /// ⚠ **بيستخدم `navigatorKey` مش `context`.** الإشعار بيتداس والأبلكيشن
  /// ممكن يكون في الخلفية أو مقفول خالص — مفيش `context` في اليد ساعتها.
  ///
  /// ⚠ **`pushNamed` مش `pushNamedAndRemoveUntil`.** العميل لازم يقدر
  /// يرجع لمكانه بزرار الرجوع؛ مسح المكدس بياخده لشاشة مالهاش رجوع.
  static void open(Map<String, dynamic> payload) {
    final destination = destinationOf(payload);
    if (destination == null) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    context.pushNamed(destination.route, arguments: destination.arguments);
  }
}
