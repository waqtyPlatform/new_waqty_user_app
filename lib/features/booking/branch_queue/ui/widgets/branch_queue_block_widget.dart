import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// بلوك الدور الكامل — بيقعد في **صفحة تفاصيل الحجز**.
///
/// ## ليه ده كارت مش شريط زي بؤرة الهوم
///
/// الشريط الغامق الممتد من حافة لحافة هو **الحاجة الوحيدة** في الأبلكيشن
/// اللي بتكسر الاستدارة والإضاءة مع بعض. لو اتكرر في صفحة تانية بيبطّل
/// يعني «دي البؤرة» ويبقى مجرد لون. فهنا سطح مرفوع عادي، والفرق إنه
/// **بيقول أكتر** مش إنه بيصرّخ أعلى.
///
/// وعشان نفس السبب الرقم هنا `displayLg` (٣٢) مش `displayXl` (٤٠) —
/// الأربعين محجوزة لبؤرة الهوم.
///
/// ## قاعدتين مش قابلين للتفاوض
///
/// **١. التقدير مدى دايمًا.** [QueueUiModel.estimateLabel] عمره ما بيرجّع
/// رقم واحد. «باقي ٢٧ دقيقة» بيتكسر مرة واحدة والعميل بيبطّل يصدّق أي رقم
/// بنعرضه بعدها.
///
/// **٢. وقت آخر تحديث ظاهر دايمًا** طول ما فيه رقم حي على الشاشة. الاستثناء
/// الوحيد هو الحالات اللي **مفيهاش أرقام أصلاً** ([QueueState.notToday]
/// و[QueueState.done]) — مافيش حاجة تبوظ عشان تحتاج تحذير.
class BranchQueueBlockWidget extends StatelessWidget {
  final QueueUiModel queue;

  const BranchQueueBlockWidget({super.key, required this.queue});

  /// الحالات اللي فيها رقم حي: كل حاجة غير «مش النهاردة» و«خلصت».
  /// [QueueState.scheduled] داخلة — الفرع لسه ما بدأش، بس ترتيبي معروف.
  bool get _hasLiveNumbers =>
      queue.state != QueueState.notToday && queue.state != QueueState.done;

  bool get _isNow => queue.state.needsAttention;

