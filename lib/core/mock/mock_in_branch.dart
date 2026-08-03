import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';

/// MOCK — حالة العميل جوه الفرع.
///
/// ## نص ده حقيقي ونص مقترح — والفرق مكتوب
///
/// **الحالة حقيقية.** `arrived` و`waiting` و`in_progress` أعمدة فعلية في
/// السيرفر، والفرع بيحرّكها من الداشبورد. فبناخدها من `booking.status`
/// زي ما هي — مفيش اختراع هنا، ويوم الربط السطر ده بيتشال وخلاص.
///
/// **التقدير الزمني PROPOSED — مفيش endpoint ليه.**
/// السيرفر عنده `arrived_at` (عمود على `booking_visits`) و
/// `actual_started_at`، وبيحسب منهم `waiting_time_minutes` في
/// `BookingVisitResource` — بس ده **قعد مستني قد إيه** بعد ما الخدمة
/// تبدأ، مش **هيستنى قد إيه**. التوقّع نفسه مش موجود لا كعمود ولا كحساب.
///
/// وكمان `visits` **مش eager-loaded** على `GET /user/bookings`
/// (`BookingRepository::paginateUser`)، فحتى الوقت المنقضي مش بيوصل
/// لليستة أصلاً — بيوصل لشاشة التفاصيل بس.
///
/// عشان كده التقدير هنا مضروب بالكامل، والسؤال اللي الجلسة بتجاوبه:
/// **هل الجملة دي بتتصدّق أكتر من رقم الدور؟** لو أيوة، بنروح للباك إند
/// بحجة مش برأي.
class MockInBranch {
  MockInBranch._();

  /// طول دورة التقدير — ٦ دقايق، بينزل ويلف من الأول.
  static const int _cycleSteps = 18;

  /// `null` لما الحجز مش في الفرع دلوقتي.
  static InBranchUiModel? forBooking(BookingUiModel booking, DateTime now) {
    if (!booking.status.isInBranch) return null;

    final item = booking.items.first;

    if (booking.status == BookingStatus.inProgress) {
      return InBranchUiModel(
        status: booking.status,
        employeeName: item.employeeName,
        expectedFinishAt: item.endAt,
        updatedAt: now,
      );
    }

    if (booking.status == BookingStatus.arrived) {
      // لسه ما دخلش الطابور — مفيش تقدير يتقال.
      return InBranchUiModel(
        status: booking.status,
        employeeName: item.employeeName,
        updatedAt: now,
      );
    }

    // `waiting` — التقدير بينزل مع الوقت عشان الشاشة تبان حية في العرض.
    // deterministic من ساعة الجهاز، فمفيش قفزات عشوائية قدام العميل.
    final ticks = (now.minute * 60 + now.second) ~/ 20;
    final step = _cycleSteps - (ticks % _cycleSteps);

    return InBranchUiModel(
      status: booking.status,
      employeeName: item.employeeName,
      estimateLow: Duration(minutes: step),
      estimateHigh: Duration(minutes: step + 10),
      updatedAt: now,
    );
  }
}
