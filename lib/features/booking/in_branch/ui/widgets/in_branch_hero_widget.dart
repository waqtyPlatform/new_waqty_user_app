import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_gradients.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_band_widget.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/app_watermark_glyph_widget.dart';

/// **بؤرة الهوم.** الحاجة الغامقة الوحيدة في الأبلكيشن.
///
/// ## ليه دي البؤرة
///
/// الهوم كان فيه ١٥ صندوق مستدير فوق الطية وصفر عناصر غير مستديرة —
/// كله بنفس الوزن، فالعين مالهاش مكان تقع فيه. الشريط ده بيكسر تلات
/// حاجات مع بعض: **مستدير → مستقيم**، **فاتح → غامق**، **٢٢sp → ٤٠sp**.
/// تلات كسور في عنصر واحد بيخلوه البؤرة من غير ما يحتاج لون صارخ.
///
/// ## بيتحوّل مع الحالة
///
/// حبر وهو مستني، **أخضر** لما الكرسي يجهز. `AppBandWidget` غلافه
/// `AnimatedContainer` فالتحوّل بيحصل لوحده.
class InBranchHeroWidget extends StatelessWidget {
  final BookingUiModel booking;

  /// `null` = الحجز مش في الفرع دلوقتي، فبنعرض الميعاد الجاي بدل الحالة.
  final InBranchUiModel? data;

  final VoidCallback onTap;

  const InBranchHeroWidget({
    super.key,
    required this.booking,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final live = data;
    final isAttention = live != null && live.needsAttention;

    // **الطقم بيتبع الخلفية.**
    //
    // قبل كده الشريط كان بيقلب لونه من الحبر للأخضر و**الألوان اللي فوقه
    // تفضل زي ما هي** — يعني رمادي معمول للحبر بيقعد على أخضر. النتيجة
    // كانت 1.35:1 على «متوقع تخلص 6:45 م» و«صالون كابتن · فرع المعادي»:
    // النص موجود ومرسوم وبيقرا خلفية.
    //
    // والسخرية إن دي **أهم لحظة في الأبلكيشن** — الشريط بيبقى أخضر لما
    // الكرسي يجهز بالظبط، فأكتر لحظة محتاجة تتقري كانت أقلهم.
    final ink = isAttention
        ? AppSemanticColors.textOnAccent
        : AppSemanticColors.textOnInk;
    final inkMuted = isAttention
        ? AppSemanticColors.textOnAccentMuted
        : AppSemanticColors.textOnInkMuted;

    return AppBandWidget(
      onTap: onTap,
      color: isAttention
          ? AppSemanticColors.surfaceAccentDeep
          : AppSemanticColors.surfaceInk,
      // الحالتين ليهم غسلتين متعاكستين: الحبر بيتضوّي، والأخضر بيغمق
      // ناحية الركن. السبب في `AppGradients.accentDeep` — الهامش فوق AA
      // على الشريط الأخضر ٠٫٢٤ بس، فالضوء هناك ماينفعش يفتّح.
      gradient: isAttention ? AppGradients.accentDeep : AppGradients.ink,
      // حرف المحل باهت وخارج من الحافة — الشريط بيبقى **بتاع الحجز ده**
      // مش مستطيل عام. بيتغيّر بتغيّر المحل، فالشاشة مش واحدة عند الكل.
      backdrop: AppWatermarkGlyphWidget(
        name: booking.providerName,
        color: ink,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            live?.label ?? 'موعدك الجاي',
            style: AppTextStyles.sectionLabel.copyWith(color: inkMuted),
          ),
          verticalSpace(AppSpacing.s4),

          AnimatedSwitcher(
            duration: AppMotion.base,
            switchInCurve: AppMotion.standard,
            child: _Headline(booking: booking, data: live, ink: ink,
                inkMuted: inkMuted),
          ),

          verticalSpace(AppSpacing.s12),
          // الخط الشعري كان `0x33FFFFFF` ثابت — على الأخضر بيبقى شبه
          // مختفي. بياخد لون النص الثانوي بشفافية بدل رقم مكتوب بالإيد،
          // فبيتبع السطح زي باقي الطقم.
          AppHairlineWidget(color: inkMuted.withValues(alpha: 0.35)),
          verticalSpace(AppSpacing.s12),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.providerName} · ${booking.branchName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: inkMuted),
                ),
              ),
              // **وقت آخر تحديث ظاهر دايمًا** طول ما فيه تقدير حي.
              // تقدير ممكن يبقى بايت، ولازم يقول كده بنفسه.
              if (live != null && live.hasLiveEstimate)
                Text(
                  live.freshnessLabel(DateTime.now()),
                  style: AppTextStyles.overline.copyWith(color: inkMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final BookingUiModel booking;
  final InBranchUiModel? data;

  /// جايين من الشريط عشان يتبعوا خلفيته — مش ثابتين على طقم الحبر.
  final Color ink;
  final Color inkMuted;

  const _Headline({
    required this.booking,
    required this.data,
    required this.ink,
    required this.inkMuted,
  });

  @override
  Widget build(BuildContext context) {
    final live = data;

    // مش في الفرع؟ الميعاد هو الرقم الكبير. في الفرع؟ الحالة.
    final headline = live?.headline ?? AppFormat.time(booking.startAt);
    final sub = live == null
        ? AppFormat.relativeDate(booking.startAt)
        : live.subline;

    return Column(
      key: ValueKey<String>('$headline|$sub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.displayXl.copyWith(color: ink),
        ),
        if (sub.isNotEmpty) ...[
          verticalSpace(AppSpacing.s4),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(color: inkMuted),
          ),
        ],
      ],
    );
  }
}
