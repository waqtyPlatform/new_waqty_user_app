import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/widgets/app_pill_widget.dart';

/// شارة حالة الحجز.
///
/// اللفظ جاي من `BookingStatus.label` — الأسماء الداخلية زي `no_show`
/// مصطلحات تقنية ومتتعرضش زي ما هي للعميل.
///
/// ## بقى غلاف رفيع فوق [AppPillWidget]
///
/// كان بيرسم `Container` بحشوته واستدارته بنفسه — يعني شارة الحالة شكلها
/// مربوط بمكان تاني غير باقي شارات الأبلكيشن، وأول ما شكل الشارات اتغيّر
/// كانت هتفضل على شكلها القديم.
///
/// اللي فاضل هنا هو **الترجمة بس**: حالة → لهجة. وده الشغل الوحيد اللي
/// يخص الحجز فعلاً.
class BookingStatusChipWidget extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChipWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) =>
      AppPillWidget(label: status.label, tone: _tone);

  /// **مفيش `_ =>` هنا بالقصد.**
  ///
  /// الـ default كان بيبلع أي حالة جديدة ويطلّعها رمادية من غير ما حد ياخد
  /// باله — وده بالظبط اللي خلّى أبلكيشن الموظف يرسم شارة مش مقروءة. من
  /// غيره، أي حالة تتضاف للـ enum بتوقّف الـ build لحد ما حد يقرر لونها.
  AppPillTone get _tone => switch (status) {
    BookingStatus.confirmed => AppPillTone.accent,
    // وصل ومستني — الأصفر بيقول «فيه حاجة بتحصل دلوقتي وتخصك».
    BookingStatus.arrived => AppPillTone.warning,
    BookingStatus.waiting => AppPillTone.warning,
    BookingStatus.inProgress => AppPillTone.info,
    BookingStatus.completed => AppPillTone.positive,
    BookingStatus.noShow => AppPillTone.danger,
    // الإلغاء رمادي مش أحمر. الأحمر بيقرا «فيه مشكلة» والإلغاء غالبًا
    // العميل هو اللي عمله.
    BookingStatus.cancelled => AppPillTone.neutral,
  };
}
