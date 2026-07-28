import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// شريط «مفيش نت» — بيظهر لوحده وبيروح لوحده.
///
/// قطع الاتصال **حالة مش خطأ**. الـ dialog القديم كان بيقفل الشاشة كلها،
/// وكل مرة الاتصال يقطع بيتفتح واحد جديد فوق التاني — فالعميل يقفل خمسة
/// ورا بعض. وكمان الترجمة بتاعته ناقصة في اللغتين فكان بيعرض
/// `noInternet` و `ok` نص خام.
///
/// الـ dialog يتستخدم في حالة واحدة بس: لما العميل يبعت حاجة وتفشل.
class OfflineBannerWidget extends StatelessWidget {
  final bool isVisible;

  const OfflineBannerWidget({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.slow,
      switchInCurve: AppMotion.standard,
      child: !isVisible
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: AppSemanticColors.surfaceInverse,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
                vertical: AppSpacing.chipGap.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 16.r,
                    color: AppSemanticColors.textOnAccent,
                  ),
                  horizontalSpace(AppSpacing.s8),
                  Flexible(
                    child: Text(
                      'مفيش اتصال بالإنترنت — هنحاول تاني لوحدنا',
                      style: AppTextStyles.captionStrong.copyWith(
                        color: AppSemanticColors.textOnAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
