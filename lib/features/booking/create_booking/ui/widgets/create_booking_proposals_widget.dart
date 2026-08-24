import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// **النافذة الأول، وبعدين اقتراحات.**
///
/// ## المشكلة اللي بيحلها
///
/// خدمة ٤٥ دقيقة في يوم مفتوح بتطلّع ٣٠+ شيب. ومعظم العملاء عندهم
/// **نافذتين أو تلاتة مقبولين** — «الصبح أو بالليل» — مش حد ١٥ دقيقة
/// مفضّل. الشبكة القديمة كانت بتحمّل العميل عبء البحث: يفتح يوم، يمسح
/// بعينه، مايلاقيش، يفتح اللي بعده، ويكرر.
///
/// القلب بيخلي الأبلكيشن هو اللي يبحث: **إنت فاضي إمتى تقريبًا؟** وبعدها
/// «أهو أقرب ٦ مواعيد مناسبين، موزّعين على أيام».
///
/// ## النوافذ **متعددة الاختيار**
///
/// «أنا فاضي الصبح أو بالليل بس مش الضهر» جملة طبيعية. لو خلّيناها
/// اختيار واحد، العميل كان هيقسم طلبه على مرتين — وده بالظبط الشغل اللي
/// إحنا شايلينه عنه.
///
/// ## ومفيش حاجة اتشالت
///
/// الشبكة الكاملة على بُعد ضغطة («كل المواعيد»). اللي عايز الساعة ٦:١٥
/// بالذات لسه يقدر يوصلها.
class CreateBookingProposalsWidget extends StatelessWidget {
  final List<SlotUiModel> proposals;
  final SlotUiModel? selectedSlot;
  final Set<SlotPeriod> periods;
  final bool isLoading;
  final double baselinePrice;

  final ValueChanged<SlotPeriod> onPeriodToggle;
  final ValueChanged<SlotUiModel> onSlotTap;
  final VoidCallback onBrowseAll;
  final VoidCallback? onJoinWaitlist;

  const CreateBookingProposalsWidget({
    super.key,
    required this.proposals,
    required this.selectedSlot,
    required this.periods,
    required this.baselinePrice,
    required this.onPeriodToggle,
    required this.onSlotTap,
    required this.onBrowseAll,
    this.onJoinWaitlist,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إنت فاضي إمتى؟', style: AppTextStyles.bodyMdStrong),
        verticalSpace(AppSpacing.s8),
        Wrap(
          spacing: AppSpacing.chipGap.w,
          runSpacing: AppSpacing.chipGap.h,
          children: [
            for (final period in SlotPeriod.values)
              _PeriodChip(
                period: period,
                isSelected: periods.contains(period),
                onTap: () => onPeriodToggle(period),
              ),
          ],
        ),
        // فاضية = أي وقت. بنقولها بدل ما نسيب العميل يستنتج.
        if (periods.isEmpty) ...[
          verticalSpace(AppSpacing.s4),
          Text(
            'مفيش تحديد — بنعرض أقرب المواعيد',
            style: AppTextStyles.caption,
          ),
        ],

        // ١٦ مش ٢٤. الفلتر والنتيجة **سؤال وجوابه** — مش قسمين مستقلين.
        // الـ ٢٤ كانت بتفصلهم لدرجة إن العميل بيغيّر الفلتر ومايربطش
        // التغيير باللي تحته.
        verticalSpace(AppSpacing.s16),
        Text('أقرب المواعيد', style: AppTextStyles.bodyMdStrong),
        verticalSpace(AppSpacing.s8),
        _list(),

        verticalSpace(AppSpacing.s8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onBrowseAll,
            icon: Icon(Icons.calendar_month_outlined, size: 18.r),
            label: Text('كل المواعيد', style: AppTextStyles.label),
          ),
        ),
      ],
    );
  }

  Widget _list() {
    if (isLoading) {
      return Column(
        children: List<Widget>.generate(
          3,
          (_) => Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.chipGap.h),
            child: const AppSkeletonBoxWidget(
              width: double.infinity,
              height: 56,
              radius: AppRadius.m,
            ),
          ),
        ),
      );
    }

    if (proposals.isEmpty) {
      // **مفيش مواعيد في النوافذ دي** — مش «مفيش مواعيد خالص». الفرق
      // مهم: الأول بيتحل بتوسيع النافذة، والتاني بقائمة الانتظار.
      return AppEmptyStateWidget(
        icon: Icons.search_off_outlined,
        title: periods.isEmpty
            ? 'مفيش مواعيد قريبة'
            : 'مفيش مواعيد في الأوقات دي',
        message: periods.isEmpty
            ? 'جرّب فرع تاني، أو خلينا نبلّغك أول ما يفضى'
            : 'وسّع الاختيار فوق، أو شوف كل المواعيد',
        actionLabel: periods.isEmpty && onJoinWaitlist != null
            ? 'ضيفني لقائمة الانتظار'
            : null,
        onAction: periods.isEmpty ? onJoinWaitlist : null,
      );
    }

    // **شبكة عمودين، مش صفوف بعرض الشاشة.**
    //
    // الصف الكامل كان محتواه في ٤٠٪ منه والباقي فراغ — نفس الجدول
    // المكسور بتاع قايمة الخدمات. وستة اقتراحات في ستة صفوف طويلة
    // معناها إن العميل بيسكرول عشان يشوف الاختيارات، وهو ده بالظبط
    // الشغل اللي البند ده شايله عنه.
    //
    // عمودين = الستة كلهم في تلات صفوف، **كلهم في نظرة واحدة**.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.chipGap.w;
        final cellWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.chipGap.h,
          children: [
            for (final slot in proposals)
              SizedBox(
                width: cellWidth,
                child: _ProposalCell(
                  slot: slot,
                  baselinePrice: baselinePrice,
                  isSelected: selectedSlot?.startAt == slot.startAt,
                  onTap: () => onSlotTap(slot),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final SlotPeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill.r);

    return Material(
      color: isSelected
          ? AppSemanticColors.accentSoft
          : AppSemanticColors.surfaceSunken,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.standard,
          // **٤٥ — فوق الحد الأدنى للمس (٤٤).**
          //
          // كانت الحشوة الرأسية ٨ حوالين نص ٢١، يعني الشيب **٣٧** — تحت
          // الحد بسبع نقط. وده فلتر بيتداس بالإبهام وسط قايمة، مش لابل.
          // شيبس المواعيد نفسها (`_SlotChip`) ٤٤ من زمان.
          //
          // ⚠ **الحل حشوة، مش `constraints` + `alignment`.** `Container`
          // اللي عنده `alignment` بيفرد لأقصى عرض متاح — وجوه `Wrap`
          // العرض المتاح هو الصف كله، فالتلات شيبس بقوا تلات صفوف كاملة.
          // الأفقي فضل ١٢ زي ما كان: التلات نوافذ لازم يدخلوا في **سطر
          // واحد** على ٣٧٥، و١٦ كانت بتنزّل «مساءً» لسطر تاني.
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12.w,
            vertical: AppSpacing.s12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? AppSemanticColors.accent : Colors.transparent,
            ),
          ),
          child: Text(
            period.label,
            style: AppTextStyles.bodyMdStrong.copyWith(
              color: isSelected
                  ? AppSemanticColors.accent
                  : AppSemanticColors.textOnSunken,
            ),
          ),
        ),
      ),
    );
  }
}

