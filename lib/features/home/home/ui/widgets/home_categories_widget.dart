import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_gradients.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// صف التصنيفات — **طبق دائري لكل تصنيف**.
///
/// من الـ design DNA:
/// > `Circular service category icons with stroke icons and amber highlight
/// > ring for active state arranged in a horizontal scroll row`
///
/// ## من بلاطة بيضا لطبق دائري
///
/// النسخة اللي قبل دي كانت بلاطة بيضا مرفوعة لكل تصنيف. البلاطة كانت بتحل
/// مشكلة حقيقية («ده قابل للضغط؟») بس بتخلق واحدة تانية: **٦ كروت بيضا
/// مرفوعة فوق صف الرئيسية بيتنافسوا مع كروت المحلات اللي تحتها بالظبط**،
/// والاتنين بنفس السطح ونفس الظل ونفس الاستدارة.
///
/// الطبق الدائري بيفصل النوعين من غير ما يخسر إشارة الضغط: **الدايرة مش شكل
/// كارت في الأبلكيشن كله**، فهي بتقرا كزرار تلقائيًا. والطبق غاطس مش مرفوع،
/// فالكروت اللي تحت بتفضل هي الصوت الأعلى.
///
/// ## الحلقة
///
/// المختار بياخد خلفية `accentSoft` **وحلقة `accent` بسمك ٢**. الحلقة دي
/// إشارة تانية جنب اللون — والقاعدة إن أي حالة اختيار لازمها إشارتين، عشان
/// اللون لوحده بيضيع في الشمس وعلى شاشة رخيصة.
class HomeCategoriesWidget extends StatelessWidget {
  /// عرض العنصر.
  ///
  /// **٨٤ مش ١٠٠**: الطبق بقى ٥٦ ومفيش حشوة بلاطة تاكل من الجناب، فالعرض
  /// المتاح للنص بقى ٨٤ كامل بدل ٧٦ — أوسع من الأول مع إن الرقم أصغر.
  static const double itemWidth = 84;

  /// قطر الطبق الدائري.
  static const double plateSize = 56;

  /// مقاس الأيقونة جوه الطبق.
  static const double iconSize = 26;

  /// المسافة بين طبق وطبق.
  static const double itemGap = AppSpacing.s12;

  /// الجزء اللي مالوش دعوة بمقياس الخط: طبق ٥٦ + ٨ + ٤. **المجموع ٦٨.**
  static const double _fixedPart = plateSize + AppSpacing.s8 + AppSpacing.s4;

  /// النص عند مقياس ١٫٠: سطرين اسم (`captionInk` ١٢×١٫٤٠×٢ = ٣٣٫٦)
  /// + العدد (`overline` ١١×١٫٣٠ = ١٤٫٣). **المجموع ٤٧٫٩.**
  static const double _textPart = 47.9;

  /// الارتفاع الوحيد للصف — **والـ skeleton بيقراه من هنا**.
  ///
  /// الرقم الثابت كان بيفيض عند مقياس خط ١٫٣ (`OVERFLOWED BY 8.4 PIXELS` على
  /// «مساج واسترخاء»). الحل مش رقم أكبر — الحل إن الجزء اللي فيه نص يكبر مع
  /// النص لوحده.
  static double itemHeight(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: _fixedPart,
    text: _textPart,
  );

  final List<CategoryUiModel> categories;
  final bool isLoading;
  final ValueChanged<CategoryUiModel> onCategoryTap;

  /// التصنيف المختار — `null` في الرئيسية (مفيش اختيار، الضغط بينقل).
  /// بيتملى في شاشة الاستكشاف حيث الصف بيشتغل كفلتر.
  final String? selectedUuid;

