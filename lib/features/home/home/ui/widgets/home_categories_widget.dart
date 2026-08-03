import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// صف التصنيفات — `ListView.builder` أفقي، **كل تصنيف بلاطة بيضا**.
///
/// ## البلاطة رجعت — وطبق الأيقونة لأ
///
/// النسخة اللي قبل دي شالت كل حاجة: التصنيف بقى أيقونة واسم قاعدين على
/// الصفحة مباشرة. ده حلّ مشكلة الزحام، بس خلق واحدة تانية — **التصنيف
/// بطّل يبان إنه قابل للضغط**. أيقونة رمادية جنب نص رمادي على أرضية
/// دافية بتقرا «عنوان قسم»، مش «اضغط هنا».
///
/// البلاطة البيضا بترجّع الإشارة دي: سطح مرفوع = هدف لمس. والصفحة دافية
/// (`page`) فالأبيض عليها ليه حد واضح من غير ما يحتاج ظل تقيل.
///
/// **بس طبق الأيقونة الدايرة ماترجعش.** ده كان الصندوق التاني جوه نفس
/// العنصر — بلاطة جوه بلاطة. الأيقونة على أرضية البلاطة مباشرة كفاية،
/// والفرق بين ٨ صناديق و٤ هو اللي كان بيدوّخ الشاشة.
///
/// **والأيقونة بتفضل رمادية.** ٦ أيقونات خضرا هنا كانت أكبر سبب إن
/// الأخضر بطّل يعلّم حاجة في الهوم.
class HomeCategoriesWidget extends StatelessWidget {
  /// عرض العنصر — **١٠٠ مش ٩٢**.
  ///
  /// البلاطة بتاكل ١٢ حشوة من كل جنب، فلو فضلت ٩٢ كان الباقي للنص ٦٨
  /// و«عناية بالبشرة» كانت هتتلف تلات سطور. الـ ١٠٠ بترجّع نفس الـ ٧٦
  /// المتاحة للنص.
  static const double itemWidth = 100;

  /// حشوة البلاطة.
  static const double tilePadding = AppSpacing.s12;

  /// المسافة بين بلاطة وبلاطة.
  ///
  /// رجعت ٨ لما البلاطة رجعت. الـ ٢٤ اللي كانت هنا كانت بتعوّض إن مفيش
  /// حواف — دلوقتي الحافة نفسها بتفصل، و٢٤ فوقها كانت هتفكّك الصف.
  static const double itemGap = AppSpacing.chipGap;

  /// مقاس الأيقونة. كانت ٢٠ جوه طبق ٣٦ — بره الطبق الـ ٢٠ بتبقى ضايعة،
  /// فطلعت ٢٨ عشان تفضل مرساة الصف من غير ما توزن أكتر من الاسم.
  static const double iconSize = 28;

  /// الجزء اللي مالوش دعوة بمقياس الخط: حشوة ١٢ فوق + ١٢ تحت + أيقونة ٢٨
  /// + ٨ (`s8`) + ٤ (`s4`). **المجموع ٦٤.**
  static const double _fixedPart = 64;

  /// النص عند مقياس ١٫٠: سطرين اسم (`captionInk` ١٢×١٫٤٠×٢ = ٣٣٫٦)
  /// + العدد (`overline` ١١×١٫٣٠ = ١٤٫٣). **المجموع ٤٧٫٩.**
  static const double _textPart = 47.9;

  /// كان **٩٦ ثابت والمحتوى بيطلع ١١٣٫٦** لما اسم التصنيف يتلف سطرين —
  /// فيضان مضمون مش احتمال. وحتى بعد ما بقى ١٢٤، **الرقم الثابت فاض تاني
  /// عند مقياس خط ١٫٣** (`OVERFLOWED BY 8.4 PIXELS` على «مساج واسترخاء»).
  ///
  /// الحل مش رقم أكبر — الحل إن الجزء اللي فيه نص يكبر مع النص لوحده.
  /// الإجمالي دلوقتي **٨٧٫٩ عند ١٫٠ و١٠٢٫٣ عند ١٫٣** (٤٠ + ٤٧٫٩×١٫٣).
  static double itemHeight(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: _fixedPart,
    text: _textPart,
  );

  final List<CategoryUiModel> categories;
  final bool isLoading;
  final ValueChanged<CategoryUiModel> onCategoryTap;

