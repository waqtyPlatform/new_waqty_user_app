import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// ديالوج.
///
/// ## ⚠ ده بيستبدل `ErrorAlertDialog` و`OfflineAlertDialog` — واللي
/// اتشال منهم مهم
///
/// `OfflineAlertDialog` في employee-app **بيستورد `navigatorKey` من
/// `lib/my_app.dart`** — يعني widget في `core/` بيمدّ إيده لمدخل
/// التطبيق. الكيت **مايقدرش يملك navigator عام**، وأي حاجة بتفترض ده
/// مابتتنسخش.
///
/// والاتنين بينادوا `.tr()` على مفاتيح ترجمة متحطوطة (`"ok"`,
/// `"noInternet"`) — فحتى لو اتنسخوا، هيرسموا المفتاح نفسه في تطبيق
/// مالوش نفس ملفات اللغة.
///
/// ## إمتى ديالوج وإمتى [AppSheetWidget]
///
/// الديالوج **بيوقف الشغل** ومحتاج رد. الـ sheet بيدي اختيارات وبيتقفل
/// بالسحب. القاعدة العملية: **لو الإلغاء مقبول، خد sheet.**
class AppDialogWidget extends StatelessWidget {
  const AppDialogWidget({
    required this.title,
    required this.actions,
    this.message,
    this.icon,
    this.iconTone,
    this.content,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? message;

  final IconData? icon;
  final Color? iconTone;
  final Widget? content;
  final List<Widget> actions;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<Widget> Function(BuildContext dialogContext) actions,
    String? message,
    IconData? icon,
    Color? iconTone,
    Widget? content,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppSemanticColors.scrim,
      builder: (dialogContext) => AppDialogWidget(
        title: title,
        message: message,
        icon: icon,
        iconTone: iconTone,
        content: content,
        actions: actions(dialogContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // `Dialog.insetPadding` نوعه `EdgeInsets` مش `EdgeInsetsGeometry` —
      // وهو متماثل هنا فمافيش مشكلة اتجاه.
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s24.w,
        vertical: AppSpacing.s24.h,
      ),
      child: Padding(
        padding: AppSpacing.cardLoose,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 36.r,
                color: iconTone ?? AppSemanticColors.accentText,
              ),
              SizedBox(height: AppSpacing.s12.h),
            ],
            Text(
              title,
              style: AppTextStyles.titleLg,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.s8.h),
              Text(
                message!,
                style: AppTextStyles.bodyMdMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[
              SizedBox(height: AppSpacing.s16.h),
              content!,
            ],
            SizedBox(height: AppSpacing.s20.h),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.s8.h),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// snackbar.
///
/// ⚠ **بياخد `BuildContext` — مش `navigatorKey`.** ده الفرق اللي بيخلي
/// الملف ده قابل للنسخ.
class AppSnack {
  AppSnack._();

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: isError
            ? AppSemanticColors.danger
            : AppSemanticColors.surfaceInverse,
        content: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(
            color: isError
                ? AppSemanticColors.textOnDanger
                : AppSemanticColors.textOnInverse,
          ),
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: isError
                    ? AppSemanticColors.textOnDanger
                    : AppSemanticColors.accent,
              ),
      ),
    );
  }
}
