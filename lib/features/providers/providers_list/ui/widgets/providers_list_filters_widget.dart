import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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

          // **[AppChipWidget] مش سطح مكتوب بالإيد.**
          //
          // الشيب القديم كان `AppSurfaceWidget` أخضر مصمت وقت الاختيار
          // بنص `labelOnAccent`. شيب الكيت بيقول الاختيار **بحد وسطح
          // فاتح** بدل تعبئة صارخة — والفرق مش تجميل: صف فيه ست شيبس
          // واحدة منهم خضرا مصمتة كان بيسحب العين من قايمة المحلات نفسها.
          //
          // وارتفاع الـ٤٤ بقى جوّه الشيب (`minHeight: touchTarget`) بدل
          // ما يكون على الـ`SizedBox` اللي فوق.
          return AppChipWidget(
            label: category.name,
            isSelected: category.uuid == selectedCategoryUuid,
            onTap: () => onCategoryTap(category.uuid),
          );
        },
      ),
    );
  }
}
