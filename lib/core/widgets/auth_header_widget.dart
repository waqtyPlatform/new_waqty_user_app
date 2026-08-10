import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// مقدّمة شاشة المصادقة — لوجو (اختياري) + عنوان + وصف.
///
/// ## ليه widget
///
/// البلوك ده كان مكتوب **بالحرف في ست شاشات**: الدخول، التسجيل، نسيت
/// كلمة السر، وتلات شاشات الكود وإعادة التعيين. نفس الـ`titleXl`، نفس
/// الـ`s8`، نفس الـ`bodyMdMuted`، نفس الـ`s32` تحته.
///
/// ست نسخ يعني إن أي تعديل على إيقاع المقدّمة لازم يتعمل ست مرات — وأول
/// مرة حد ينسى واحدة، شاشة من الست بتبقى مختلفة عن أخواتها بمسافة مالهاش
/// سبب.
///
/// ## بيملك مسافته بنفسه
///
/// نفس قاعدة [AppSectionHeaderWidget]: `s16` فوق و`s32` تحت جوّه الـ
/// widget، فاللي بينده مايحطش `verticalSpace` حواليه. ده اللي بيمنع
/// الإيقاع يفرق من شاشة لشاشة.
class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({
    required this.title,
    required this.description,
    this.showLogo = false,
    this.trailing,
    super.key,
  });

  /// **نصوص جاهزة — الترجمة بتتعمل عند اللي بينده.**
  final String title;
  final String description;

  /// شاشتين بس فيهم لوجو: الدخول والتسجيل — دول اللي العميل ممكن يفتح
  /// عليهم الأبلكيشن. الباقي جوّه رحلة وليهم `AppBar` بسهم رجوع.
  final bool showLogo;

  /// بيقعد على الطرف التاني من صف اللوجو — مبدّل اللغة في التسجيل.
  /// بيتجاهل لو [showLogo] بـ`false`.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        verticalSpace(AppSpacing.s16),
        if (showLogo) ...[
          Row(
            children: [
              Image.asset(ImageAsset.logoImage, height: 50),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          verticalSpace(AppSpacing.s16),
        ],
        Text(title, style: AppTextStyles.titleXl),
        verticalSpace(AppSpacing.s8),
        Text(description, style: AppTextStyles.bodyMdMuted),
        verticalSpace(AppSpacing.s32),
      ],
    );
  }
}
