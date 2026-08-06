import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// شريط البحث الحقيقي.
///
/// الـ controller جاي من الـ Cubit مش متعمل هنا — القديم كان بيتعمل جوه
/// `build()` فأي rebuild كان بيمسح اللي العميل كتبه.
///
/// الحقل غاطس فوق صفحة دافية، يعني كل اللي جواه ماشي على قاعدة
/// [AppSemanticColors.textOnSunken] — مفيش حاجة أفتح من كده تقعد على الغاطس.
class ProvidersListSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  const ProvidersListSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: (_) => onChanged(),
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(
        hintText: 'دوّر على صالون أو منطقة',
        // اللون متكتوب صريح مش مستني `bodyMdMuted` — لو اتظبط يوم لأفتح،
        // الهنت هنا **مايتأثرش**.
        hintStyle: AppTextStyles.bodyMdMuted.copyWith(
          color: AppSemanticColors.textOnSunken,
        ),
        filled: true,
        fillColor: AppSemanticColors.surfaceSunken,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22.r,
          color: AppSemanticColors.textOnSunken,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: AppSemanticColors.textOnSunken,
                ),
              ),
        contentPadding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s.r),
          borderSide: BorderSide(color: AppSemanticColors.accent, width: 1.5.r),
        ),
      ),
    );
  }
}
