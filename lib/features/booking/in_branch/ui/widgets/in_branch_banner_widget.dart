import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_band_widget.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';

/// شريط رفيع فوق التبويبات — بيظهر لما الكرسي يقرب، على **أي تبويب**.
///
/// ## ليه الحركة مش تفصيلة شكلية
///
/// الشريط بيظهر والعميل ماسك الأبلكيشن وبيبص على حاجة تانية خالص. لو ظهر
/// فجأة، الشاشة كلها بتتزحلق تحته وممكن يدوس على حاجة ما كانش قاصدها.
/// [AnimatedSize] بيفتح المساحة بالتدريج من ناحية **تحت** (يعني المحتوى
/// بيتزح لفوق بهدوء)، و[AnimatedOpacity] بيمنع اللون الغامق من إنه ينطّ.
///
/// ## بيقول حاجة واحدة بس
///
/// سطر واحد وسهم. لو حط عليه تقدير ووقت تحديث بقى بؤرة تانية بتزاحم
/// المحتوى — وده شريط **تنبيه**، مش لوحة. التفاصيل كلها على بُعد ضغطة.
class InBranchBannerWidget extends StatelessWidget {
  /// `null` = مفيش حجز في الفرع أصلاً. الشريط بيتعامل مع الحالتين بنفس
  /// الطريقة عشان اللي بينده مايحتاجش يلفّه في `if`.
  final InBranchUiModel? data;

  final VoidCallback onTap;

  const InBranchBannerWidget({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final live = data;
    final isVisible = live != null && live.needsAttention;

    return AnimatedSize(
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      // بيتمدّد من تحت لفوق — الشريط ملزوق في التبويبات، فالحافة السفلية
      // هي اللي مفروض تفضل ثابتة.
      alignment: AlignmentDirectional.bottomCenter,
      child: AnimatedOpacity(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        opacity: isVisible ? 1 : 0,
        child: isVisible
            ? _band(live)
            : const SizedBox(width: double.infinity),
      ),
    );
  }

  /// نفس باج البؤرة بالحرف: خلفية [AppSemanticColors.accent] وفوقها طقم
  /// معمول للحبر. النص كان **3.76:1** والسهم **1.35:1** — يعني الشريط
  /// اللي بينده على العميل عشان يدخل كان أصعب حاجة يقراها في الشاشة.
  ///
  /// الأخضر الغامق وطقمه بيرفعوهم لـ **6.8:1** و**4.7:1**.
  Widget _band(InBranchUiModel live) {
    return AppBandWidget(
      onTap: onTap,
      color: AppSemanticColors.surfaceAccentDeep,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
        vertical: AppSpacing.s12.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              // **مش `announcement`.** ده شريط قاعد، والتنبيه لحظة.
              live.bannerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // **`textOnAccentDeep` مش `textOnAccent`** — التاني بينقلب
              // لحبر غامق في الوضع الغامق، وعلى الأخضر الغامق بيدي 2.52:1.
              style: AppTextStyles.bodyMdStrong.copyWith(
                color: AppSemanticColors.textOnAccentDeep,
              ),
            ),
          ),
          horizontalSpace(AppSpacing.s8),
          DirectionalChevronWidget(
            size: 18,
            color: AppSemanticColors.textOnAccentMuted,
          ),
        ],
      ),
    );
  }
}
