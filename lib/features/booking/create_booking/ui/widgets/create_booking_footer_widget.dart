import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// الفوتر المثبّت — السعر والمدة على جنب، والزرار على الجنب التاني.
///
/// ده اللي بيخلي السعر ظاهر في كل خطوة. لو الحجز كان شاشات منفصلة
/// مكانش ينفع نعمل ده من غير تكرار.
class CreateBookingFooterWidget extends StatelessWidget {
  final double? price;

  /// السطر اللي تحت السعر — «٤٥ دقيقة» لخدمة واحدة، أو
  /// «٣ خدمات · ١ س ٣٠ د» للسلة.
  ///
  /// بيتحسب برّه بدل ما يبقى `durationMinutes` هنا: الفوتر مابيعرفش
  /// السلة فيها كام حاجة، والمكان الوحيد اللي بيعرف هو الـ cubit.
  final String? metaLabel;

  final String buttonLabel;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const CreateBookingFooterWidget({
    super.key,
    required this.buttonLabel,
    required this.isEnabled,
    required this.onPressed,
    this.price,
    this.metaLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppFooterWidget(
      child: Row(
        children: [
          if (price != null)
            // السعر بيتغيّر لما تختار ميعاد بفرق سعر — بيتزحلق من تحت
            // مع تلاشي بدل ما الرقم يتبدّل فجأة.
            AnimatedSwitcher(
              duration: AppMotion.base,
              switchInCurve: AppMotion.standard,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey('${price}_$metaLabel'),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppFormat.money(price!), style: AppTextStyles.cardTitle),
                  if (metaLabel != null)
                    Text(metaLabel!, style: AppTextStyles.caption),
                ],
              ),
            ),
          horizontalSpace(AppSpacing.listRowGap),
          Expanded(
            child: AppButtonWidget(
              label: buttonLabel,
              isLoading: isLoading,
              onPressed: isEnabled ? onPressed : null,
            ),
          ),
        ],
      ),
    );
  }
}
