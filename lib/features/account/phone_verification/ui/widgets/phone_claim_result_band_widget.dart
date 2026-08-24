import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **باند بيقول اللي ظهر فعلاً — بأرقام السيرفر.**
///
/// ## ليه مش «تم التأكيد بنجاح»
///
/// العميلة ما أكّدتش رقمها عشان تأكّد رقمها — أكّدته عشان **الباقة اللي
/// دفعت فيها تظهر**. فالنجاح اللي يهمها هو عدد الحاجات اللي بانت، مش إن
/// الـOTP عدّى.
///
/// والأرقام دي **مش محسوبة عندنا**: `relinked_bookings` بييجي من
/// `LinkProviderCustomersToPlatformUserAction` اللي بيعمل الـ`update` فعلاً
/// وبيرجّع عدد الصفوف اللي اتغيّرت.
///
/// ⚠ **[PhoneClaimResultUiModel.linked] بيعدّ سجلات عملاء مش باقات**، عشان
/// كده الباند مابيقولش عدد باقات من عنده — بييجي من إعادة تحميل
/// الـentitlements و بيتبعت في [packagesFound].
class PhoneClaimResultBandWidget extends StatelessWidget {
  const PhoneClaimResultBandWidget({
    required this.result,
    this.packagesFound,
    super.key,
  });

  final PhoneClaimResultUiModel result;

  /// عدد الباقات بعد إعادة التحميل. `null` = لسه ما اتحمّلوش.
  final int? packagesFound;

  /// **جمع عربي بسيط للأعداد الصغيرة.**
  ///
  /// العربي فيه مفرد ومثنى وجمع، والأرقام اللي بتوصل هنا صغيرة (سجلات
  /// عميلة واحدة عند فروع قليلة) — فالتغطية من ١ لـ١٠ كفاية، وفوقيها
  /// بترجع للمفرد زي قواعد العربي («١١ حجز»).
  ///
  /// محلي مقصود ومش في `AppFormat`: أول ما يبقى ليه مستهلك تاني يتنقل
  /// للكيت — ولحد ساعتها إضافته هناك بتكلّف مزامنة نسختين من غير مقابل.
  static String _plural(int count, String one, String two, String few) {
    if (count == 1) return one;
    if (count == 2) return two;
    if (count <= 10) return '${AppFormat.digits(count)} $few';
    return '${AppFormat.digits(count)} $one';
  }

  /// النص — **بيتغيّر جذريًا لما مالقاش حاجة**.
  ///
  /// «ظهرلك ٠ حجوزات» أوحش من السكوت: بتأكّد للعميلة إن مفيش حاجة بطريقة
  /// بتحسّسها إنها غلطتها. النص المحايد بيقول اللي ممكن يحصل بعدين.
  ///
  /// ⚠ **مش بيكرّر «رقمك اتأكّد»** — دي عنوان الورقة اللي بتلفّه
  /// (`PhoneClaimResultSheet`). التكرار كان بيخلّي الورقة تقول نفس
  /// الجملة مرتين فوق بعض.
  String get message {
    final parts = <String>[];
    final packages = packagesFound ?? 0;

    if (packages > 0) {
      parts.add(_plural(packages, 'باقة', 'باقتين', 'باقات'));
    }
    if (result.relinkedBookings > 0) {
      parts.add(_plural(result.relinkedBookings, 'حجز', 'حجزين', 'حجوزات'));
    }

    if (parts.isEmpty) {
      return 'لو اشتريت باقة أو حجزت من الفرع، هتلاقيها هنا.';
    }

    return 'ظهرلك ${parts.join(' و')}';
  }

  @override
  Widget build(BuildContext context) => AppBannerWidget(
    message: message,
    tone: AppPillTone.positive,
    icon: Icons.check_circle_outline_rounded,
  );
}
