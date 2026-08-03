import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// تبويبين: القادمة · السابقة.
///
/// ## الحبّة بتزحلق، مش بتنطّ
///
/// القديم كان بيبدّل لون خلفية التبويبين — يعني الحبّة البيضا كانت
/// **بتختفي من هنا وتظهر هناك**. القفزة دي بتقطع الإحساس إن ده نفس العنصر
/// اتحرّك.
///
/// دلوقتي حبّة واحدة في `AnimatedAlign` **ورا** اللابلات، فبتمشي من مكان
/// لمكان. اللابلات فوقها بتغيّر ستايلها بالتوازي بـ `AnimatedDefaultTextStyle`.
///
/// **مفيش `ValueKey` على أي حاجة متحركة هنا** — الشاشة بتعمل rebuild من
/// الـ `BlocBuilder` مع كل emit، والـ Element بيتعاد استخدامه فالحركة
/// بتشتغل. المفتاح كان هيعمل Element جديد **ويقتل الحركة**.
class MyBookingsTabsWidget extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  static const List<String> _labels = ['القادمة', 'السابقة'];

  const MyBookingsTabsWidget({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(AppSpacing.s4.r),
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      child: Stack(
        children: [
          // الحبّة المتحركة — تحت اللابلات في ترتيب الـ Stack.
          AnimatedAlign(
            duration: AppMotion.base,
            curve: AppMotion.standard,
            // `-1` بداية · `1` نهاية. في الـ RTL الاتجاه بيتقلب لوحده
            // لأن `Alignment` بيتحوّل حسب `Directionality`.
            alignment: selectedTab == 0
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 1 / _labels.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppSemanticColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                  boxShadow: AppShadows.raised,
                ),
              ),
            ),
          ),
          Row(
            children: List<Widget>.generate(
              _labels.length,
              (index) => Expanded(
                child: _Tab(
                  label: _labels[index],
                  isSelected: selectedTab == index,
                  onTap: () => onTabChanged(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.base,
            curve: AppMotion.standard,
            style: isSelected
                ? AppTextStyles.bodyMdStrong
                : AppTextStyles.bodyMdMuted,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
