import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/widgets/entity_panel_widget.dart';

/// هيدر صفحة المحل.
///
/// ## الهوية بقت **فوق** الصورة
///
/// كان الهيدر لوح ملوّن وبس، والاسم والتصنيف مكتوبين تحته في أول الجسم —
/// يعني أول شاشة العميل بيشوفها فيها **مستطيل ملوّن بلا سياق**، وعشان يعرف
/// هو في صفحة مين لازم عينه تنزل تحته.
///
/// دلوقتي الاسم والتصنيف والمنطقة قاعدين على اللوح فوق السكريم. ده الشكل
/// اللي أي فاترينة بتمشي عليه: الصورة والهوية حاجة واحدة، والتفاصيل تحت.
/// والجسم بقى بيبدأ بالمعلومات مباشرة بدل ما يكرر الاسم.
///
/// ## تلات حاجات كانت مكسورة قبل كده
///
/// **١. الصورة كانت بتتقص.** `expandedHeight: 200.h` جوه `AspectRatio(16/9)`
/// — والارتفاع الطبيعي لـ 16:9 على عرض ٣٧٥ هو **٢١٠٫٩**.
///
/// **٢. مكانش فيه سكريم.** الاسم بلون الحبر على الصورة مباشرة بيختفي على
/// أي لوح غامق.
///
/// **٣. زرار الرجوع كان أيقونة سايبة** على الصورة.
class ServiceProviderDetailsHeaderWidget extends StatelessWidget {
  /// **٢٦٠ مش ٢٣٢** — الهوية نزلت جوه الهيدر، فمحتاج مساحة تحتها.
  static const double expandedHeight = 260;

  final String name;
  final String imageUrl;
  final String categoryName;
  final String areaName;

  const ServiceProviderDetailsHeaderWidget({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.categoryName,
    required this.areaName,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // الهيدر بيتجمّع فيفضل اسم المحل ظاهر مهما نزلت — القديم كان الاسم
      // بيروح خالص فالعميل مش عارف هو في صفحة مين وهو بيقرا.
      pinned: true,
      expandedHeight: expandedHeight.r,
      // `surfaceTint` مقتول عالميًا في الثيم، فمفيش مسحة خضرا وقت التجميع.
      backgroundColor: AppSemanticColors.page,
      leadingWidth: 56.w,
      leading: const _CircularBackButton(),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      flexibleSpace: FlexibleSpaceBar(
        // `parallax` بيحرّك اللوح أبطأ من السكرول — بيدي عمق من غير أي كود
        // حركة، وده اللي بيخلي الهيدر يحس إنه صورة مش خلفية.
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            EntityPanelWidget(name: name),
            const _Scrim(),
            _identity(),
          ],
        ),
      ),
    );
  }

  /// الاسم والتصنيف على الحافة السفلية.
  ///
  /// اللون `textOnInk` مش `textPrimary`: ده نص على سكريم غامق، والحبر عليه
  /// بيختفي. و`FlexibleSpaceBar` بيبهّت الخلفية وهي بتتجمّع، فالكتلة دي
  /// بتروح لوحدها وبيفضل عنوان الـ AppBar — مفيش نصين فوق بعض.
  Widget _identity() {
    return PositionedDirectional(
      start: AppSpacing.pageGutter.w,
      end: AppSpacing.pageGutter.w,
      bottom: AppSpacing.s20.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLg.copyWith(
              color: AppSemanticColors.textOnInk,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            '$categoryName · $areaName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppSemanticColors.textOnInkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// تدرّج من فوق ومن تحت.
///
/// من فوق عشان زرار الرجوع، ومن تحت عشان كتلة الهوية. **التحتاني اتقّل**
/// من `scrimSoft` لـ `scrim`: قبل كده مكانش فيه نص تحت، دلوقتي فيه عنوان
/// لازم يقرا فوق أي لوح.
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppSemanticColors.scrimSoft,
            Colors.transparent,
            AppSemanticColors.scrimSoft,
            AppSemanticColors.scrim,
          ],
          stops: const [0, 0.30, 0.62, 1],
        ),
      ),
    );
  }
}

class _CircularBackButton extends StatelessWidget {
  const _CircularBackButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 36.r,
        width: 36.r,
        decoration: BoxDecoration(
          color: AppSemanticColors.surfaceRaised,
          shape: BoxShape.circle,
          boxShadow: AppShadows.raised,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          // الحد الأدنى للمس بيتحقق من مساحة الـ IconButton نفسها (٤٤)،
          // مش من الدايرة المرسومة — الدايرة ٣٦ عشان تبان أنيقة بس.
          constraints: BoxConstraints.tight(
            Size.square(AppSpacing.touchTarget.r),
          ),
          // بيتقلب تلقائيًا في الـ RTL — مفيش قلب يدوي.
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 20.r,
            color: AppSemanticColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