  const HomeCategoriesWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.isLoading = false,
    this.selectedUuid,
  });

  @override
  Widget build(BuildContext context) {
    final height = itemHeight(context);

    return SizedBox(
      height: height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // الصف مش ملفوف في هامش الصفحة عن قصد — بياخد العرض كله وبيعيد
        // الهامش كـ scroll padding، فآخر عنصر بيتقص من الحافة وده اللي
        // بيقول «فيه كمان».
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.pageGutter.w,
        ),
        itemCount: isLoading ? 5 : categories.length,
        separatorBuilder: (_, __) => horizontalSpace(itemGap),
        itemBuilder: (context, index) {
          if (isLoading) return _CategorySkeleton();

          final category = categories[index];
          return _CategoryItem(
            category: category,
            isSelected: selectedUuid != null && selectedUuid == category.uuid,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryUiModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rS,
        child: SizedBox(
          width: HomeCategoriesWidget.itemWidth.w,
          child: Column(
            children: [
              AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                height: HomeCategoriesWidget.plateSize.r,
                width: HomeCategoriesWidget.plateSize.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // **قرص محدّب مش خرم.**
                  //
                  // الطبق المسطّح بيقرا كفراغ في الصفحة، وخمس دواير مسطّحة
                  // ورا بعض بتقرا كصف عناصر نائبة. التدرّج المضوّي من فوق
                  // بيخليها تقرا كأجسام، والفرق ده هو الفرق بين «صف تصنيفات»
                  // و«placeholder».
                  gradient: isSelected
                      ? AppGradients.plateSelected
                      : AppGradients.plate,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: AppSemanticColors.accent,
                          width: 2.r,
                        )
                      : null,
                ),
                child: Icon(
                  _iconFor(category.name),
                  size: HomeCategoriesWidget.iconSize.r,
                  // **خضرا — لون البراند.**
                  //
                  // كانت رمادية بحجة إن ٦ أيقونات خضرا بتخفّف قيمة الأخضر في
                  // الهوم. الحجة دي اتراجعنا عنها: الرمادي خلّى الصف يقرا
                  // **معطّل**. والأخضر هنا مش بيزاحم حاجة — البؤرة الحقيقية
                  // في الرئيسية شريط غامق بيكسب على أي أيقونة بالحجم واللون.
                  color: AppSemanticColors.accent,
                ),
              ),
              verticalSpace(AppSpacing.s8),
              // `Expanded` عشان العدد يقعد على نفس الخط في كل العناصر. من
              // غيره الاسم اللي سطر واحد بيرفع عدده فوق عن اللي سطرين، والصف
              // بيقرا مايل.
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: isSelected
                      ? AppTextStyles.captionInk.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : AppTextStyles.captionInk,
                ),
              ),
              if (category.servicesCount > 0)
                Text(
                  '${AppFormat.digits(category.servicesCount)} خدمة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline.copyWith(
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// أيقونة مؤقتة لحد ما صور التصنيفات تيجي من السيرفر.
  ///
  /// كلها `_rounded` — كان فيه خلط `_outlined`/`_rounded` في نفس الصف، وده
  /// بيبان كأن الأيقونات من مكتبتين مختلفتين.
  IconData _iconFor(String name) => switch (name) {
    'حلاقة رجالي' => Icons.content_cut_rounded,
    'كوافير حريمي' => Icons.face_retouching_natural_rounded,
    'عناية بالبشرة' => Icons.spa_rounded,
    'مساج واسترخاء' => Icons.self_improvement_rounded,
    'أظافر' => Icons.back_hand_rounded,
    _ => Icons.medical_services_rounded,
  };
}

/// التحميل بشكل العنصر نفسه — **مش مستطيل واحد بمقاس البلاطة**.
///
/// الارتفاع بيتقرا من [HomeCategoriesWidget.itemHeight] فمفيش احتمال إن
/// اللستة تنطّ بين حالة وحالة.
class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HomeCategoriesWidget.itemWidth.w,
      height: HomeCategoriesWidget.itemHeight(context).h,
      // موجة واحدة للعنصر كله — اللي جواها `animate: false`، من غير كده كل
      // مستطيل بيعمل موجته لوحده والنتيجة وميض عشوائي.
      child: SkeletonGroupWidget(
        child: Column(
          children: [
            // دايرة زي الطبق الحقيقي — الاستدارة نص القطر.
            SkeletonBoxWidget(
              width: HomeCategoriesWidget.plateSize,
              height: HomeCategoriesWidget.plateSize,
              radius: HomeCategoriesWidget.plateSize / 2,
              animate: false,
            ),
            verticalSpace(AppSpacing.s8),
            const SkeletonBoxWidget(width: 64, height: 10, animate: false),
            verticalSpace(AppSpacing.s4),
            const SkeletonBoxWidget(width: 44, height: 10, animate: false),
            verticalSpace(AppSpacing.s8),
            const SkeletonBoxWidget(width: 36, height: 8, animate: false),
          ],
        ),
      ),
    );
  }
}
