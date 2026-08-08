import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';

/// كارت إدخال في قائمة انتظار.
///
/// ## العدّاد بيتعرض والزرار لأ — وده صدق مش نقص
///
/// الحجز المؤقت ٥ دقايق **حقيقي في السيرفر**، و`hold_remaining_seconds`
/// مكشوف في `BookingWaitlistResource` — فالعدّاد مش اختراع.
///
/// اللي مش موجود هو **إن العميل يقبل بنفسه**: `PATCH .../accept` تحت
/// `/provider/` مش `/user/`. يعني الموظف بيقبل نيابة عنه جوه حجز مؤقت
/// العميل نفسه مش شايفه.
///
/// فبدل ما نحط زرار «أكّد» بيكدب، بنقول الحقيقة: «الفرع بيأكّد دلوقتي».
/// ولما ناس في الاختبار تحاول تدوس على العدّاد، دي بتبقى الحجة اللي
/// بنروح بيها نطلب endpoint للعميل.
class WaitlistCardWidget extends StatelessWidget {
  final WaitlistUiModel entry;
  final DateTime now;
  final VoidCallback? onRemove;

  const WaitlistCardWidget({
    super.key,
    required this.entry,
    required this.now,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isOffered = entry.status == WaitlistStatus.awaitingResponse;
    final isHoldActive = entry.isHoldActive(now);

    return AppSurfaceWidget(
      padding: AppSpacing.cardLoose,
      // العرض الشغّال بياخد حد أخضر — هو الحاجة الوحيدة هنا اللي فيها
      // وقت بيجري.
      border: isOffered && isHoldActive
          ? Border.all(color: AppSemanticColors.accent)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.status.label,
                  style: AppTextStyles.sectionLabel,
                ),
              ),
              // `canLeaveQueue` مش `isLive` — الخروج بيختفي وقت العرض
              // الشغّال. السبب مكتوب على الـ getter نفسها.
              if (onRemove != null && entry.status.canLeaveQueue)
                InkWell(
                  onTap: onRemove,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s4.r),
                    child: Text(
                      'اخرج من القائمة',
                      style: AppTextStyles.overline.copyWith(
                        color: AppSemanticColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          verticalSpace(AppSpacing.s4),

          Text(
            entry.serviceName,
            style: AppTextStyles.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${entry.providerName} · ${entry.branchName}',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${AppFormat.relativeDate(entry.preferredAt)}'
            ' · ${AppFormat.time(entry.preferredAt)}'
            '${entry.employeeName == null ? '' : ' · مع ${entry.employeeName}'}',
            style: AppTextStyles.caption,
          ),

          if (isOffered && isHoldActive) ...[
            verticalSpace(AppSpacing.s12),
            _Countdown(label: entry.countdownLabel(now)),
          ],

          verticalSpace(AppSpacing.s8),
          Text(entry.explanation, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// العدّاد — **الرقم الوحيد اللي بيتحرك في الشاشة**.
class _Countdown extends StatelessWidget {
  final String label;

  const _Countdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18.r,
          color: AppSemanticColors.accent,
        ),
        horizontalSpace(AppSpacing.s8),
        // `ltr` عشان النقطتين مايتنقلوش — «٤:٣٢» مش «٣٢:٤».
        Text(
          label,
          textDirection: TextDirection.ltr,
          style: AppTextStyles.titleLg.copyWith(
            color: AppSemanticColors.accent,
          ),
        ),
        horizontalSpace(AppSpacing.s8),
        Expanded(
          child: Text(
            'محجوز ليك',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

/// قسم قوائم الانتظار فوق قايمة الحجوزات.
///
/// **بيختفي بالكامل لما مفيش إدخالات** — مش عنوان فاضي. القائمة حاجة
/// استثنائية، وعنوان دايم ليها بيخليها تبان زي تبويب مهجور.
class WaitlistSectionWidget extends StatelessWidget {
  final List<WaitlistUiModel> entries;
  final DateTime now;
  final ValueChanged<String>? onRemove;

  /// بيفتح شاشة قايمة الانتظار الكاملة. `null` = مايبانش السطر.
  ///
  /// القسم ده بيتعرض في مكانين بمعنيين مختلفين: في الرئيسية بيعرض
  /// **العروض الشغّالة بس**، وفي تبويب الحجوزات بيعرض كل الإدخالات.
  /// «عرض الكل» ليها معنى في التاني بس — في الرئيسية هي بتقول للعميل
  /// إن فيه حاجة مخبّية وهو أصلاً واقف قدام العدّاد.
  final VoidCallback? onSeeAll;

  const WaitlistSectionWidget({
    super.key,
    required this.entries,
    required this.now,
    this.onRemove,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries) ...[
          WaitlistCardWidget(
            entry: entry,
            now: now,
            onRemove: onRemove == null ? null : () => onRemove!(entry.uuid),
          ),
          verticalSpace(AppSpacing.listRowGap),
        ],
        if (onSeeAll != null) _SeeAllRow(onTap: onSeeAll!),
        verticalSpace(AppSpacing.s8),
      ],
    );
  }
}

/// «كل قوايم الانتظار ›» — بيوصّل للحالات اللي القسم ده مابيعرضهاش.
class _SeeAllRow extends StatelessWidget {
  final VoidCallback onTap;

  const _SeeAllRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rXs,
      child: Padding(
        // **`touchTarget` مش حشوة على العين.** السطر ده نص وسهم، وارتفاعه
        // الطبيعي أقل من ٤٤ — والقاعدة `.r` مش `.h`.
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s8.w,
        ),
        child: SizedBox(
          height: AppSpacing.touchTarget.r,
          child: Row(
            children: [
              Text(
                'كل قوايم الانتظار',
                style: AppTextStyles.captionAccent,
              ),
              horizontalSpace(AppSpacing.s4),
              DirectionalChevronWidget(
                size: 16,
                color: AppSemanticColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
