import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// شيبس التصنيفات.
///
/// الشيب ٤٤ نقطة ارتفاع — القديمة كانت ٢٦ تقريبًا، أصغر من الحد الأدنى
/// للمس، وواحدة منهم كانت مرسومة كأنها متحددة ومفيش طريقة تلغي التحديد.
class ProvidersListFiltersWidget extends StatelessWidget {
  final List<CategoryUiModel> categories;
  final String selectedCategoryUuid;
  final ValueChanged<String> onCategoryTap;

  const ProvidersListFiltersWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryUuid,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // `.r` مش `.h`. الـ `ListView` الأفقي بيدّي الابن قيد **ضيق** على
      // المحور العرضي، يعني ده ارتفاع الشيب بالظبط مش حد أقصى. وعلى جهاز
      // ٦٦٧ الـ `.h` بيصغّر الـ ٤٤ لـ ٣٧٫٩ — تحت الحد الأدنى للمس، وضد
      // القاعدة المكتوبة في `AppSpacing.touchTarget` نفسه.
      height: AppSpacing.touchTarget.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.pageGutter.w,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, __) => horizontalSpace(AppSpacing.chipGap),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.uuid == selectedCategoryUuid;
          return _FilterChip(
            label: category.name,
            isSelected: isSelected,
            onTap: () => onCategoryTap(category.uuid),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // **مفيش `ValueKey(isSelected)` هنا عن قصد.** المفتاح على حالة الاختيار
    // بيعمل Element جديد كل مرة، والـ Element الجديد بيبدأ من الحالة النهائية
    // على طول — يعني **بيقتل الحركة** بدل ما يشغّلها.
    return AppSurfaceWidget(
      onTap: onTap,
      radius: AppRadius.pill,
      // مختار = أخضر مرفوع بظل أخضر خفيف · مش مختار = غاطس ساكت.
      level: isSelected ? AppElevation.raised : AppElevation.sunken,
      color: isSelected
          ? AppSemanticColors.accent
          : AppSemanticColors.surfaceSunken,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: AppMotion.base,
            curve: AppMotion.standard,
            // مش مختار = نص على غاطس، فاللون مربوط بـ `textOnSunken` صريح
            // بدل ما يستنى `bodyMdMuted` — القاعدة إن مفيش حاجة أفتح من
            // كده تقعد على الغاطس، ولازم تفضل صح لو الستايل اتظبط بعدين.
            style: isSelected
                ? AppTextStyles.labelOnAccent
                : AppTextStyles.bodyMdMuted.copyWith(
                    color: AppSemanticColors.textOnSunken,
                  ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
