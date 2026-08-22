import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **تذكرة بالباقات في صفحة المزوّد — من غير ما تدّعي إنها من هنا.**
///
/// ## ليه مافيش زرار حجز
///
/// السؤال «الباقة دي من الفرع ده؟» **مالوش إجابة في التطبيق**:
///
///  • رد `/entitlements/packages` مافيهوش `provider` ولا `branch` (BE-A1).
///  • المطابقة بالخدمة **مش صالحة**: `Service` عنده `providers()`
///    belongsToMany، يعني «قص شعر» صف واحد مشترك بين صالونات كتير —
///    فمطابقة `service_uuid` هتدّي إيجابيات كاذبة.
///
/// ولو عرضنا زرار حجز غلط، النتيجة مش رسالة خطأ — دي **حجز صامت في
/// المكان الغلط**: `bookSessionForUser` بياخد الفرع من الشراء نفسه
/// (`$purchase->branch_id`)، فالعميلة تختار ميعاد من تقويم الصالون اللي
/// قدامها والحجز يتعمل في صالون تاني.
///
/// فالتذكرة بتقول اللي إحنا **متأكدين منه** بس: عندها باقات شغّالة،
/// والفرع هو اللي بيستخدمها. والباقي رحلة لـ«باقاتي».
///
/// TODO(api): BE-A1 — أول ما `provider` و`branch` ينزلوا في الرد، ده
/// يبقى قسم «باقاتك هنا» بزرار حجز حقيقي، والفلترة تبقى بالمزوّد مش
/// تخمين.
class ProviderPackagesNoticeWidget extends StatelessWidget {
  const ProviderPackagesNoticeWidget({
    required this.activeCount,
    this.onTap,
    super.key,
  });

  /// عدد الباقات **الشغّالة** بس. المنتهية والمكتملة مالهاش لازمة هنا —
  /// تذكرة بحاجة خلصت مش تذكرة، دي ضوضاء.
  final int activeCount;

  final VoidCallback? onTap;

  /// جمع عربي بسيط للأعداد الصغيرة.
  String get _count {
    if (activeCount == 1) return 'باقة شغّالة';
    if (activeCount == 2) return 'باقتين شغّالين';
    if (activeCount <= 10) return '${AppFormat.digits(activeCount)} باقات شغّالة';
    return '${AppFormat.digits(activeCount)} باقة شغّالة';
  }

  @override
  Widget build(BuildContext context) {
    if (activeCount <= 0) return const SizedBox.shrink();

    return AppSurfaceWidget(
      level: AppElevation.raised,
      radius: AppRadius.m,
      padding: EdgeInsets.all(AppSpacing.cardPadding.r),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.card_giftcard_rounded,
            size: 20.r,
            color: AppSemanticColors.accentText,
          ),
          SizedBox(width: AppSpacing.s12.w),
          // النص هو اللي بيتنازل والسهم لأ — `Expanded` مش `Spacer` عشان
          // الصف مايفيضش عند مقياس خط ١٫٣.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'عندك $_count',
                  style: AppTextStyles.bodyMdStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.titleToSubtitle.h),
                Text(
                  // ⚠ **مابتقولش «باقاتك هنا»** — إحنا مش عارفين.
                  'لو واحدة منها من الفرع ده، كلّم الفرع عشان يستخدمها.',
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          const DirectionalChevronWidget(),
        ],
      ),
    );
  }
}
