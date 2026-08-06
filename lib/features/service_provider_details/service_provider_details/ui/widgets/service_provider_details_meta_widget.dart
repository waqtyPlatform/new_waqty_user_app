import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/widgets/app_pill_widget.dart';

/// شريط شارات تحت هيدر المحل: **المسافة · عدد الخدمات · يبدأ من**.
///
/// ## ليه شارات مش سطر نص
///
/// التلات معلومات دي كانت مدموجة في سطر واحد بنقط فاصلة تحت الاسم
/// (`تصنيف · منطقة · ١٫٢ كم`). السطر ده بيقرا كوصف — العين بتعدّي عليه.
///
/// وهما مش وصف: دول **الحاجات اللي العميل بيقارن بيها** قبل ما يحجز. كل
/// واحدة في شارة ليها حدودها بتتقرا كحقيقة مستقلة، والتلاتة مع بعض بيقروا
/// كبطاقة مواصفات.
///
/// التصنيف والمنطقة اتنقلوا للهيدر فوق الصورة — دول هوية مش مواصفة.
class ServiceProviderDetailsMetaWidget extends StatelessWidget {
  final ProviderUiModel provider;

  const ServiceProviderDetailsMetaWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.chipGap.w,
      runSpacing: AppSpacing.chipGap.h,
      children: [
        AppPillWidget(
          label: AppFormat.distance(provider.distanceKm),
          icon: Icons.near_me_rounded,
        ),
        if (provider.servicesCount > 0)
          AppPillWidget(
            label: '${AppFormat.digits(provider.servicesCount)} خدمة',
            icon: Icons.list_alt_rounded,
          ),
        // السعر بلهجة اللمسة — هو الرقم اللي بيتقارن، والباقي سياق.
        AppPillWidget(
          label: 'يبدأ من ${AppFormat.money(provider.priceFrom)}',
          icon: Icons.sell_rounded,
          tone: AppPillTone.accent,
        ),
      ],
    );
  }
}
