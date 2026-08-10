import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_gradients.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_hairline_widget.dart';

/// فوتر ملزوق تحت الشاشة.
///
/// ⚠ **الظل بيطلع لفوق** ([AppShadows.floatingUp]) — الفوتر بيغطي
/// محتوى، فالظل لازم يقع على اللي بيتغطى مش على اللي تحته.
///
/// وبياخد `SafeArea` من تحت بس: لو أخد الأربع جهات، بيزوّد حشوة جانبية
/// على أجهزة الشق وبيبوّظ الهامش.
class AppFooterWidget extends StatelessWidget {
  const AppFooterWidget({
    required this.child,
    this.showBorder = true,
    super.key,
  });

  final Widget child;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceRaised,
        boxShadow: AppShadows.floatingUp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBorder) const AppHairlineWidget(),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.pageGutter.w,
                end: AppSpacing.pageGutter.w,
                top: AppSpacing.s12.h,
                bottom: AppSpacing.s12.h,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر في [AppBottomNavWidget]. **نصوص جاهزة — مش مفاتيح.**
@immutable
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;

  /// عدد صغير جنب الأيقونة.
  final String? badge;
}

/// شريط تنقّل سفلي.
///
/// ## ⚠ ليه الكيت بيشحن ده رغم إن نسخة employee-app اتشالت
///
/// `custom_bottom_nav_bar.dart` هناك حاطط **قايمة التبويبات جوّه** كـ
/// `static const`، وبيقرا `ImageAsset.homeIcon` وأخواتها، وبيعرف راوتات
/// التطبيق. اللي اتشال هو **القايمة**، مش الشريط.
///
/// هنا العناصر بتيجي من بره والكولباك بيرجّع الفهرس — فالشريط مايعرفش
/// حاجة عن التطبيق.
class AppBottomNavWidget extends StatelessWidget {
  const AppBottomNavWidget({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceRaised,
        boxShadow: AppShadows.floatingUp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppHairlineWidget(),
          SafeArea(
            top: false,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavTab(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected
        ? AppSemanticColors.accentText
        : AppSemanticColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minHeight: (AppSpacing.touchTarget + 8).r),
        padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 22.r,
                  color: ink,
                ),
                if (item.badge != null)
                  PositionedDirectional(
                    top: -4.h,
                    end: -8.w,
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 4.w),
                      constraints: BoxConstraints(minWidth: 14.r),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppSemanticColors.danger,
                        borderRadius: AppRadius.rPill,
                      ),
                      child: Text(
                        item.badge!,
                        style: AppTextStyles.overline.copyWith(
                          color: AppSemanticColors.textOnDanger,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              style: AppTextStyles.overline.copyWith(color: ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// فاصل بلابل في النص — «أو».
class AppLabeledDividerWidget extends StatelessWidget {
  const AppLabeledDividerWidget({required this.label, super.key});

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: AppHairlineWidget()),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12.w,
          ),
          child: Text(label, style: AppTextStyles.caption),
        ),
        const Expanded(child: AppHairlineWidget()),
      ],
    );
  }
}

/// ظهور متدرّج — تلاشي + ارتفاع ١٢ نقطة.
///
/// ⚠ **بيحترم `MediaQuery.disableAnimations`.** الحركة اللي مابتحترمش
/// الإعداد ده مش تحسين، هي عائق لناس بتتعب من الحركة.
class AppRevealWidget extends StatefulWidget {
  const AppRevealWidget({
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 60),
    super.key,
  });

  final Widget child;

  /// ترتيب العنصر — بيأخّر ظهوره [stagger] × [index].
  final int index;

  final Duration stagger;

  @override
  State<AppRevealWidget> createState() => _AppRevealWidgetState();
}

class _AppRevealWidgetState extends State<AppRevealWidget> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.stagger * widget.index, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedSlide(
      duration: AppMotion.entrance,
      curve: AppMotion.standard,
      offset: _shown ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: AppMotion.entrance,
        curve: AppMotion.standard,
        opacity: _shown ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

/// غلاف الشاشة — **بيحط قرارات التخطيط في مكان واحد**.
///
/// بيمسك: خلفية الصفحة، الوهج العلوي، الهيدر، الفوتر الملزوق، وحد
/// مقياس الخط. الشاشة اللي جواه مابتفكّرش في أي واحدة منهم.
class AppScreenScaffold extends StatelessWidget {
  const AppScreenScaffold({
    required this.body,
    this.header,
    this.footer,
    this.bottomNav,
    this.showGlow = true,
    this.banner,
    super.key,
  });

  final Widget body;
  final Widget? header;
  final Widget? footer;
  final Widget? bottomNav;
  final Widget? banner;

  /// وهج خفيف أعلى الصفحة.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: showGlow ? AppGradients.pageGlow : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ?banner,
              if (header != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: AppSpacing.pageGutter.w,
                    end: AppSpacing.pageGutter.w,
                    top: AppSpacing.s8.h,
                  ),
                  child: header!,
                ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNav,
      persistentFooterAlignment: AlignmentDirectional.center,
      floatingActionButton: null,
      bottomSheet: footer,
    );
  }
}
