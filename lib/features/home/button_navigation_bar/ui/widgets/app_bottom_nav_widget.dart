import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';

/// شريط التبويبات — **٤ تبويبات**.
///
/// ## الزرار الوسطاني اتشال (تاني)
///
/// الـ design DNA بيحط زرار مقص مرفوع في النص. جرّبناه فعلاً، والقرار
/// النهائي إنه يتشال:
///
/// الزرار ده في الـ kit الأصلي بيخدم تطبيق بيتعمل فيه **إنشاء** (زي زرار
/// النشر في السوشيال). في أبلكيشن حجز، العميل مابيعملش حاجة من الصفر —
/// هو بيختار محل وبيحجز منه. فالزرار كان لازم يفتح sheet يسأل «تحب تحجز
/// إزاي؟»، يعني **خطوة زيادة قبل نفس الشاشتين** اللي التبويبات بتوصّلهم
/// أصلاً: «كرّر آخر حجز» موجود ككارت في الرئيسية، و«احجز من محل جديد» هو
/// تبويب «استكشاف» بالحرف.
///
/// اللي فضل من الـ DNA هو اللي بيشتغل فعلاً: **الدايرة خلف أيقونة التبويب
/// المختار** — إشارة تانية جنب اللون، والاتنين مع بعض بيبانوا في الشمس
/// وعلى شاشة رخيصة.
class AppBottomNavWidget extends StatelessWidget {
  /// قطر الدايرة اللي ورا أيقونة التبويب المختار.
  static const double activePill = 34;

  final int currentIndex;
  final ValueChanged<int> onTabTap;

  const AppBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    // الجزء اللي فيه نص بيكبر مع مقياس الخط لوحده — الدايرة والحشوة مالهمش
    // دعوة بالمقياس، ومن غير ده الشريط بيفيض عند ١٫٣.
    final barHeight = AppSpacing.scaledHeight(
      context,
      fixed: activePill + AppSpacing.s4 + AppSpacing.s12,
      text: 11 * 1.30,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceRaised,
        boxShadow: AppShadows.floatingUp,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight.h,
          child: Row(
            children: List.generate(
              ButtonNavigationBarCubit.tabs.length,
              _tab,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final tab = ButtonNavigationBarCubit.tabs[index];
    final isSelected = currentIndex == index;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        child: InkResponse(
          onTap: () => onTabTap(index),
          radius: AppSpacing.touchTarget.r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // **الدايرة هي الحالة المختارة** (من الـ DNA). قبل كده كان
              // الفرق لون أيقونة بس — إشارة واحدة، وبتضيع على شاشة صغيرة
              // في الشمس.
              AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                height: activePill.r,
                width: activePill.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppSemanticColors.accentSoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  size: 22.r,
                  color: isSelected
                      ? AppSemanticColors.accent
                      // `textSecondary` مش أفتح: ده أصغر خط في الأبلكيشن،
                      // والرمادي اللي كان قبل كده تباينه ~٢٫٣ (راسب).
                      : AppSemanticColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.s4.h),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.overline.copyWith(
                  color: isSelected
                      ? AppSemanticColors.accent
                      : AppSemanticColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
