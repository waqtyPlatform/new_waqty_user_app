import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/entity_panel_widget.dart';

/// صف أفقي للمحلات.
///
/// ## اللوح بقى واصل لحافة الكارت
///
/// كان اللوح **مُدرَج جوه حشوة الكارت** — يعني إطار أبيض ٤ جهات حواليه.
/// الشكل ده بيقرا «صورة متحطّة في خانة»، والـ design DNA بيقول
/// `content-forward with image thumbnails`: الصورة هي أول حاجة العين
/// بتمسكها، ومالهاش إطار.
///
/// دلوقتي الكارت حشوته **صفر** واللوح بياخد العرض كله لحد الحافة، والنص
/// بس هو اللي متحشّي. `AppSurfaceWidget` بيقص بالاستدارة، فأركان اللوح
/// العلوية بتتدوّر مع الكارت لوحدها.
///
/// ## الشارة فوق اللوح
///
/// «أقرب موعد» كان سطر أخضر مدفون تحت البيانات. هو **أهم معلومة في الكارت**
/// (ده أبلكيشن حجز)، فطلع شارة فوق اللوح — أول حاجة تتقرا بعد الحرف.
/// وبيختفي بالكامل لو مفيش موعد قريب، مش بيرسم شارة فاضية.
class HomeProvidersRailWidget extends StatelessWidget {
  /// عرض الكارت. **١٧٦ مش ١٦٨** — اللوح بقى كامل العرض فمحتاج مساحة تسنده.
  static const double cardWidth = 176;

  /// ارتفاع لوح الحرف جوه الكارت.
  static const double imageHeight = 96;

  /// حشوة كتلة النص (مش الكارت — الكارت حشوته صفر).
  static const double textPadding = AppSpacing.s12;

  /// اللوح + حشوة النص فوق وتحت + المسافتين جوه العمود.
  static const double _fixedPart =
      imageHeight +
      (textPadding * 2) +
      AppSpacing.titleToSubtitle +
      AppSpacing.subtitleToMeta;

  /// سطرين اسم (`bodyMdStrong` ١٤×١٫٥٠×٢ = ٤٢) + المنطقة (١٦٫٨) +
  /// البيانات (١٦٫٨). المجموع الحسابي ٧٥٫٦، والرقم هنا **٧٦** لأن فلاتر
  /// بيقرّب ارتفاع السطر لأعلى وقت التشكيل.
  static const double _textPart = 76;

  /// كان ٢٠٨ رقم ثابت — يعني بيفيض مع تكبير الخط بدل ما يكبر معاه.
  static double cardHeight(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  final List<ProviderUiModel> providers;
  final bool isLoading;
  final ValueChanged<ProviderUiModel> onProviderTap;

  const HomeProvidersRailWidget({
    super.key,
    required this.providers,
    required this.onProviderTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = cardHeight(context);

    return SizedBox(
      height: height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.pageGutter.w,
        ),
        itemCount: isLoading ? 3 : providers.length,
        separatorBuilder: (_, __) => horizontalSpace(AppSpacing.listRowGap),
        itemBuilder: (context, index) {
          if (isLoading) {
            return AppSkeletonBoxWidget(
              width: cardWidth,
              height: height,
              radius: AppRadius.m,
            );
          }
          final provider = providers[index];
          return _CompactProviderCard(
            provider: provider,
            onTap: () => onProviderTap(provider),
          );
        },
      ),
    );
  }
}

class _CompactProviderCard extends StatelessWidget {
  final ProviderUiModel provider;
  final VoidCallback onTap;

  const _CompactProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      width: HomeProvidersRailWidget.cardWidth.w,
      // **صفر.** الحشوة نزلت لكتلة النص عشان اللوح يوصل الحافة.
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panel(),
          Padding(
            padding: EdgeInsetsDirectional.all(
              HomeProvidersRailWidget.textPadding.r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
                verticalSpace(AppSpacing.titleToSubtitle),
                Text(
                  provider.areaName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
                verticalSpace(AppSpacing.subtitleToMeta),
                Text(
                  '${AppFormat.distance(provider.distanceKm)} · من ${AppFormat.money(provider.priceFrom)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionInk,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// اللوح + الشارة اللي فوقه.
  ///
  /// الشارة في الركن السفلي: فوق اللوح فبتقرا كطبقة عليه، وقريبة من النص
  /// فبتقرا كأنها أول سطر فيه.
  Widget _panel() {
    final hasSlot = provider.nextAvailableLabel.isNotEmpty;

    return SizedBox(
      height: HomeProvidersRailWidget.imageHeight.r,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          EntityPanelWidget(name: provider.name),
          if (hasSlot)
            PositionedDirectional(
              start: AppSpacing.s8.w,
              bottom: AppSpacing.s8.h,
              child: AppPillWidget(
                label: provider.nextAvailableLabel,
                icon: Icons.schedule_rounded,
                tone: AppPillTone.onImage,
                // العرض المتاح ناقص الهامشين — الميعاد الطويل بيتقص مش بيفيض.
                maxWidth: HomeProvidersRailWidget.cardWidth - AppSpacing.s16,
              ),
            ),
        ],
      ),
    );
  }
}
