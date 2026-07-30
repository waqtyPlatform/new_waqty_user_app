import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

/// شريط الحجز المثبّت تحت صفحة المحل.
///
/// ## ليه فيه زرارين حجز في الصفحة
///
/// زرار «احجز» اللي جنب كل خدمة و«احجز موعد» المثبّت تحت **مش تكرار**،
/// دول مدخلين لحالتين مختلفتين:
///
///  • العميل اللي عارف هو عايز إيه بيضغط على صفه — والـ sheet بيفتح على
///    الميعاد على طول لأنه اختار الخدمة بالضغطة دي.
///  • العميل اللي لسه بيتفرّج، أو عايز أكتر من خدمة، مالوش صف واحد
///    يضغط عليه. الشريط ده بيفتحله قايمة الخدمات بالاختيار المتعدد.
///
/// عشان كده اللابل مختلف: «احجز» فعل على حاجة بعينها، و«احجز موعد»
/// بداية حجز.
///
/// ## ليه نفس شكل فوتر الـ sheet
///
/// نفس السطح والحد والظل بتوع [CreateBookingFooterWidget]. لما العميل
/// يضغط، الشريط اللي تحت إيده بيفضل في نفس المكان بنفس الشكل جوه الـ
/// sheet — فالحركة بتقرا كأن الصفحة اتفتحت، مش كأن حاجة اتبدلت بحاجة.
class ServiceProviderDetailsBookingBarWidget extends StatelessWidget {
  /// الخدمات المعروضة في الصفحة — أرخص واحدة فيها هي اللي بتتعرض.
  ///
  /// **مش `provider.priceFrom`.** الحقل ده بيتحسب على مستوى المحل وبيفرق
  /// عن الليستة اللي تحت: محل الـ mock مثلًا `priceFrom` بتاعه ٢٥٠ وأرخص
  /// خدمة معروضة ١٢٠. «يبدأ من ٢٥٠» فوق ليستة فيها ١٢٠ كذب باين بالعين.
  final List<ServiceUiModel> services;

  final VoidCallback onBook;

  const ServiceProviderDetailsBookingBarWidget({
    super.key,
    required this.services,
    required this.onBook,
  });

  double? get _priceFrom {
    final bookable = services.where((s) => !s.isCategory && s.price > 0);
    if (bookable.isEmpty) return null;
    return bookable.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final priceFrom = _priceFrom;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
        vertical: AppSpacing.cardPadding.h,
      ),
      // مش `const` — الظلال بتتقاس بـ `.r` فقيمها بتتحسب وقت التشغيل.
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceRaised,
        // **حد حاد تحت ظل** — واحدة من التلات حالات اللي بيفضل فيها حد.
        // الظل بيقول «الشريط طايف»، والحد بيقطع الحافة بحدّة فبيبان إن
        // المحتوى بيعدّي من تحته.
        border: Border(top: BorderSide(color: AppSemanticColors.border)),
        boxShadow: AppShadows.floatingUp,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (priceFrom != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('يبدأ من', style: AppTextStyles.caption),
                  Text(
                    AppFormat.money(priceFrom),
                    style: AppTextStyles.cardTitle,
                  ),
                ],
              ),
              horizontalSpace(AppSpacing.listRowGap),
            ],
            Expanded(
              child: ButtonWidget(
                isLoading: false,
                buttonText: 'احجز موعد',
                backGroundColor: AppSemanticColors.accent,
                borderColor: AppSemanticColors.accent,
                textStyle: AppTextStyles.button,
                buttonHeight: 52.h,
                onPressed: onBook,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
