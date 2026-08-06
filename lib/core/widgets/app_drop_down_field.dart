import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// قايمة منسدلة — **نفس شكل [AppTextFormField] بالظبط**.
///
/// كانت بتكتب حدودها الأربعة وحشوتها ولون قايمتها بإيدها بنفس الشكل اللي
/// الحقل كان بيعمله — يعني نفس ٤٠ سطر متكرّرين في ملفين. أول ما استدارة
/// الحقول اتغيّرت من ٢٠ لـ ١٢، الحقل اتغيّر والقايمة فضلت ٢٠ لو محدش فتح
/// الملف ده.
///
/// دلوقتي الاتنين بيقروا من `inputDecorationTheme`، فالقاعدة مكتوبة في مكان
/// واحد.
class AppDropDownField<T> extends StatelessWidget {
  /// اللابل اللي بيقعد فوق — نفس قاعدة [AppTextFormField].
  final String? label;

  final String hintText;
  final List<T> items;
  final T? value;

  /// النص اللي بيتعرض لكل عنصر. كان `element.name` على `dynamic` — يعني
  /// أي نوع مالوش `name` كان بيقع **وقت التشغيل** مش وقت التحليل.
  final String Function(T item) itemLabel;

  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const AppDropDownField({
    super.key,
    this.label,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 300.h,
      dropdownColor: AppSemanticColors.surfaceRaised,
      borderRadius: AppRadius.rS,
      style: AppTextStyles.bodyLg,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppSemanticColors.textSecondary,
        size: 22.r,
      ),
      validator: validator,
      onChanged: enabled ? onChanged : null,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLg,
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        fillColor: enabled
            ? AppSemanticColors.surfaceRaised
            : AppSemanticColors.surfaceSunken,
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s12.h,
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: AppSpacing.s8.h,
            start: AppSpacing.s4.w,
          ),
          child: Text(label!, style: AppTextStyles.fieldLabel),
        ),
        field,
      ],
    );
  }
}
