import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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

  /// العميل بيقبل الميعاد المعروض. `null` = الكارت للعرض بس.
  final VoidCallback? onAccept;

  /// العميل بيطلب ميعاد تاني — بياخد السبب من sheet.
  final VoidCallback? onRequestChange;

  const WaitlistCardWidget({
    super.key,
    required this.entry,
    required this.now,
    this.onRemove,
    this.onAccept,
    this.onRequestChange,
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
                child: Text(entry.status.label, style: AppTextStyles.overline),
              ),
              // **`entry.canCancel` من السيرفر، مش شرط محسوب هنا.**
              //
              // الخروج كان بيتخفي وقت العرض الشغّال عشان العميل مكانش
              // يقدر يعمل حاجة تانية، فالدوسة الغلط كانت خسارة صافية.
              // بقى جنبه «أقبل» و«ميعاد تاني»، فهو اختيار تالت مش الفعل
              // الوحيد — والسيرفر هو اللي بيقول مسموح ولا لأ.
              if (onRemove != null && entry.canCancel)
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
          // ⚠ **`displayAt` مش `preferredAt`.**
          //
          // لما يبقى فيه عرض، الميعاد المعروض هو اللي يهم — والسطر ده كان
          // بيعرض اللي العميل طلبه جنب عدّاد بينزل، يعني ساعة مش هي
          // المحجوزة له وهو فاكرها هي.
          Text(
            '${AppFormat.relativeDate(entry.displayAt)}'
            ' · ${AppFormat.time(entry.displayAt)}'
            '${entry.displayEmployeeName == null ? '' : ' · مع ${entry.displayEmployeeName}'}',
            style: AppTextStyles.caption,
          ),

          // العرض على ميعاد غير المطلوب؟ **قوله صراحة.**
          //
          // من غير السطر ده، العميل اللي طلب ٦م وشايف ٤م هيفتكرها غلطة
          // في الأبلكيشن مش عرض مختلف — والعرض بيروح وهو بيتأكد.
          if (entry.offerDiffersFromPreferred) ...[
            verticalSpace(AppSpacing.s4),
            Text(
              'إنت طلبت ${AppFormat.time(entry.preferredAt)}'
              ' — ده أقرب ميعاد فضي',
              style: AppTextStyles.overline.copyWith(
                color: AppSemanticColors.textSecondary,
              ),
            ),
          ],

          if (entry.offerMessage != null && entry.offerMessage!.isNotEmpty) ...[
            verticalSpace(AppSpacing.s4),
            Text(
              entry.offerMessage!,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (isOffered && isHoldActive) ...[
            verticalSpace(AppSpacing.s12),
            _Countdown(label: entry.countdownLabel(now)),
          ],

          verticalSpace(AppSpacing.s8),
          Text(entry.explanation, style: AppTextStyles.caption),

          // **الأزرار اللي العدّاد كان مستنيها.**
          //
          // الشاشة كانت بتعرض مهلة بتنزل وجملة بتقول «استنى مكالمة» —
          // عدّاد من غير فعل بيقرا قلق من غير مخرج. waitlist v2 ادّى
          // العميل الفعلين دول، فالرقم بقى ليه معنى.
          //
          // بيتحطوا على `canAccept` من السيرفر مش على الحالة: السيرفر
          // بيشترط إن المهلة لسه شغّالة كمان، والشرط ده عايش هناك.
          if (entry.canAccept || entry.canRequestChange) ...[
            verticalSpace(AppSpacing.s12),
            Row(
              children: [
                if (entry.canAccept && onAccept != null)
                  Expanded(
                    child: AppButtonWidget(
                      label: 'أقبل الميعاد',
                      onPressed: onAccept,
                    ),
                  ),
                if (entry.canAccept && entry.canRequestChange)
                  horizontalSpace(AppSpacing.s8),
                if (entry.canRequestChange && onRequestChange != null)
                  Expanded(
                    child: AppButtonWidget(
                      label: 'ميعاد تاني',
                      onPressed: onRequestChange,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
              ],
            ),
          ],
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
          color: AppSemanticColors.accentText,
        ),
        horizontalSpace(AppSpacing.s8),
        // `ltr` عشان النقطتين مايتنقلوش — «٤:٣٢» مش «٣٢:٤».
        Text(
          label,
          textDirection: TextDirection.ltr,
          style: AppTextStyles.titleLg.copyWith(
            color: AppSemanticColors.accentText,
          ),
        ),
        horizontalSpace(AppSpacing.s8),
        Expanded(child: Text('محجوز ليك', style: AppTextStyles.caption)),
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
  final ValueChanged<String>? onAccept;
  final ValueChanged<WaitlistUiModel>? onRequestChange;

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
    this.onAccept,
    this.onRequestChange,
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
            onAccept: onAccept == null ? null : () => onAccept!(entry.uuid),
            onRequestChange: onRequestChange == null
                ? null
                : () => onRequestChange!(entry),
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
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.s8.w),
        child: SizedBox(
          height: AppSpacing.touchTarget.r,
          child: Row(
            children: [
              Text('كل قوايم الانتظار', style: AppTextStyles.captionAccent),
              horizontalSpace(AppSpacing.s4),
              DirectionalChevronWidget(
                size: 16,
                color: AppSemanticColors.accentText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
