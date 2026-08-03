import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_row_widget.dart';
import 'package:waqty_user_application/core/widgets/entity_avatar_widget.dart';

/// المكان **كصف في قايمة** — نفس داتا `ProviderCardWidget` من غير الكارت.
///
/// ## ليه الكارت اتشال من اللستة
///
/// شاشة البحث كانت عشر كروت بيضا مرفوعة ورا بعض: عشر ظلال، عشر استدارات
/// ٢٠، وعشر حدود بتقول «أنا جسم منفصل». لما كل عنصر بيقول كده، مافيش عنصر
/// بيقوله. الكارت اتحجز للصف الأفقي اللي بيتسحب في الهوم — هناك هو فعلاً
/// جسم منفصل بيتحرّك لوحده.
///
/// الصف قاعد على `page` مباشرة ومفصول بخط شعري بيبدأ **من تحت النص** —
/// فالعين بتنزل على عمود واحد نضيف بدل ما تقفز بين حدود.
///
/// ## الصورة ٥٦ مش ٨٨
///
/// الكارت بياخد ٨٨ عشان الحرف فيه عنصر تصميم مستقل. في الصف اللي مالوش
/// حدود، اللوح الكبير بيبقى هو الحد — بيرسم عمود ملوّن جنب النص. ٥٦ بيخلي
/// اللوح علامة مش جدار.
class ProviderRowWidget extends StatelessWidget {
  /// مقاس لوح الحرف.
  static const double avatarSize = 56;

  /// إزاحة الخط الشعري: ١٦ هامش + ٥٦ لوح + ١٢ مسافة = **٨٤**.
  ///
  /// مصدّرة عشان أي حاجة تانية في نفس اللستة (فاصل قسم، صف «عرض المزيد»)
  /// تقدر تمشي على نفس الإزاحة بدل ما تعيد حساب الرقم بإيدها.
  static const double hairlineIndent =
      AppSpacing.pageGutter + avatarSize + AppSpacing.listRowGap;

  /// **الحسبة:** ١٢ حشوة فوق + ١٢ تحت (من [AppRowWidget]) = ٢٤،
  /// زائد المسافات جوه عمود النص: ٤ (`titleToSubtitle`) + ٨
  /// (`subtitleToMeta`) + ٤ (`s4` قبل «أقرب موعد») = ١٦. **المجموع ٤٠.**
  static const double _fixedPart = 40;

  /// **الحسبة عند مقياس خط ١٫٠:**
  /// `cardTitle` ١٦×١٫٤٠ = ٢٢٫٤ · `caption` ١٢×١٫٤٠ = ١٦٫٨ ·
  /// `captionInk` ١٢×١٫٤٠ = ١٦٫٨ · `captionAccent` ١٢×١٫٤٠ = ١٦٫٨.
  /// **المجموع ٧٢٫٨.**
  static const double _textPart = 72.8;

  /// المصدر الوحيد للارتفاع — **و`ProviderRowSkeletonWidget` بيقراه من هنا**.
  ///
  /// السطر الرابع («أقرب موعد») مساحته محجوزة حتى لو مش موجود. لو الارتفاع
  /// اتحسب على اللي ظاهر، اللستة كانت هترقص بين ٩٦ و١١٢ حسب كل صف —
  /// وده بالظبط الباج اللي كان في الكارت القديم.
  ///
  /// الإجمالي عند ١٫٠ = ١١٢٫٨، واللوح ٥٦ + ٢٤ حشوة = ٨٠ — يعني اللوح
  /// **عمره ما بيحدد الارتفاع**، فمفيش حاجة تانية محتاجة تتراعى هنا.
  static double heightOf(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: _fixedPart,
    text: _textPart,
  );

  final ProviderUiModel provider;
  final VoidCallback onTap;

  /// آخر صف في القايمة بياخد `false` — الخط الشعري تحت آخر عنصر بيرسم
  /// حد لقايمة مالهاش حد.
  final bool showHairline;

  const ProviderRowWidget({
    super.key,
    required this.provider,
    required this.onTap,
    this.showHairline = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppRowWidget(
      onTap: onTap,
      height: heightOf(context).h,
      showHairline: showHairline,
      hairlineIndent: hairlineIndent,
      leading: EntityAvatarWidget(
        name: provider.name,
        size: avatarSize,
        radius: AppRadius.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${provider.categoryName} · ${provider.areaName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          verticalSpace(AppSpacing.subtitleToMeta),
          Text(
            _metrics,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionInk,
          ),
          if (provider.nextAvailableLabel.isNotEmpty) ...[
            verticalSpace(AppSpacing.s4),
            Text(
              'أقرب موعد: ${provider.nextAvailableLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionAccent,
            ),
          ],
        ],
      ),
    );
  }

  String get _metrics => <String>[
    AppFormat.distance(provider.distanceKm),
    'من ${AppFormat.money(provider.priceFrom)}',
    '${AppFormat.digits(provider.servicesCount)} خدمة',
  ].join(' · ');
}
