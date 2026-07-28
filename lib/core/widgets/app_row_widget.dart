import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';

/// صف في قايمة — **مش كارت**.
///
/// ## ليه القوايم بطّلت كروت
///
/// كل قايمة في الأبلكيشن كانت N كارت أبيض مرفوع ورا بعض. والكارت معناه
/// «الحاجة دي جسم منفصل ليها حدود ووزن» — لما كل صف ياخد المعاملة دي،
/// المعنى بيضيع وبيتحوّل لضوضاء: عشر ظلال في الشاشة الواحدة، والعين
/// مالهاش مكان تقع فيه.
///
/// الصف بيقعد **على الصفحة مباشرة** ومفصول بخط شعري. الكارت بيتحجز
/// للحاجات اللي فعلاً أجسام منفصلة — زي كروت الصف الأفقي اللي بتتسحب.
///
/// ## الـ full-bleed
///
/// الهامش **جوه الصف** مش على الـ `ListView`. كده الصف بياخد العرض كله،
/// والخط الشعري يقدر يمشي من حافة لحافة أو ينزاح تحت النص — قرار اللي
/// بينده، مش قيد من الأب.
class AppRowWidget extends StatelessWidget {
  /// الخانة الأمامية — لوح حرف، أيقونة، أو أي حاجة بعرض ثابت.
  final Widget? leading;

  final Widget child;

  /// اللي بيتحط في النهاية — سعر، شارة، أو سهم.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// خط شعري تحت الصف. آخر صف في القايمة بياخد `false`.
  final bool showHairline;

  /// إزاحة الخط الشعري. الافتراضي بيبدأ من تحت المحتوى مش من حافة الشاشة.
  final double? hairlineIndent;

  final double? height;

  const AppRowWidget({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.showHairline = true,
    this.hairlineIndent,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              height: height,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
                vertical: AppSpacing.cardPadding.h,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    horizontalSpace(AppSpacing.listRowGap),
                  ],
                  Expanded(child: child),
                  if (trailing != null) ...[
                    horizontalSpace(AppSpacing.s8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showHairline)
          AppHairlineWidget(
            indent: hairlineIndent ?? AppSpacing.pageGutter,
          ),
      ],
    );
  }
}
