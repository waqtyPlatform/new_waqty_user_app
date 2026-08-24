import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'app_surface_widget.dart';

/// صف في قايمة — **كارت**.
///
/// الـ `ListView` بيفضل من غير هامش أفقي، والكارت بياخد هامشه بنفسه —
/// عشان اللي بينده مايحتاجش يعرف إن ده كارت ولا صف.
class AppRowWidget extends StatelessWidget {
  const AppRowWidget({
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.showHairline = true,
    this.height,
    super.key,
  });

  /// الخانة الأمامية — لوح حرف، أيقونة، أو أي حاجة بعرض ثابت.
  final Widget? leading;

  final Widget child;

  /// اللي بيتحط في النهاية — سعر، شارة، أو سهم.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// **فيه صف بعده؟** لو أيوة بياخد مسافة تحته.
  ///
  /// الاسم بيقول «خط» بس معناه **«فاصل»** — الفصل بقى بحافة الكارت مش
  /// بخط. آخر صف في القايمة بياخد `false` فمابياخدش مسافة زيادة.
  final bool showHairline;

  /// **ارتفاع الكارت كله — بالحشوة.**
  ///
  /// ده العقد اللي كل الصفوف مكتوبة عليه: أي `heightOf` بيحسب حشوة الكارت
  /// **جوه** الرقم، والـ skeleton بيقرا نفس الـ static.
  ///
  /// ⚠ السطر اللي تحت هو اللي بيحقّق العقد: الحشوة **بتتشال** من الارتفاع
  /// المطلوب قبل ما يوصل الصندوق الداخلي. من غيره الكارت بيطلع أطول من
  /// اللي اتحسب له بمقدار الحشوة × ٢، والـ skeleton بيطلع أقصر من صفه
  /// بنفس الرقم — يعني اللستة بتنطّ أول ما الداتا توصل.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.cardPadding.r;

    final contentHeight = height == null
        ? null
        : (height! - padding * 2).clamp(0.0, double.infinity);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.pageGutter.w,
        end: AppSpacing.pageGutter.w,
        bottom: showHairline ? AppSpacing.listRowGap.h : 0,
      ),
      child: AppSurfaceWidget(
        onTap: onTap,
        radius: AppRadius.s,
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          height: contentHeight,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: AppSpacing.listRowGap.w),
              ],
              Expanded(child: child),
              if (trailing != null) ...[
                SizedBox(width: AppSpacing.s8.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
