import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
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

  /// `null` لما الزيارة الحالية مش في الفرع دلوقتي.
  ///
  /// ⚠ **الزيارة مش الحجز.** الاتنين كانوا واحد لما الحالة كانت على الحجز
  /// الأب بس — وساعتها `items.first` كانت بتدّي أخصائي **أول زيارة** حتى
  /// وإنت واقف في التانية، فالشاشة كانت بتقول اسم غلط.
  static InBranchUiModel? forBooking(BookingUiModel booking, DateTime now) {
    final visit = booking.currentVisit(now);
    if (!visit.status.isInBranch) return null;

    final item = visit.items.first;

    if (visit.status == BookingStatus.inProgress) {
      return InBranchUiModel(
        status: visit.status,
        employeeName: item.employeeName,
        // نهاية **الزيارة** مش نهاية أول خدمة — الزيارة اللي فيها خدمتين
        // ورا بعض العميل بيخلص فيها مع آخر واحدة.
        expectedFinishAt: visit.endAt,
        updatedAt: now,
      );
    }

    if (visit.status == BookingStatus.arrived) {
      // لسه ما دخلش الطابور — مفيش تقدير يتقال.
      return InBranchUiModel(
        status: visit.status,
        employeeName: item.employeeName,
        updatedAt: now,
      );
    }

    // `waiting` من غير تقدير — **ده الشكل اللي السيرفر بيوفّره النهاردة**.
    //
    // الحالة `waiting` عمود حقيقي، والتوقّع الزمني لأ: مفيش عمود ولا
    // حساب ولا endpoint. فالسيناريو ده مش «حالة تدهور» نادرة — هو الـ
    // payload المتوقّع يوم الربط، والتاني هو اللي محتاج طلب للباك إند.
    if (MockConfig.scenario == MockScenario.waitingNoEstimate) {
      return InBranchUiModel(
        status: visit.status,
        employeeName: item.employeeName,
        updatedAt: now,
      );
    }

    // التقدير بينزل مع الوقت عشان الشاشة تبان حية في العرض.
    // deterministic من ساعة الجهاز، فمفيش قفزات عشوائية قدام العميل.
    final ticks = (now.minute * 60 + now.second) ~/ 20;
    final step = _cycleSteps - (ticks % _cycleSteps);

    return InBranchUiModel(
      status: visit.status,
      employeeName: item.employeeName,
      estimateLow: Duration(minutes: step),
      estimateHigh: Duration(minutes: step + 10),
      updatedAt: now,
    );
  }
}
