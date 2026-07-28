import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_band_widget.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';

/// **بؤرة الهوم.** الحاجة الغامقة الوحيدة في الأبلكيشن.
///
/// ## ليه دي البؤرة
///
/// الهوم كان فيه ١٥ صندوق مستدير فوق الطية وصفر عناصر غير مستديرة —
/// كله بنفس الوزن، فالعين مالهاش مكان تقع فيه. الشريط ده بيكسر تلات
/// حاجات مع بعض: **مستدير → مستقيم**، **فاتح → غامق**، **٢٢sp → ٤٠sp**.
/// تلات كسور في عنصر واحد بيخلوه البؤرة من غير ما يحتاج لون صارخ.
///
/// وهو يستاهلها فعلاً: ده الحاجة الوحيدة في الشاشة اللي **بتتحرّك لوحدها**.
///
/// ## بيتحوّل مع الحالة
///
/// حبر وهو مستني، **أخضر** لما يبقى دورك. `AppBandWidget` غلافه
/// `AnimatedContainer` فالتحوّل بيحصل لوحده.
class BranchQueueHeroWidget extends StatelessWidget {
  final BookingUiModel booking;
  final QueueUiModel queue;
  final VoidCallback onTap;

  const BranchQueueHeroWidget({
    super.key,
    required this.booking,
    required this.queue,
    required this.onTap,
  });

  bool get _isNow => queue.state == QueueState.yourTurn;

  @override
  Widget build(BuildContext context) {
    return AppBandWidget(
      onTap: onTap,
      color: _isNow ? AppSemanticColors.accent : AppSemanticColors.surfaceInk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            queue.state.label,
            style: AppTextStyles.sectionLabel.copyWith(
              color: AppSemanticColors.textOnInkMuted,
            ),
          ),
          verticalSpace(AppSpacing.s4),

          // الرقم هو البطل. `AnimatedSwitcher` عشان لما الطابور يتقدّم
          // الرقم يتبدّل بتلاشي بدل ما ينطّ.
          AnimatedSwitcher(
            duration: AppMotion.base,
            switchInCurve: AppMotion.standard,
            child: _Headline(queue: queue, booking: booking),
          ),

          verticalSpace(AppSpacing.s12),
          const AppHairlineWidget(color: Color(0x33FFFFFF)),
          verticalSpace(AppSpacing.s12),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.providerName} · ${booking.branchName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppSemanticColors.textOnInkMuted,
                  ),
                ),
              ),
              // **وقت آخر تحديث ظاهر دايمًا.** رقم حي ممكن يبقى بايت،
              // ولازم يقول كده بنفسه.
              if (queue.state.isLive)
                Text(
                  queue.freshnessLabel(DateTime.now()),
                  style: AppTextStyles.overline.copyWith(
                    color: AppSemanticColors.textOnInkMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final QueueUiModel queue;
  final BookingUiModel booking;

  const _Headline({required this.queue, required this.booking});

  @override
  Widget build(BuildContext context) {
    // قبل ما الطابور يبدأ، الميعاد هو الرقم الكبير. بعد ما يبدأ، الدور.
    final isQueueLive = queue.state.isLive;

    final headline = switch (queue.state) {
      QueueState.yourTurn => 'دورك',
      QueueState.inService => 'جارية',
      QueueState.done => 'تمّت',
      _ when isQueueLive => '${_ar(queue.aheadOfMe)} قدامك',
      _ => AppFormat.time(booking.startAt),
    };

    final sub = switch (queue.state) {
      QueueState.yourTurn => 'اتوجّه للريسيبشن',
      QueueState.inService => 'بدأت دلوقتي',
      QueueState.done => 'خلصت — تقدر تقيّمها',
      _ when isQueueLive => queue.estimateLabel,
      _ => AppFormat.relativeDate(booking.startAt),
    };

    return Column(
      key: ValueKey('${queue.state}_${queue.aheadOfMe}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          headline,
          maxLines: 1,
          style: AppTextStyles.displayXl.copyWith(
            color: AppSemanticColors.textOnInk,
          ),
        ),
        verticalSpace(AppSpacing.s4),
        Text(
          sub,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppSemanticColors.textOnInkMuted,
          ),
        ),
      ],
    );
  }

  static String _ar(int n) =>
      n.toString().split('').map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)]).join();
}
