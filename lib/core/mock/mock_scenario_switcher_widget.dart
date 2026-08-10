import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/demo_mode.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/my_app.dart';

/// MOCK — مبدّل السيناريوهات. **بيختفي بالكامل في الـ release.**
///
/// بيلف الأبلكيشن كله ويحط شارة صغيرة تحت الشمال. الضغط عليها بيفتح
/// قايمة السيناريوهات، وكل واحد مكتوب جنبه **السؤال اللي بيجاوبه في
/// جلسة الاختبار** — لأن سيناريو مالوش سؤال يبقى مالوش لزمة.
///
/// اختيار سيناريو بيعيد بناء الشجرة كلها (عن طريق [ValueKey] فوق الـ
/// Navigator) عشان كل الـ cubits تتعمل من جديد بالداتا الجديدة. ده
/// بيدي نفس أثر الـ hot restart من غير ما نلمس الكود.
class MockScenarioSwitcherWidget extends StatelessWidget {
  final Widget child;

  const MockScenarioSwitcherWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // مفيش شارة ولا إعادة بناء ولا حتى listener لما الوضع مقفول.
    //
    // كان `kDebugMode` — وده كان بيمنع المبدّل عن الحالة اللي هو معمول
    // عشانها بالظبط: نسخة release مثبّتة على موبايل قدام ناس بتجرّب.
    if (!kDebugMode && !kDemoMode) return child;

    return ValueListenableBuilder<MockScenario>(
      valueListenable: MockConfig.scenarioListenable,
      builder: (context, scenario, _) => Stack(
        children: [
          // **مفيش `KeyedSubtree` هنا — كانت مالهاش أي أثر.**
          //
          // الفكرة كانت إن تغيير المفتاح بيرمي الشجرة ويعيد بناء الـ
          // cubits. بس `MaterialApp` عندها `navigatorKey`، و**الـ widget
          // اللي ليه GlobalKey بيتنقل element بتاعه مش بيتعاد إنشاؤه** —
          // فالـ Navigator وكل اللي تحته كانوا بيعيشوا بحالتهم كاملة.
          //
          // النتيجة: الشارة بتتغيّر والداتا لأ. إعادة التشغيل الحقيقية
          // بقت في [_restart] تحت.
          child,
          // **فوق الشمال، مش تحت.**
          //
          // تحت كانت بتقع فوق الفوتر المثبّت وتغطي «٤٥ دقيقة» جنب السعر
          // — يعني أداة العرض بتخفي المحتوى اللي جاية تعرضه. فوق الشمال
          // المنطقة الوحيدة اللي مفيهاش لا رأس ولا فوتر ولا زرار رجوع.
          PositionedDirectional(
            end: AppSpacing.s8.w,
            top: AppSpacing.s8.h,
            child: _Badge(scenario: scenario),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final MockScenario scenario;

  const _Badge({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill.r),
          onTap: () => _open(context),
          child: Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s8.w,
              vertical: AppSpacing.s4.h,
            ),
            decoration: BoxDecoration(
              color: AppSemanticColors.textPrimary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.pill.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 14.r,
                  color: AppSemanticColors.textOnAccent,
                ),
                horizontalSpace(AppSpacing.s4),
                Text(
                  scenario.title,
                  style: AppTextStyles.overline.copyWith(
                    color: AppSemanticColors.textOnAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **إعادة تشغيل حقيقية — بترمي كل الشاشات والـ cubits اللي جواها.**
  ///
  /// `pushNamedAndRemoveUntil` بيمسح كل الـ routes ويبني القشرة من جديد،
  /// فكل cubit بيتعمل من الأول ويقرا الـ fixtures بالسيناريو الجديد.
  ///
  /// المحاولة اللي قبل دي كانت بتغيّر مفتاح فوق الـ Navigator — ومكانتش
  /// بتعمل حاجة، لأن الـ Navigator ليه `GlobalKey` فبيتنقل بحالته بدل
  /// ما يتعاد إنشاؤه. الشارة كانت بتتغيّر والشاشة تفضل زي ما هي.
  ///
  /// والرجوع للرئيسية مقصود ومكتوب في الشيت («بيعيد تشغيل الشاشات») —
  /// السيناريو بيغيّر الداتا تحت رجل العميل، فالبقاء في نص فلو مبني على
  /// داتا قديمة أسوأ من البداية من جديد.
  void _restart() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.buttonNavigationBarScreen,
      (_) => false,
    );
  }

  void _open(BuildContext context) {
    // **الـ context بتاع الـ Navigator، مش بتاع الشارة.**
    //
    // الشارة عايشة في `MaterialApp.builder` — يعني **فوق** الـ Navigator
    // في الشجرة. `showModalBottomSheet` بالـ context ده كان بيرمي
    // «Navigator operation requested with a context that does not include
    // a Navigator»، فالمبدّل كله كان ميت.
    //
    // `navigatorKey` معرّف في `my_app.dart` وبيتحط على الـ `MaterialApp`،
    // فالـ context بتاعه تحت الـ Navigator وتحت `MaterialLocalizations`.
    final navigatorContext = navigatorKey.currentContext;
    if (navigatorContext == null) return;

    showModalBottomSheet<void>(
      context: navigatorContext,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('سيناريو العرض', style: AppTextStyles.sectionHeader),
              verticalSpace(AppSpacing.s4),
              Text(
                'الاختيار بيعيد تشغيل الشاشات بالداتا الجديدة',
                style: AppTextStyles.caption,
              ),
              verticalSpace(AppSpacing.s16),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: MockScenario.values.length,
                  itemBuilder: (_, index) {
                    final item = MockScenario.values[index];
                    final isCurrent = item == scenario;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.title,
                        style: isCurrent
                            ? AppTextStyles.cardTitle.copyWith(
                                color: AppSemanticColors.accent,
                              )
                            : AppTextStyles.cardTitle,
                      ),
                      // السؤال مش وصف — هو سبب وجود السيناريو.
                      subtitle: Text(
                        item.question,
                        style: AppTextStyles.caption,
                      ),
                      trailing: isCurrent
                          ? Icon(
                              Icons.check_rounded,
                              color: AppSemanticColors.accent,
                            )
                          : null,
                      onTap: () {
                        MockConfig.scenario = item;
                        Navigator.of(sheetContext).pop();
                        _restart();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
