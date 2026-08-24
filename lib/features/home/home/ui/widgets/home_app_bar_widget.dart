import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// التحية + المدينة.
///
/// التحية من غير اسم بالقصد. الشاشة القديمة كانت بتقول «اهلا احمد» لكل
/// الناس — بما فيهم الستات. والعربي بيفرّق في التحية بين المذكر والمؤنث،
/// فلحد ما الأسماء والنوع ييجوا من السيرفر، تحية محايدة أأمن وأصح.
///
/// ## جرس الإشعارات اتشال
///
/// كان `onNotificationsTap: () {}` — زرار بيرد بلا شيء. مفيش شاشة إشعارات
/// ولا route ليها، ومفيش transport في المنظومة كلها: التوكنات بتتخزن في
/// `app_device_tokens` ومحدش بيقراها، ومفيش package ولا listener. فالجرس
/// كان بيوعد بحاجة مش موجودة — وأول حاجة أي حد بيجرّب الأبلكيشن بيدوس
/// عليها، فبتضيع الجلسة في تفسير سكوت.
///
/// يرجع لما يبقى فيه إشعارات فعلاً.
class HomeAppBarWidget extends StatelessWidget {
  final String cityName;

  const HomeAppBarWidget({super.key, required this.cityName});

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
      ],
    );
  }
}
