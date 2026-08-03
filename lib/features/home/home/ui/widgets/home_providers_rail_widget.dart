import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/entity_panel_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// صف أفقي للمحلات — `ListView.builder` مكان الـ ١٣١٩ سطر القديمة.
class HomeProvidersRailWidget extends StatelessWidget {
  /// مقاسات الكارت — **مصدر واحد يقراه الـ skeleton كمان.**
  static const double cardWidth = 168;

  /// ارتفاع الصورة جوه الكارت. ١٤٤ عرض متاح (١٦٨ − ٢٤ حشوة) على 16:9
  /// بيدّي ٨١ — قرّبناها لـ ٨٤ عشان الاقتصاص يبقى أقل حدة.
  static const double _imageHeight = 84;

  /// ٢٤ حشوة + ٨٤ صورة + ٨ + ٤ مسافات.
  static const double _fixedPart = 120;

  /// سطرين اسم (١٤×١٫٥٠×٢) + المنطقة + البيانات، عند مقياس ١٫٠.
  static const double _textPart = 72.8;

  /// كان ٢٠٨ ثابت والمحتوى ١٩٢٫٨ — ١٥ بكسل فراغ ميت تحت كل كارت.
  /// وزي كل رقم ثابت، كان هيفيض مع تكبير الخط — فبقى محسوب.
  static double cardHeight(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: _fixedPart,
    text: _textPart,
  );

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
            return SkeletonBoxWidget(
              width: cardWidth,
              height: height,
              radius: AppRadius.l,
            );
          }
          final provider = providers[index];
          return _CompactProviderCard(
            provider: provider,
            imageHeight: _imageHeight,
            onTap: () => onProviderTap(provider),
          );
        },
      ),
    );
  }
}

class _CompactProviderCard extends StatelessWidget {
  final ProviderUiModel provider;
  final double imageHeight;
  final VoidCallback onTap;

  const _CompactProviderCard({
    required this.provider,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      width: HomeProvidersRailWidget.cardWidth.w,
      padding: EdgeInsets.all(AppSpacing.cardPadding.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // `isWide` بقى معناه «املا الأب» — فالأب لازم يحدد ارتفاع.
          // قبل كده كان `AspectRatio` جوه الـ widget نفسه، وده اللي كان
          // بيخلي الصورة **تتقص** لما الأب يفرض ارتفاع مختلف.
          SizedBox(
            height: imageHeight.r,
            width: double.infinity,
            child: EntityPanelWidget(name: provider.name),
          ),
          verticalSpace(AppSpacing.s8),
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
          const Spacer(),
          Text(
            '${AppFormat.distance(provider.distanceKm)} · من ${AppFormat.money(provider.priceFrom)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionInk,
          ),
        ],
      ),
    );
  }
}
