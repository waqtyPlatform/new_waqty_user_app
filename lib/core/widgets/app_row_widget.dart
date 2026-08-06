import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// صف في قايمة — **كارت أبيض**.
///
/// ## ليه رجعت كروت
///
/// النسخة اللي قبل دي كانت صفوف مسطّحة قاعدة على الصفحة ومفصولة بخط
/// شعري، والحجة كانت إن N كارت = N ظل = ضوضاء.
///
/// الحجة دي بتشتغل على شاشة فيها عنصر واحد بيحارب على الانتباه. بس
/// الأبلكيشن ده **مالوش صور** — كل صف نص رمادي وحرف في مربّع. من غير
/// سطح، القايمة بتتحوّل لعمود نص متواصل: مفيش حد يقول فين المحل ده
/// بيخلص وفين اللي بعده يبدأ، والصف بطّل يبان إنه هدف لمس.
///
/// الكارت بيرجّع التلات حاجات دي مرة واحدة: **حد**، و**فصل**، و**إشارة
/// إنه بيتداس**. والظل خفيف (`AppShadows`) فمفيش تكويم بصري.
///
/// ## الهامش جوه الصف
///
/// الـ `ListView` بيفضل من غير هامش أفقي، والكارت بياخد هامشه بنفسه —
/// عشان اللي بينده مايحتاجش يعرف إن ده كارت ولا صف.
class AppRowWidget extends StatelessWidget {
  /// الخانة الأمامية — لوح حرف، أيقونة، أو أي حاجة بعرض ثابت.
  final Widget? leading;

  final Widget child;

  /// اللي بيتحط في النهاية — سعر، شارة، أو سهم.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// فيه صف بعده؟ لو أيوة بياخد مسافة تحته.
  ///
  /// الاسم فضل زي ما هو عشان مش نلمس ٦ ملفات — بس معناه بقى «فاصل»
  /// مش «خط». آخر صف في القايمة بياخد `false` فمابياخدش مسافة زيادة.
  final bool showHairline;

  /// مابقاش ليه لازمة بعد ما الصف بقى كارت — الفصل بقى بالحافة مش بخط.
  /// اتساب في الـ API عشان النداءات الموجودة ما تتكسرش.
  final double? hairlineIndent;

  /// **ارتفاع الكارت كله — بالحشوة.**
  ///
  /// ده العقد اللي كل الصفوف مكتوبة عليه: `_fixedPart` في
  /// `ProviderRowWidget` و`MyBookingRowWidget` وصف الخدمة **بيحسبوا حشوة
  /// الكارت جوه الرقم**، والـ skeletons بترسم `SizedBox(heightOf)` وبتحط
  /// حشوتها جواه.
  ///
  /// ⚠ الـ widget ده كان بيخالف العقد: بيدي الرقم للصندوق الداخلي **و**
  /// يزوّد ٣٢ حشوة فوقه — يعني **كل كارت في الأبلكيشن كان أطول ٣٢ نقطة
  /// من اللي اتحسب له**، وكل صف skeleton كان أقصر من صفه الحقيقي بنفس
  /// الرقم (اللستة بتنطّ لما الداتا توصل).
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
    final padding = AppSpacing.cardPadding.r;

    // الحشوة بتتشال من الارتفاع المطلوب — اللي بيوصل الصندوق الداخلي هو
    // مساحة المحتوى. `clamp` عشان ارتفاع أصغر من الحشوة مايطلعش سالب.
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
        radius: AppRadius.m,
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          height: contentHeight,
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
    );
  }
}
