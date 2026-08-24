import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// إشعار نهاية مش مكتملة — **بيتقفل، مش أرشيف**.
///
/// ## ليه ده مش صف في القايمة
///
/// «السابقة» كانت بتجمّع المكتمل والملغي واللي ما حضرش. التلاتة نهايات
/// مختلفة عاطفيًا وكل واحدة وراها نية تانية:
///
///  • **مكتمل** → «اعملها تاني» — ودي اللي بتدر إيراد.
///  • **ملغي** → «إيه اللي حصل؟» وبعدين خلاص.
///  • **ما حضرش** → غالبًا إحراج، وأحيانًا خلاف.
///
/// خلطهم بيخفف التبويب اللي المفروض يكرر الحجز. ومحدش عايز أرشيف دايم
/// لإلغاءاته — فالإشعار بيقول اللي حصل، وبيسيب مخرج، وبيمشي لما يتقفل.
///
/// ## ليه [AppBannerWidget]
///
/// ده بالظبط تعريف البانر في الكيت: **حالة مستمرة بتخص الشاشة دي**، مش
/// نتيجة فعل (snackbar) ولا حاجة بتوقف الشغل (dialog). واللي اتشال معاه
/// زرار القفل المكتوب بالإيد (كان `InkWell` بحشوة ٤ — أصغر من هدف اللمس)
/// وصف الأيقونة والعنوان.
///
/// **النغمة `neutral` مش `danger`**: الإلغاء حصل وخلاص، والأحمر هنا كان
/// هيقرا كإنذار على حاجة لسه محتاجة تصرّف.
class MyBookingsNoticeWidget extends StatelessWidget {
  final BookingUiModel booking;
  final VoidCallback onDismiss;
  final VoidCallback onRebook;

  const MyBookingsNoticeWidget({
    super.key,
    required this.booking,
    required this.onDismiss,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    return AppBannerWidget(
      tone: AppPillTone.neutral,
      icon: booking.status == BookingStatus.noShow
          ? Icons.event_busy_outlined
          : Icons.cancel_outlined,
      title: '${booking.status.label} · ${booking.serviceName}',
      message: _message,
      actionLabel: 'احجز تاني',
      onAction: onRebook,
      onDismiss: onDismiss,
    );
  }

  /// المكان والميعاد، وتحتهم السبب لو موجود.
  ///
  /// **السبب بيتعرض.** `cancellation_reason` مكشوف في `UserBookingResource`
  /// من الأول — الأبلكيشن كان بيطلبه من العميل وبيرميه، وكان بيتجاهله لما
  /// ييجي من الفرع كمان.
  String get _message {
    final head =
        '${booking.providerName} · ${AppFormat.relativeDate(booking.startAt)}';

    return booking.cancellationReason.isEmpty
        ? head
        : '$head\nالسبب: ${booking.cancellationReason}';
  }
}
