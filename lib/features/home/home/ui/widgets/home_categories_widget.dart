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
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// صف التصنيفات — **كارت لكل تصنيف، والعدد جواه**.
///
/// ## ليه رجع كارت بعد ما كان طبق دائري
///
/// النسخة اللي فاتت كانت دايرة سايبة والاسم والعدد نص طايح تحتها. اتشالت
/// لسببين اتقالوا من الاستخدام الحقيقي:
///
/// **١. العدد كان بيقرا إنه مش تابع لحاجة.** «٢٤ خدمة» كانت آخر سطر في
/// عمود مالوش حدود، فمافيش حاجة بتقول إنها بتوصف التصنيف اللي فوقها —
/// وبينها وبين اسم التصنيف مسافة زي المسافة بينها وبين اللي بعدها.
///
/// **٢. الدايرة بتتقص وحش.** الصف بيسيب آخر عنصر مقصوص من الحافة عشان
/// يقول «فيه كمان». الكارت المقصوص بيقرا كارت ناقص — إشارة مفهومة. **نص
/// الدايرة بيقرا عطل رسم**، لأن الدايرة مالهاش حالة «نصها بس».
///
/// الاعتراض القديم (إن الكروت هتزاحم كروت المحلات اللي تحت) اتحل من غير ما
/// نرجع للدايرة: الكارت هنا **غاطس مش مرفوع** ومقاسه نص كارت المحل، فبيقرا
/// كصف كنترولات مش كصف محتوى.
///
/// ## الحلقة
///
/// المختار بياخد خلفية `accentSoft` **وحلقة `accent` بسمك ٢**. الحلقة دي
/// إشارة تانية جنب اللون — والقاعدة إن أي حالة اختيار لازمها إشارتين، عشان
/// اللون لوحده بيضيع في الشمس وعلى شاشة رخيصة.
class HomeCategoriesWidget extends StatelessWidget {
  /// عرض الكارت.
  ///
  /// **١١٦**: العدد بقى جوه الحشوة، فالعرض المتاح للنص ١١٦ − ٢٤ = ٩٢ —
  /// كفاية لـ«مساج واسترخاء» على سطرين من غير قص.
  static const double itemWidth = 116;

  /// حشوة الكارت.
  static const double cardPadding = AppSpacing.s12;

  /// قطر الطبق الدائري جوه الكارت.
  ///
  /// **٤٠ مش ٥٦**: بقى جوه كارت، والطبق اللي بيملا عرض الكارت بيقرا خلفية
  /// مش أيقونة.
  static const double plateSize = 40;

  /// مقاس الأيقونة جوه الطبق.
  static const double iconSize = 22;

  /// المسافة بين كارت وكارت.
  static const double itemGap = AppSpacing.s12;

  /// الجزء اللي مالوش دعوة بمقياس الخط: حشوة ١٢×٢ + طبق ٤٠ + ٨ + ٤.
  /// **المجموع ٧٦.**
  static const double _fixedPart =
      (cardPadding * 2) + plateSize + AppSpacing.s8 + AppSpacing.s4;

  /// النص عند مقياس ١٫٠: سطرين اسم (`captionInk` ١٢×١٫٤٠×٢ = ٣٣٫٦)
  /// + العدد (`overline` ١١×١٫٣٠ = ١٤٫٣). المجموع الحسابي ٤٧٫٩، والرقم هنا
  /// **٤٩** لأن فلاتر بيقرّب ارتفاع السطر لأعلى وقت التشكيل.
  static const double _textPart = 49;

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
      child: AppSurfaceWidget(
        onTap: onTap,
        width: HomeCategoriesWidget.itemWidth.w,
        // **غاطس مش مرفوع.** ده صف كنترولات فوق صف محتوى — لو اتساوى مع
        // كروت المحلات في السطح والظل، الاتنين بيتنافسوا والعين بتتوه.
        level: AppElevation.sunken,
        color: isSelected ? AppSemanticColors.accentSoft : null,
        radius: AppRadius.m,
        padding: EdgeInsetsDirectional.all(
          HomeCategoriesWidget.cardPadding.r,
        ),
        border: isSelected
            ? Border.all(color: AppSemanticColors.accent, width: 2.r)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                // الطبق المسطّح بيقرا كفراغ في الكارت. التدرّج المضوّي من
                // فوق بيخليه يقرا كجسم، والفرق ده هو الفرق بين «أيقونة
                // تصنيف» و«مربع صورة ما حمّلتش».
                gradient: isSelected
                    ? AppGradients.plateSelected
                    : AppGradients.plate,
                shape: BoxShape.circle,
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
            // `Expanded` عشان العدد يقعد على نفس الخط في كل الكروت. من
            // غيره الاسم اللي سطر واحد بيرفع عدده فوق عن اللي سطرين، والصف
            // بيقرا مايل.
            Expanded(
              child: Text(
                category.name,
                maxLines: 2,
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
        // نفس حشوة الكارت الحقيقي — من غيرها الـ skeleton بيبدأ من الحافة
        // والصف بينطّ لما الداتا تيجي.
        child: Padding(
          padding: EdgeInsetsDirectional.all(
            HomeCategoriesWidget.cardPadding.r,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // دايرة زي الطبق الحقيقي — الاستدارة نص القطر.
              SkeletonBoxWidget(
                width: HomeCategoriesWidget.plateSize,
                height: HomeCategoriesWidget.plateSize,
                radius: HomeCategoriesWidget.plateSize / 2,
                animate: false,
              ),
              verticalSpace(AppSpacing.s8),
              const SkeletonBoxWidget(width: 78, height: 10, animate: false),
              verticalSpace(AppSpacing.s4),
              const SkeletonBoxWidget(width: 52, height: 10, animate: false),
              verticalSpace(AppSpacing.s8),
              const SkeletonBoxWidget(width: 40, height: 8, animate: false),
            ],
          ),
        ),
      ),
    );
  }
}
