import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// شريط البحث في الهوم — **زرار مش TextField**.
///
/// القديم كان `TextField` حقيقي بـ controller بيتعمل جوه `build()` (يعني
/// أي rebuild بيمسح اللي العميل كتبه) و `onChange` كله كومنت. فالعميل كان
/// بيكتب وما يحصلش حاجة.
///
/// خليناه زرار بيودّي على شاشة بحث كاملة — ده الشكل الصح في أي marketplace،
/// لأن نتايج البحث محتاجة فلاتر وترتيب وحالة فاضية، ومكانهاش شريط في الهوم.
class HomeSearchWidget extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      // **غاطس.** ده كروم بحث، والمفروض يترجع لورا عشان الكروت اللي تحته
      // هي اللي تسحب العين. لو رفعناه بظل هيتنافس مع المحتوى.
      level: AppElevation.sunken,
      // ١٢ — **نفس استدارة الحقول** من الـ DNA. ده كروم بحث، ولازم يقرا من
      // نفس عيلة الحقول مش من عيلة الكروت.
      radius: AppRadius.s,
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 24.r,
            color: AppSemanticColors.textOnSunken,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(
            child: Text(
              'دوّر على صالون أو خدمة',
              style: AppTextStyles.bodyMdMuted,
            ),
          ),
        ],
      ),
    );
  }
}
