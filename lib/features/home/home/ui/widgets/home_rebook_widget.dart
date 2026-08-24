import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// **«زي المرة اللي فاتت؟»** — كارت درجة أولى في الهوم.
///
/// ## ليه ده أعلى رافعة إيراد في الخطة
///
/// عند الكوافير والباربر، «نفس اللي فات» هو **السلوك الغالب** مش حالة
/// خاصة: نفس القصة ونفس الشخص كل ٣–٥ أسابيع. ومكانش ليه أي سطح:
/// العميل لازم يفتح تبويب «السابقة»، يلاقي الحجز، يدخل جواه، ويدوس زرار
/// كان بيرجّعه للقايمة تاني.
///
/// **ومحتاجش أي داتا جديدة.** آخر حجز مكتمل + نفس الخدمة + نفس الأخصائي
/// — كلهم موجودين خلاص.
///
/// ## ليه سطح مرفوع مش لوح حبر
///
/// اللوح الغامق محجوز لبؤرة واحدة في الشاشة (حالة الفرع). ده اقتراح مش
/// حدث بيحصل دلوقتي — بياخد وزن كارت، مش وزن بؤرة. لو الاتنين اتغمقوا،
/// مافيش حاجة فيهم بتبقى البؤرة.
class HomeRebookWidget extends StatelessWidget {
  final BookingUiModel booking;
  final VoidCallback onTap;

  const HomeRebookWidget({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      radius: AppRadius.m,
      padding: EdgeInsets.all(AppSpacing.cardPadding.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ١ · العرض الأول ────────────────────────────────────────
          //
          // **السؤال فوق، مش تحت.** كان «زي المرة اللي فاتت؟» سطر صغير
          // تحت اسم الخدمة — يعني العرض نفسه كان تابع للبيانات. والكارت
          // ده مش صف بيانات، هو **اقتراح**: السؤال هو المحتوى، والخدمة
          // هي التفصيلة اللي بتخليه مقنع.
          Row(
            children: [
              Icon(
                Icons.replay_rounded,
                size: 16.r,
                color: AppSemanticColors.accentText,
              ),
              horizontalSpace(AppSpacing.s4),
              Expanded(
                child: Text(
                  'زي المرة اللي فاتت؟',
                  style: AppTextStyles.overline.copyWith(
                    color: AppSemanticColors.accentText,
                  ),
                ),
              ),
              Text(_lastTimeLabel, style: AppTextStyles.overline),
            ],
          ),
          verticalSpace(AppSpacing.s8),

          // ── ٢ · الخدمات بأسمائها ───────────────────────────────────
          //
          // **مش «و٢ غيرها».** الملخص ده مكتوب لصف في قايمة، ومكانه
          // هناك. هنا العميل بيتسأل «تعمل نفس اللي فات؟» — والرد بيعتمد
          // على إنه يشوف **إيه** بالظبط. «قص شعر · حلاقة ذقن · غسيل
          // وتصفيف» بتخلي الرد أيوة؛ «قص شعر و٢ غيرها» بتخليه «إيه دول؟».
          Text(
            _servicesLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${booking.providerName} · ${booking.branchName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),

          verticalSpace(AppSpacing.s12),
          const AppHairlineWidget(),
          verticalSpace(AppSpacing.s8),

          // ── ٣ · مين وكام، وبعدين الفعل ─────────────────────────────
          Row(
            children: [
              // الصورة بتبان **لما تعني حاجة بس** — يعني أخصائي واحد
              // للحجز كله. في حجز بتلات أخصائيين، أول حرف من أول واحد
              // فيهم معلومة عشوائية بتاخد ٤٤ بكسل.
              if (_singleEmployee != null) ...[
                EntityAvatarWidget(
                  name: _singleEmployee!,
                  size: 28,
                  shape: AvatarShape.person,
                ),
                horizontalSpace(AppSpacing.s8),
              ],
              Expanded(
                child: Text(
                  _withLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
              Text(
                AppFormat.money(booking.price),
                style: AppTextStyles.bodyMdStrong,
              ),
              horizontalSpace(AppSpacing.s8),
              DirectionalChevronWidget(
                size: 18,
                color: AppSemanticColors.accentText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// كل الخدمات بأسمائها، وبتتقفل عند ٣ عشان السطر مايبقاش فقرة.
  String get _servicesLabel {
    final names = booking.items.map((i) => i.serviceName).toList();
    if (names.length <= 3) return names.join(' · ');
    final extra = names.length - 3;
    return '${names.take(3).join(' · ')} +${AppFormat.digits(extra)}';
  }

  /// اسم الأخصائي لو هو نفسه في كل الخدمات — وإلا `null`.
  String? get _singleEmployee {
    final names = booking.items.map((i) => i.employeeName).toSet();
    return names.length == 1 ? names.first : null;
  }

  String get _withLabel {
    final single = _singleEmployee;
    if (single != null) return 'مع $single';
    return booking.employeeName;
  }

  /// **«آخر مرة من ١٢ يوم» — ده المُطلِق.**
  ///
  /// «زي المرة اللي فاتت؟» من غير «إمتى» بتسأل سؤال ناقص. الحلاقة ليها
  /// إيقاع (٣–٥ أسابيع)، والرقم ده هو اللي بيخلي العميل يقول «آه بقالي
  /// كتير فعلاً» بدل ما يفكّر.
  String get _lastTimeLabel {
    final days = DateTime.now().difference(booking.endAt).inDays;
    if (days <= 0) return 'آخر مرة النهاردة';
    if (days == 1) return 'آخر مرة إمبارح';
    if (days < 7) return 'آخر مرة من ${AppFormat.digits(days)} أيام';
    if (days < 14) return 'آخر مرة من أسبوع';
    if (days < 30) {
      return 'آخر مرة من ${AppFormat.digits(days ~/ 7)} أسابيع';
    }
    final months = days ~/ 30;
    return months == 1
        ? 'آخر مرة من شهر'
        : 'آخر مرة من ${AppFormat.digits(months)} شهور';
  }
}