  const HomeCategoriesWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.isLoading = false,
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
        itemCount: isLoading ? 4 : categories.length,
        separatorBuilder: (_, __) => horizontalSpace(itemGap),
        itemBuilder: (context, index) {
          if (isLoading) return const _CategorySkeleton();

          final category = categories[index];
          return _CategoryItem(
            category: category,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryUiModel category;
  final VoidCallback onTap;

  const _CategoryItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      radius: AppRadius.m,
      padding: EdgeInsets.all(HomeCategoriesWidget.tilePadding.r),
      child: SizedBox(
          width:
              (HomeCategoriesWidget.itemWidth -
                      HomeCategoriesWidget.tilePadding * 2)
                  .w,
          child: Column(
            children: [
              Icon(
                _iconFor(category.name),
                size: HomeCategoriesWidget.iconSize.r,
                // **خضرا — لون البراند.**
                //
                // كانت رمادية بحجة إن ٦ أيقونات خضرا بتخفّف قيمة الأخضر
                // في الهوم. الحجة دي اتراجعنا عنها: الرمادي خلّى صف
                // التصنيفات يقرا **معطّل** — ٦ مربعات بيضا فيها أيقونة
                // رمادية ونص رمادي مافيهاش حاجة تقول إنها بتتداس.
                //
                // والأخضر هنا مش بيزاحم حاجة: البؤرة الحقيقية في الهوم
                // شريط غامق (`surfaceInk`/`surfaceAccentDeep`) بيكسب على
                // أي أيقونة بالحجم واللون.
                //
                // التباين مع الكارت الأبيض 3.96:1 — فوق حد الـ3:1
                // المطلوب لعنصر واجهة مش نص.
                color: AppSemanticColors.accent,
              ),
              verticalSpace(AppSpacing.s8),
              // `Expanded` عشان العدد يقعد على نفس الخط في كل العناصر.
              // من غيره الاسم اللي سطر واحد بيرفع عدده فوق عن اللي سطرين،
              // والصف بيقرا مايل. المساحة محجوزة لسطرين أصلًا في الارتفاع.
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionInk,
                ),
              ),
              if (category.servicesCount > 0)
                Text(
                  '${AppFormat.digits(category.servicesCount)} خدمة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // الرمادي بقى `textSecondary` مش `textOnSunken` — مفيش
                  // سطح غاطس تحته دلوقتي (القيمتين نفس اللون، الفرق إن
                  // الاسم بقى بيوصف المكان الصح).
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
  /// كلها `_rounded` — كان فيه خلط `_outlined`/`_rounded` في نفس الصف،
  /// وده بيبان كأن الأيقونات من مكتبتين مختلفتين.
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
/// كان `SkeletonBoxWidget` واحد بعرض ٩٢ وارتفاع الصف كله واستدارة ١٦،
/// يعني التحميل كان بيرسم بالظبط الصناديق اللي احنا شايلينها، والصفحة
/// بتتغيّر شكلها لما الداتا توصل. دلوقتي بيرسم أيقونة وسطرين وعدد.
///
/// الارتفاع بيتقرا من [HomeCategoriesWidget.itemHeight] فمفيش احتمال
/// إن اللستة تنطّ بين حالة وحالة.
class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HomeCategoriesWidget.itemWidth.w,
      height: HomeCategoriesWidget.itemHeight(context).h,
      // موجة واحدة للعنصر كله — الأربع مستطيلات جواها `animate: false`،
      // من غير كده كل مستطيل بيعمل موجته لوحده والنتيجة وميض عشوائي.
      child: SkeletonGroupWidget(
        child: Column(
          children: [
            SkeletonBoxWidget(
              width: HomeCategoriesWidget.iconSize,
              height: HomeCategoriesWidget.iconSize,
              radius: AppRadius.xs,
              animate: false,
            ),
            verticalSpace(AppSpacing.s8),
            // الأعراض بتقلّ سطر ورا سطر زي الاسم الحقيقي لما يتلف.
            const SkeletonBoxWidget(width: 72, height: 10, animate: false),
            verticalSpace(AppSpacing.s4),
            const SkeletonBoxWidget(width: 48, height: 10, animate: false),
            verticalSpace(AppSpacing.s8),
            const SkeletonBoxWidget(width: 40, height: 8, animate: false),
          ],
        ),
      ),
    );
  }
}
