import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

/// شاشة النجاح — **شاشة كاملة، مش toast**.
///
/// العميل لسه ارتبط بميعاد وبفلوس. الـ sheet بيقفل وتوست بيعدي في تانيتين
/// مش رد فعل مناسب للحظة دي.
///
/// وبنمسح الـ stack وراها — العميل مايرجعش لشاشة الحجز ويأكد تاني.
///
/// ## ليه `LayoutBuilder` مش `Column` عادي
///
/// كان `Column` فيه `Spacer` من غير أي scroll. الـ `Spacer` بياخد المساحة
/// الزيادة — وعلى شاشة قصيرة (أو مع مقياس خط ١٫٣) **مفيش مساحة زيادة أصلاً،
/// فالعمود بيفيض** والشريط الأصفر والأسود بيطلع.
///
/// الشكل ده بيدّي التوسيط لما فيه مكان، **والسكرول لما مافيش** — الاتنين
/// من غير ما نختار واحد فيهم على حساب التاني.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.s24.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.s24.r * 2),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SuccessMark(),
                      verticalSpace(AppSpacing.s24),
                      Text('تم الحجز', style: AppTextStyles.displayLg),
                      verticalSpace(AppSpacing.s8),
                      Text(
                        'بعتنا تفاصيل الحجز، وهتلاقيه في «الحجوزات»',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMdMuted,
                      ),
                      const Spacer(),
                      verticalSpace(AppSpacing.sectionBreak),
                      ButtonWidget(
                        isLoading: false,
                        buttonText: 'شوف حجوزاتي',
                        backGroundColor: AppSemanticColors.accent,
                        borderColor: AppSemanticColors.accent,
                        textStyle: AppTextStyles.button,
                        buttonHeight: 52.h,
                        onPressed: () => context.pushNamedAndRemoveUntil(
                          Routes.buttonNavigationBarScreen,
                          arguments: {'initialIndex': 2},
                          predicate: (_) => false,
                        ),
                      ),
                      verticalSpace(AppSpacing.s8),
                      // الحد الأدنى للمس جاي من `textButtonTheme`.
                      TextButton(
                        onPressed: () => context.pushNamedAndRemoveUntil(
                          Routes.buttonNavigationBarScreen,
                          predicate: (_) => false,
                        ),
                        child: Text(
                          'رجوع للرئيسية',
                          style: AppTextStyles.bodyMdStrong.copyWith(
                            color: AppSemanticColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// علامة الصح — بتكبر مرة واحدة عند الدخول.
///
/// `TweenAnimationBuilder` بيشغّل الحركة أول ما الـ widget يتبني، من غير
/// `StatefulWidget` ولا `AnimationController`. ومنحنى `emphasis` بيدّي
/// نطّة صغيرة في الآخر — اللحظة دي تستاهل احتفال بسيط.
class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.entrance,
      curve: AppMotion.emphasis,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        height: 96.r,
        width: 96.r,
        decoration: const BoxDecoration(
          color: AppSemanticColors.accentSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 48.r,
          color: AppSemanticColors.accent,
        ),
      ),
    );
  }
}
