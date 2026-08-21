import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_button_widget.dart';
import 'app_icon_widget.dart';

/// مؤشّر تحميل.
///
/// ## ⚠ ليه اتعاد كتابته
///
/// نسخة employee-app بتكتب `import 'dart:io'` و`Platform.isAndroid` —
/// و`dart:io` **مابيتكمبلش على الويب أصلًا**. الجاليري بتاع الكيت ويب،
/// يعني نسخة employee-app كانت هتمنع الكيت من إنه يتعرض.
///
/// `defaultTargetPlatform` بيدي نفس المعلومة من غير `dart:io`، وبيحترم
/// كمان أي `TargetPlatform` مفروض في الاختبارات.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({this.color, this.size, super.key});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppSemanticColors.accent;
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return Center(
        child: CupertinoActivityIndicator(color: tint, radius: (size ?? 14).r),
      );
    }

    return Center(
      child: SizedBox(
        width: (size ?? 28).r,
        height: (size ?? 28).r,
        child: CircularProgressIndicator(color: tint, strokeWidth: 2.5),
      ),
    );
  }
}

/// حالة الفراغ.
///
/// ⚠ **العنوان بيقول حصل إيه، والمتن بيقول اعمل إيه.** «مفيش حجوزات»
/// لوحدها مش حالة فراغ — دي رسالة خطأ من غير حل.
class AppEmptyStateWidget extends StatelessWidget {
  const AppEmptyStateWidget({
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? message;

  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// جوه كارت أو sheet — من غير أيقونة كبيرة ولا مسافات واسعة.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
        vertical: (compact ? AppSpacing.s16 : AppSpacing.s40).h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Container(
              width: 64.r,
              height: 64.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppSemanticColors.surfaceSunken,
                borderRadius: AppRadius.rM,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 28.r,
                color: AppSemanticColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),
          ],
          Text(
            title,
            style: compact ? AppTextStyles.cardTitle : AppTextStyles.titleLg,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.s4.h),
            Text(
              message!,
              style: AppTextStyles.bodyMdMuted,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppSpacing.s16.h),
            AppButtonWidget(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.secondary,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// حالة الخطأ.
///
/// ⚠ **الفرق عن حالة الفراغ إن فيه زرار إعادة.** الفراغ حالة صحيحة؛
/// الخطأ حاجة اتكسرت والعميل يقدر يجرّب تاني.
class AppErrorStateWidget extends StatelessWidget {
  const AppErrorStateWidget({
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.isCompact = false,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String message;
  final String? title;
  final String? retryLabel;

  final VoidCallback? onRetry;

  /// جوه صف أو sheet — سطر واحد وزرار صغير.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppSemanticColors.dangerSoft,
          borderRadius: AppRadius.rS,
        ),
        child: Row(
          children: [
            AppIconWidget(
              AppIcons.error,
              size: 18,
              color: AppSemanticColors.dangerOnSoft,
            ),
            SizedBox(width: AppSpacing.s8.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(
                  color: AppSemanticColors.dangerOnSoft,
                ),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: AppSpacing.s8.w),
              GestureDetector(
                onTap: onRetry,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: AppSpacing.touchTarget.r,
                  height: AppSpacing.touchTarget.r,
                  child: AppIconWidget(
                    AppIcons.refresh,
                    size: 18,
                    color: AppSemanticColors.dangerOnSoft,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return AppEmptyStateWidget(
      title: title ?? 'فيه حاجة مامشيتش',
      message: message,
      icon: Icons.wifi_off_rounded,
      actionLabel: onRetry == null ? null : (retryLabel ?? 'جرّب تاني'),
      onAction: onRetry,
    );
  }
}

/// شريط «مفيش نت» — بيتحط فوق المحتوى، واللي بينده هو اللي بيقرر يظهره.
///
/// employee-app بيعمل ده بـ`showDialog` من `navigatorKey` عام. الشريط
/// أقل عدوانية: العميل يقدر يكمّل قراية اللي محمّل عنده.
class AppOfflineBannerWidget extends StatelessWidget {
  const AppOfflineBannerWidget({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
        vertical: AppSpacing.s8.h,
      ),
      color: AppSemanticColors.surfaceInverse,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIconWidget(
            AppIcons.wifiOff,
            size: 16,
            color: AppSemanticColors.textOnInverse,
          ),
          SizedBox(width: AppSpacing.s8.w),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppSemanticColors.textOnInverse,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
