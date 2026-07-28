import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_band_widget.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';

/// شريط رفيع فوق التبويبات — بيظهر لما الدور يقرب، على **أي تبويب**.
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
/// سطر واحد وسهم. لو حط عليه رقم وتقدير ووقت تحديث بقى بؤرة تانية بتزاحم
/// المحتوى — وده شريط **تنبيه**، مش لوحة. التفاصيل كلها على بُعد ضغطة.
class BranchQueueBannerWidget extends StatelessWidget {
  /// `null` = مفيش حجز حي أصلاً. الشريط بيتعامل مع الحالتين بنفس الطريقة
  /// عشان اللي بينده مايحتاجش يلفّه في `if`.
  final QueueUiModel? queue;

  final VoidCallback onTap;

  const BranchQueueBannerWidget({
    super.key,
    required this.queue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final live = queue;
    final isVisible = live != null && live.state.needsAttention;

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

  Widget _band(QueueUiModel live) {
    final isNow = live.state == QueueState.yourTurn;

    return AppBandWidget(
      onTap: onTap,
      color: isNow ? AppSemanticColors.accent : AppSemanticColors.surfaceInk,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
        vertical: AppSpacing.s12.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isNow
                  ? 'دورك دلوقتي — اتوجّه للريسيبشن'
                  : 'دورك قرّب — ${AppFormat.digits(live.aheadOfMe)} قدامك',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMdStrong.copyWith(
                color: AppSemanticColors.textOnInk,
              ),
            ),
          ),
          horizontalSpace(AppSpacing.s8),
          const DirectionalChevronWidget(
            size: 18,
            color: AppSemanticColors.textOnInkMuted,
          ),
        ],
      ),
    );
  }
}
