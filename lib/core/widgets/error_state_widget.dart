import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// الخطأ بيتعرض **جوه الشاشة** وفيه زرار إعادة محاولة.
///
/// مش dialog. الـ `ErrorAlertDialog` القديم عنوانه فاضي، وبيعرض رسالة
/// السيرفر خام، ومش بيتقفل، ومفيهوش إعادة محاولة — يعني العميل بيتحبس
/// في رسالة مايفهمهاش.
///
/// **بطّل يبقى لوح أحمر كامل.** الأحمر على مساحة كبيرة بيقرا كأن الأبلكيشن
/// اتكسر، والحقيقة إن ٩٠٪ من الحالات دي نت ضعيف. دلوقتي: سطح أبيض مرفوع
/// وطبق أيقونة أحمر فاتح — الأحمر مساحته اتقلّت لـ ٤٤ بكسل بدل الشاشة.
///
/// [isCompact] للاستخدام جوه صف أفقي أو sheet — بيقلل المساحة.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isCompact;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: (isCompact ? AppSpacing.s16 : AppSpacing.s24).h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompact) ...[
            Container(
              height: 44.r,
              width: 44.r,
              decoration: const BoxDecoration(
                color: AppSemanticColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 22.r,
                color: AppSemanticColors.danger,
              ),
            ),
            verticalSpace(AppSpacing.s12),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd,
          ),
          verticalSpace(AppSpacing.s8),
          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
