import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// التحية + المدينة + جرس الإشعارات.
///
/// التحية من غير اسم بالقصد. الشاشة القديمة كانت بتقول «اهلا احمد» لكل
/// الناس — بما فيهم الستات. والعربي بيفرّق في التحية بين المذكر والمؤنث،
/// فلحد ما الأسماء والنوع ييجوا من السيرفر، تحية محايدة أأمن وأصح.
class HomeAppBarWidget extends StatelessWidget {
  final String cityName;
  final VoidCallback onNotificationsTap;

  const HomeAppBarWidget({
    super.key,
    required this.cityName,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أهلاً بيك', style: AppTextStyles.bodyMdMuted),
              verticalSpace(2),
              Row(
                children: [
                  // رمادي مش أخضر — الدبوس ده بيقول «فين» مش «اضغط هنا»،
                  // والأخضر محجوز للأفعال والاختيار.
                  Icon(
                    Icons.location_on_rounded,
                    size: 16.r,
                    color: AppSemanticColors.textSecondary,
                  ),
                  horizontalSpace(4),
                  Text(cityName, style: AppTextStyles.cardTitle),
                ],
              ),
            ],
          ),
        ),
        // 44 نقطة حد أدنى — الأيقونة القديمة كانت 24 من غير padding
        SizedBox(
          height: 44.r,
          width: 44.r,
          child: IconButton(
            onPressed: onNotificationsTap,
            tooltip: 'الإشعارات',
            icon: Icon(
              Icons.notifications_none_rounded,
              size: 24.r,
              color: AppColors.greyColor900,
            ),
          ),
        ),
      ],
    );
  }
}
