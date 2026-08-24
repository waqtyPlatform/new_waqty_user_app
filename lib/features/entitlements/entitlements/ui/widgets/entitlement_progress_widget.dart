import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **شريط بتلات شرايح — مستهلك · محجوز · متاح.**
///
/// ## ليه مش [AppProgressWidget]
///
/// شريط الكيت بقيمة واحدة: نسبة واحدة، لون واحد. والباقة فيها **تلات
/// كميات مختلفة المعنى**:
///
///  • **مستهلك** — راح خلاص.
///  • **محجوز** — متعلّق بميعاد جاي. لسه بتاعها، بس **مش تحت إيدها**.
///  • **متاح** — اللي تقدر تحجزه دلوقتي.
///
/// لو المحجوز اتلمّ مع المتاح، العميلة بتشوف جلسة تقدر تحجزها وهي محجوزة
/// أصلاً — وبتحاول وتتصدّ. ولو اتلمّ مع المستهلك، بتشوف جلسة ضاعت وهي لسه
/// ليها. **الشريحتين غلط في الاتجاهين**، عشان كده تلاتة.
///
/// ## التمييز مش باللون بس
///
/// المحجوز بيتعرض بلون اللمسة **الباهت** (`accentSoft`) جنب اللمسة
/// الكاملة، والفرق بينهم مقروء من غير تمييز ألوان — بس اللابل تحت الشريط
/// هو اللي بيقول المعنى بالنص، فمحدش بيحتاج يفسّر لون.
class EntitlementProgressWidget extends StatelessWidget {
  const EntitlementProgressWidget({
    required this.used,
    required this.reserved,
    required this.available,
    this.usedLabel = 'مستخدم',
    this.reservedLabel = 'محجوز',
    this.availableLabel = 'متاح',
    super.key,
  });

  final int used;
  final int reserved;
  final int available;

  final String usedLabel;
  final String reservedLabel;
  final String availableLabel;

  int get total => used + reserved + available;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill.r),
          child: SizedBox(
            height: 8.h,
            child: Row(
              children: <Widget>[
                if (used > 0)
                  Expanded(
                    flex: used,
                    child: ColoredBox(
                      color: AppSemanticColors.borderStrong,
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (reserved > 0)
                  Expanded(
                    flex: reserved,
                    child: ColoredBox(
                      color: AppSemanticColors.accentSoft,
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (available > 0)
                  Expanded(
                    flex: available,
                    child: ColoredBox(
                      color: AppSemanticColors.accent,
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSpacing.s8.h),

        // **`Wrap` مش `Row`.** تلات لابلات بأرقام في عرض ٣٧٥ عند مقياس خط
        // ١٫٣ بتفيض — والـ`Wrap` بينزّل التالت سطر تحت بدل ما يقص رقم.
        Wrap(
          spacing: AppSpacing.s12.w,
          runSpacing: AppSpacing.s4.h,
          children: <Widget>[
            if (available > 0)
              _Legend(
                color: AppSemanticColors.accent,
                label: availableLabel,
                value: available,
              ),
            if (reserved > 0)
              _Legend(
                color: AppSemanticColors.accentSoft,
                label: reservedLabel,
                value: reserved,
              ),
            if (used > 0)
              _Legend(
                color: AppSemanticColors.borderStrong,
                label: usedLabel,
                value: used,
              ),
          ],
        ),
      ],
    );
  }
}

/// نقطة لون + لابل + رقم.
///
/// ⚠ **مش `const`** — بيرسم لون، والتوكنز مش `InheritedWidget` فالـ`const`
/// مابيتبنيش تاني لما الوضع يقلب (CLAUDE.md).
class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.s4.w),
        Text(
          '$label ${AppFormat.digits(value)}',
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
