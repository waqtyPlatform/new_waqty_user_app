import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon_widget.dart';

/// قايمة منسدلة — **generic**.
///
/// نسخة employee-app بتاخد `List<dynamic>` وبتفترض إن العنصر نص. هنا
/// النوع محفوظ و[labelOf] هي اللي بتحوّله لنص، فالـ dropdown بيشتغل على
/// أي موديل من غير ما الكيت يعرف حاجة عنه.
class AppDropDownField<T> extends StatelessWidget {
  const AppDropDownField({
    required this.items,
    required this.labelOf,
    required this.onChanged,
    required this.hintText,
    this.value,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    super.key,
  });

  final List<T> items;

  /// بتحوّل العنصر لنص معروض. **نص جاهز — مش مفتاح ترجمة.**
  final String Function(T item) labelOf;

  final ValueChanged<T?> onChanged;
  final String hintText;
  final T? value;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      // ⚠ **`Clip.hardEdge` على القايمة نفسها.** من غيره العنصر الطويل
      // بيفيض بره المنسدلة بدل ما يتقص.
      menuMaxHeight: 300.h,
      borderRadius: AppRadius.rS,
      dropdownColor: AppSemanticColors.surfaceRaised,
      icon: AppIconWidget(
        AppIcons.chevronDown,
        size: 22,
        color: AppSemanticColors.textSecondary,
      ),
      style: AppTextStyles.bodyLg,
      hint: Text(
        hintText,
        style: AppTextStyles.bodyLg.copyWith(
          color: AppSemanticColors.textTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        fillColor: enabled
            ? AppSemanticColors.surfaceRaised
            : AppSemanticColors.surfaceSunken,
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(
              labelOf(item),
              style: AppTextStyles.bodyLg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