/// خلية اقتراح — **الوقت هو البطل، واليوم فوقه**.
///
/// ## ليه الوقت أكبر من اليوم
///
/// العميل بيمسح بعينه على **الأوقات** — «فيه حاجة ٦ ونص؟». اليوم بيحدد
/// أنهي اقتراح، بس الوقت هو اللي بيتقارن. لما الاتنين اتساووا في الحجم
/// (النسخة الأولى) العين مكانش عندها نقطة ترسو عليها.
///
/// والخلية عرضها نص الشاشة عشان الستة كلهم يبانوا مع بعض — اقتراح مش
/// شايفه مش اقتراح.
class _ProposalCell extends StatelessWidget {
  final SlotUiModel slot;
  final double baselinePrice;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProposalCell({
    required this.slot,
    required this.baselinePrice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.m.r);
    final hasDifferentPrice = slot.price != baselinePrice;

    return Material(
      color: isSelected
          ? AppSemanticColors.accentSoft
          : AppSemanticColors.surfaceSunken,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.standard,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12.w,
            vertical: AppSpacing.s12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? AppSemanticColors.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **سطرين دايمًا — الخلايا لازم تبقى بنفس الارتفاع.**
              //
              // فرق السعر كان سطر تالت بيظهر في بعض الخلايا بس، فالصف
              // كان بيطلع مسنن والشبكة بتبطّل تبان شبكة. مكانه هنا جنب
              // اليوم: السطر ده فيه مساحة فاضية أصلاً (اسم اليوم قصير)،
              // والفرق بيفضل مقروء من غير ما يزوّد سطر.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppFormat.relativeDate(slot.startAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppSemanticColors.accent : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.r,
                      color: AppSemanticColors.accentText,
                    )
                  // فرق السعر سببه **مين فاضي** مش الساعة، وهو حقيقي في
                  // السيرفر (`effective_price` بيختلف لكل أخصائي).
                  else if (hasDifferentPrice)
                    Text(
                      '+${AppFormat.digits((slot.price - baselinePrice).toInt())}',
                      style: AppTextStyles.overline,
                    ),
                ],
              ),
              verticalSpace(AppSpacing.titleToSubtitle),
              Text(
                AppFormat.time(slot.startAt),
                maxLines: 1,
                style: AppTextStyles.cardTitle.copyWith(
                  color: isSelected ? AppSemanticColors.accent : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
