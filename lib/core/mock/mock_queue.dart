import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';

/// طابور وهمي **بيتحرّك بساعة الحيط**.
///
/// ## ليه بيتحرّك لوحده
///
/// طابور ثابت مابيثبتش إن الميزة شغّالة. ده بيتقدّم **دور كل ٤٥ ثانية
/// حقيقية**، فتقدر تسيب الشاشة مفتوحة دقيقتين وتشوف الحالة بتعدّي
/// `waiting` → `soon` → `yourTurn` قدامك، من غير باك إند وقبل ما الـ
/// endpoint يتكتب.
///
/// ## الـ endpoint اللي هيحل محل ده
///
/// ```
/// GET /api/user/bookings/{uuid}/queue
/// → { position, now_serving, ahead_of_me,
///     est_low_minutes, est_high_minutes, updated_at, state }
/// ```
///
/// وقت التوصيل بنغيّر سطر النداء بس — الـ Cubit والـ states والـ widgets
/// كلهم مكتوبين على شكلهم النهائي.
///
/// **بس خلي بالك:** في الإنتاج المصدر الحقيقي هو الموظف لما يعلّم
/// `arrived` و`in_service`. وأبلكيشن الموظف دلوقتي **بيبعت `completed`
/// على طول** ومابيمرش عليهم — فده الحلقة الناقصة مش الـ endpoint.
class MockQueue {
  MockQueue._();

  /// كل قد إيه الطابور بيتقدّم دور.
  static const Duration advanceEvery = Duration(seconds: 45);

  /// متوسط مدة الخدمة اللي بنحسب بيه التقدير.
  static const int _avgServiceMinutes = 35;

  /// ترتيب العميل الثابت في طابور النهاردة.
  static const int _myPosition = 7;

  /// بيحسب حالة الطابور من الوقت الحالي.
  ///
  /// دالة صافية في [now] — فالاختبار بيبقى تمرير وقت مش انتظار.
  static QueueUiModel forBooking(BookingUiModel booking, DateTime now) {
    final isToday =
        booking.startAt.year == now.year &&
        booking.startAt.month == now.month &&
        booking.startAt.day == now.day;

    if (!isToday) {
      return QueueUiModel(
        myPosition: _myPosition,
        nowServing: 0,
        estimateLow: Duration.zero,
        estimateHigh: Duration.zero,
        updatedAt: now,
        state: QueueState.notToday,
      );
    }

    // **الطابور بيلفّ.**
    //
    // أول ما ربطناه بساعة فتح ثابتة (٩ الصبح)، أي حد بيفتح الأبلكيشن
    // بالليل كان بيلاقي الطابور خلص من ساعات — وده مايوريش الميزة.
    //
    // هنا بيلفّ على دورة كاملة كل `(myPosition + 2) × ٤٥ ثانية` ≈ ٦ دقايق،
    // فأي وقت تفتح فيه بتلاقي الطابور في نص حتة، ولو قعدت بتتفرّج بتعدّي
    // على الحالات كلها بالترتيب.
    //
    // **الـ endpoint الحقيقي مش هيلفّ** — ده سلوك عرض بس، والحساب اللي
    // تحته (`ahead` والتقدير والحالات) هو نفسه اللي هيشتغل على داتا حقيقية.
    final cycleLength = _myPosition + 2;
    final ticks = now.millisecondsSinceEpoch ~/ advanceEvery.inMilliseconds;
    final nowServing = ticks % cycleLength;

    final ahead = _myPosition - nowServing - 1;

    final QueueState state;
    if (nowServing > _myPosition) {
      state = QueueState.done;
    } else if (nowServing == _myPosition) {
      state = QueueState.inService;
    } else if (ahead <= 0) {
      state = QueueState.yourTurn;
    } else if (ahead <= 2) {
      state = QueueState.soon;
    } else {
      state = QueueState.waiting;
    }

    // **التقدير مدى.** المدى بيتوسّع كل ما عدد اللي قدامك يزيد — لأن
    // كل واحد قدامك بيضيف عدم يقين، مش دقايق ثابتة.
    final centre = ahead * _avgServiceMinutes;
    final spread = (centre * 0.25).round();

    return QueueUiModel(
      myPosition: _myPosition,
      nowServing: nowServing,
      estimateLow: Duration(minutes: centre - spread),
      estimateHigh: Duration(minutes: centre + spread),
      updatedAt: now,
      state: state,
    );
  }
}
