import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/widgets/entity_panel_widget.dart';

/// هيدر صفحة المحل.
///
/// ## تلات حاجات كانت مكسورة
///
/// **١. الصورة كانت بتتقص.** `expandedHeight: 200.h` جوه `AspectRatio(16/9)`
/// — والارتفاع الطبيعي لـ 16:9 على عرض ٣٧٥ هو **٢١٠٫٩**. الفرق ١١ بكسل كان
/// بيتاكل من فوق ومن تحت. دلوقتي الصورة بتملا الهيدر بـ `BoxFit.cover`
/// والارتفاع ٢٣٢ — **مفيش نسبة مفروضة تتخانق مع الأب**.
///
/// **٢. مكانش فيه سكريم.** اسم المحل بلون الحبر `#0D0D12` كان بيترسم على
/// الصورة مباشرة — على صورة غامقة بيختفي تمامًا. التدرّج من فوق ومن تحت
/// بيضمن إن العنوان وزرار الرجوع مقروءين فوق **أي** صورة.
///
/// **٣. زرار الرجوع كان أيقونة سايبة** على الصورة. بقى دايرة بيضا بظل —
/// دي الحاجة الوحيدة في الصفحة اللي لازم تفضل باينة مهما كانت الصورة.
class ServiceProviderDetailsHeaderWidget extends StatelessWidget {
  static const double expandedHeight = 232;

  final String name;
  final String imageUrl;

  const ServiceProviderDetailsHeaderWidget({
    super.key,
    required this.name,
    required this.imageUrl,
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            EntityPanelWidget(name: name),
            const _Scrim(),
          ],
        ),
      ),
    );
  }
}

/// تدرّج من فوق ومن تحت.
///
/// من فوق عشان زرار الرجوع، ومن تحت عشان الاسم اللي بيظهر وقت التجميع.
/// الوسط شفاف تمامًا — الصورة هي البطل، السكريم بيخدمها مش بيغطيها.
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
            Colors.transparent,
            AppSemanticColors.scrimSoft,
          ],
          stops: const [0, 0.28, 0.62, 1],
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
          // الحد الأدنى للمس بيتحقق من مساحة الـ IconButton نفسها (٤٨)،
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
