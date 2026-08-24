import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

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

  /// خدمات **الفرع المختار** — الشارات بتتحسب منها مش من [provider].
  ///
  /// ⚠ `ProviderUiModel.servicesCount` و`priceFrom` **مستوى المحل**، مش
  /// مستوى الفرع. سيبناهم فترة بعد ما الأسعار بقت فرعية، فالشارة كانت
  /// بتقول «يبدأ من ٢٥٠» والصف تحتها بالحرف بيقول ٢٩٠ — تناقض في نفس
  /// الشاشة من غير سكرول.
  ///
  /// الشارتين دلوقتي بيتحسبوا، فمستحيل يفترقوا عن القايمة اللي تحتيهم.
  /// المسافة بتفضل من [provider] لأنها مسافة المحل مش الفرع.
  final List<ServiceUiModel> services;

  const ServiceProviderDetailsMetaWidget({
    super.key,
    required this.provider,
    required this.services,
  });

  /// أرخص خدمة حقيقية في الفرع — التصنيفات سعرها صفر فمابتتحسبش.
  double get _priceFrom {
    final priced = services
        .where((s) => !s.isCategory && s.price > 0)
        .map((s) => s.price);
    if (priced.isEmpty) return provider.priceFrom;
    return priced.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final count = services.isEmpty ? provider.servicesCount : services.length;

    return Wrap(
      spacing: AppSpacing.chipGap.w,
      runSpacing: AppSpacing.chipGap.h,
      children: [
        AppPillWidget(
          label: AppFormat.distance(provider.distanceKm),
          icon: Icons.near_me_rounded,
        ),
        if (count > 0)
          AppPillWidget(
            label: '${AppFormat.digits(count)} خدمة',
            icon: Icons.list_alt_rounded,
          ),
        // السعر بلهجة اللمسة — هو الرقم اللي بيتقارن، والباقي سياق.
        AppPillWidget(
          label: 'يبدأ من ${AppFormat.money(_priceFrom)}',
          icon: Icons.sell_rounded,
          tone: AppPillTone.accent,
        ),
      ],
    );
  }
}