  @override
  Widget build(BuildContext context) {
    final accentedColor = _isNow
        ? AppSemanticColors.accent
        : AppSemanticColors.textPrimary;

    return AppSurfaceWidget(
      padding: AppSpacing.cardLoose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(queue.state.label, style: AppTextStyles.sectionLabel),
          verticalSpace(AppSpacing.s4),

          // الرقم بيتبدّل بتلاشي لما الطابور يتقدّم. الـ key على **نص**
          // العنوان مش على الحالة — لو كان على الحالة، «٥ قدامك» و«٤ قدامك»
          // كانوا هيتبدلوا من غير حركة.
          AnimatedSwitcher(
            duration: AppMotion.base,
            switchInCurve: AppMotion.standard,
            // الافتراضي بيكوّم النصين بـ `Alignment.center` — يعني الرقم
            // الطالع بيزحف أفقيًا وهو بيختفي. الوقوف على بداية السطر
            // بيخلي التبديل في مكانه.
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: Text(
              _headline,
              key: ValueKey<String>(_headline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayLg.copyWith(color: accentedColor),
            ),
          ),

          verticalSpace(AppSpacing.s4),
          Text(_sub, style: AppTextStyles.bodyMdMuted),

          if (_hasLiveNumbers) ...[
            verticalSpace(AppSpacing.s16),

            // إحساس بسيط بالتقدّم — **نسبة مش رقم**. الشريط بيقول
            // «إحنا فين من الطابور» من غير ما يدّعي دقة مالهاش أساس.
            _ProgressBar(value: _progress, color: accentedColor),

            verticalSpace(AppSpacing.s12),
            Row(
              children: [
                _Fact(label: 'الدور دلوقتي', value: _nowServingValue),
                const Spacer(),
                _Fact(
                  label: 'رقمك',
                  value: AppFormat.digits(queue.myPosition),
                  alignEnd: true,
                ),
              ],
            ),

            verticalSpace(AppSpacing.s12),
            const AppHairlineWidget(),
            verticalSpace(AppSpacing.s8),
            Text(
              queue.freshnessLabel(DateTime.now()),
              style: AppTextStyles.overline.copyWith(
                color: AppSemanticColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// اللابل فوق والعنوان والسطر التحتاني — **تلاتتهم بيقولوا حاجات مختلفة**.
  /// أول نسخة كانت بتحط «جاري الخدمة» تحت لابل «الخدمة» فوق سطر «جاري
  /// الخدمة»، والبلوك كان بيقرا كأنه اتلغبط.
  String get _headline => switch (queue.state) {
    QueueState.yourTurn => 'دورك',
    QueueState.inService => 'جارية',
    QueueState.done => 'تمّت',
    QueueState.notToday => 'مش النهاردة',
    _ => '${AppFormat.digits(queue.aheadOfMe)} قدامك',
  };

  String get _sub => switch (queue.state) {
    QueueState.yourTurn => 'اتوجّه للريسيبشن',
    QueueState.inService => 'بدأت دلوقتي',
    QueueState.done => 'شكرًا — تقدر تقيّم الخدمة',
    QueueState.notToday => 'مفيش طابور غير يوم الحجز',
    // المدى بيجي من الموديل نفسه — عشان نفس الجملة تطلع في البلوك وفي
    // بؤرة الهوم من غير ما حد يعيد صياغتها.
    _ => queue.estimateLabel,
  };

  /// «لسه» أوضح من صفر: الفرع ما بدأش يستقبل، مش بيخدم الحجز رقم صفر.
  String get _nowServingValue =>
      queue.nowServing <= 0 ? 'لسه' : AppFormat.digits(queue.nowServing);

  /// كام واحد خلص من طابوري — **مش تقدير وقت**.
  ///
  /// الوقت مدى عشان مش مضمون. النسبة دي من ناحية تانية حقيقة معدودة:
  /// [QueueUiModel.nowServing] من [QueueUiModel.myPosition].
  double get _progress {
    if (queue.state == QueueState.yourTurn ||
        queue.state == QueueState.inService ||
        queue.state == QueueState.done) {
      return 1;
    }
    if (queue.myPosition <= 0) return 0;
    final served = queue.nowServing.clamp(0, queue.myPosition);
    return served / queue.myPosition;
  }
}

/// شريط تقدّم رفيع.
///
/// `TweenAnimationBuilder` مش `AnimationController`: كل ما النسبة تتغيّر
/// الشريط بيمشي من مكانه الحالي للجديد لوحده، من غير أي حالة متخزّنة.
class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.rPill,
      child: SizedBox(
        height: 6.h,
        width: double.infinity,
        child: ColoredBox(
          color: AppSemanticColors.surfaceSunken,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: AppMotion.slow,
            curve: AppMotion.standard,
            builder: (context, fraction, _) => FractionallySizedBox(
              // بيملا من ناحية القراءة — يمين في العربي.
              alignment: AlignmentDirectional.centerStart,
              widthFactor: fraction,
              child: AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// رقم صغير تحته لابل. تفصيلة تخطيط للبلوك بس — مش primitive عام.
class _Fact extends StatelessWidget {
  final String label;
  final String value;

  /// آخر الصف. `CrossAxisAlignment.end` جوه `Column` بيتحل بالـ
  /// `Directionality`، فمافيش حاجة محتاجة تتقلب بالإيد.
  final bool alignEnd;

  const _Fact({required this.label, required this.value, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        verticalSpace(AppSpacing.s4),
        Text(value, style: AppTextStyles.bodyMdStrong),
      ],
    );
  }
}
