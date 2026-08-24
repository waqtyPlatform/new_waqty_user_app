import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';

/// زرار أيقونة دايري.
///
/// الدايرة دي مكتوبة **تسع مرات** في employee-app — مرة في كل هيدر. هنا
/// مرة واحدة، وبرّه الهيدر عشان مايبقاش هو بيتها الوحيد.
class AppIconButtonWidget extends StatelessWidget {
  const AppIconButtonWidget({
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
    this.background,
    this.foreground,
    this.border,
    this.tooltip,
    super.key,
  });

  final IconData icon;

  /// `null` = معطّل.
  final VoidCallback? onTap;

  /// ⚠ الافتراضي [AppSpacing.headerHeight] (٤٨) وأقل حاجة مسموحة
  /// [AppSpacing.touchTarget] (٤٤).
  final double? size;

  final double? iconSize;
  final Color? background;
  final Color? foreground;
  final Color? border;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final resolved = (size ?? AppSpacing.headerHeight).clamp(
      AppSpacing.touchTarget,
      double.infinity,
    );
    final enabled = onTap != null;

    final button = Material(
      color: background ?? AppSemanticColors.surfaceSunken,
      shape: CircleBorder(
        side: border == null
            ? BorderSide.none
            : BorderSide(color: border!, width: 1.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: resolved.r,
          height: resolved.r,
          child: Icon(
            icon,
            size: (iconSize ?? 20).r,
            color: enabled
                ? (foreground ?? AppSemanticColors.textPrimary)
                : AppSemanticColors.textTertiary,
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// نسخة مربّعة باستدارة — للأزرار اللي جنب الحقول.
class AppSquareIconButtonWidget extends StatelessWidget {
  const AppSquareIconButtonWidget({
    required this.icon,
    required this.onTap,
    this.size,
    this.background,
    this.foreground,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final resolved = (size ?? AppSpacing.touchTarget).clamp(
      AppSpacing.touchTarget,
      double.infinity,
    );

    return Material(
      color: background ?? AppSemanticColors.surfaceSunken,
      borderRadius: AppRadius.rXs,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rXs,
        child: SizedBox(
          width: resolved.r,
          height: resolved.r,
          child: Icon(
            icon,
            size: 20.r,
            color: onTap == null
                ? AppSemanticColors.textTertiary
                : (foreground ?? AppSemanticColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
