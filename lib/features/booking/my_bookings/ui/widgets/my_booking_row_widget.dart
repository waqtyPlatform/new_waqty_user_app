import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_row_widget.dart';
import 'package:waqty_user_application/core/widgets/booking_status_chip_widget.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_chip_widget.dart';

/// الحجز **كصف في قايمة** — كان كارت أبيض مرفوع.
///
/// ## ليه بطّل كارت
///
/// نفس السبب اللي شال الكارت من لستة الأماكن: عشر كروت بيضا ورا بعض معناها
/// عشر ظلال وعشر حدود، وكل واحد فيهم بيقول «أنا جسم منفصل» — ولما الكل
/// بيقولها، محدش بيقولها. الصف قاعد على `page` مباشرة ومفصول بخط شعري،
/// فالعين بتنزل على عمود واحد.
///
/// ## من غير لوح حرف
///
/// `ProviderRowWidget` بياخد لوح ٥٦ لأن ده صف **تعريف**: العميل بيدوّر وسط
/// أماكن مش عارفها ومحتاج علامة يقفل عليها. الصف ده مختلف — العميل عارف
/// المحل خلاص، اللي بيدوّر عليه هو **الوقت والحالة**. لوح ملوّن على كل صف
/// هنا كان هيزاحم الشارات على نفس الانتباه من غير ما يضيف معلومة.
///
/// ## شارة حالة الفرع
///
/// [InBranchChipWidget] بتاخد لقطة **مرة واحدة** من [MockInBranch] وقت
/// الـ build. الصف **عمره ما يفتح `InBranchCubit`** — عشرين صف يبقى
/// عشرين تايمر شغّال في الخلفية عشان تقدير بيتغيّر كل ٢٠ ثانية. اللي بيـ poll
/// هو الهيرو في الهوم وبلوك التفاصيل بس، وهما واحد في الشاشة.
class MyBookingRowWidget extends StatelessWidget {
  /// **الحسبة:** ١٢ حشوة فوق + ١٢ تحت (من [AppRowWidget]) = ٢٤، زائد
  /// المسافات جوه عمود النص: ٤ (`titleToSubtitle`) + ٨ (`subtitleToMeta`)
  /// = ١٢. **المجموع ٣٦.**
  ///
  /// كان ٤٠ في الكارت لأن المسافة قبل صف البيانات كانت `s12` مكتوبة بإيدها.
  /// بقت `subtitleToMeta` — نفس الدور في كل الصفوف بنفس الرقم.
  static const double _fixedPart = 36;

  /// **الحسبة عند مقياس خط ١٫٠:**
  /// `cardTitle` ١٦×١٫٤٠ = ٢٢٫٤ · `caption` ١٢×١٫٤٠ = ١٦٫٨ ·
  /// `bodyMdStrong` ١٤×١٫٥٠ = ٢١. **المجموع ٦٠٫٢.**
  ///
  /// السطر الأول بيتحسب بالعنوان مش بالشارة: الشارة `overline` ١١×١٫٣٠ =
  /// ١٤٫٣ زائد ٨ حشوة رأسية = **٢٢٫٣** — أقصر من العنوان بعُشر بكسل،
  /// فالعنوان هو اللي بيحدد الارتفاع دايمًا. وأيقونات البيانات ١٦ وصفها
  /// نصه ٢١، فهي كمان مابتحددش حاجة.
  static const double _textPart = 60.2;

  /// المصدر الوحيد للارتفاع — **و`MyBookingRowSkeletonWidget` بيقراه من هنا**.
  static double heightOf(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: _fixedPart,
    text: _textPart,
  );

  final BookingUiModel booking;
  final VoidCallback onTap;

  /// آخر صف في القايمة بياخد `false` — الخط تحت الأخير بيرسم حد لقايمة
  /// مالهاش حد.
  final bool showHairline;

  const MyBookingRowWidget({
    super.key,
    required this.booking,
    required this.onTap,
    this.showHairline = true,
  });

  @override
  Widget build(BuildContext context) {
    final inBranch = _inBranch;

    return AppRowWidget(
      onTap: onTap,
      height: heightOf(context).h,
      showHairline: showHairline,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
              ),
              horizontalSpace(AppSpacing.s8),
              // **شارة الفرع قبل شارة الحالة.** الحالة («مؤكد») ثابتة من
              // ساعة الحجز، والتقدير هو اللي بيتغيّر دلوقتي — فبيقعد أقرب
              // للاسم عشان يتقرا الأول.
              //
              // الشرط هنا **مش تكرار** لشرط الـ widget: الشارة بتخفي نفسها
              // بس المسافة اللي قبلها لأ، فمن غيره كان هيبان ٨ بكسل فاضيين
              // في كل صف مالوش حالة فرع.
              if (inBranch != null) ...[
                InBranchChipWidget(data: inBranch),
                horizontalSpace(AppSpacing.chipGap),
              ],
              BookingStatusChipWidget(status: booking.status),
            ],
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${booking.serviceName} · ${booking.branchName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),

          // **التقييم المستني بيقول عن نفسه في الصف.**
          //
          // صف الحجز المكتمل كان ساكت تمامًا عن التقييم، فصف عليه تلات
          // خدمات محدش قيّمها بيبان **زي** صف اتقيّم بالكامل بالحرف.
          // العميل مالوش سبب يدوس، والتقييم اللي الأبلكيشن كله متبني
          // عليه (`booking_item_id` بـunique constraint) بيموت في مكانه.
          //
          // العدد مقصود مش «قيّم دلوقتي»: **التقييم لكل خدمة** — ودي
          // بالظبط الحاجة اللي سيناريو «مكتمل · من غير تقييم» بيسأل عنها
          // («فاهمين إن التقييم لكل خدمة؟»). رقم في الصف بيجاوب السؤال
          // قبل ما العميل يفتح أصلاً.
          if (booking.hasPendingRatings) ...[
            verticalSpace(AppSpacing.titleToSubtitle),
            Text(
              booking.rateableItems.length == 1
                  ? 'قيّم الخدمة'
                  : 'قيّم ${AppFormat.digits(booking.rateableItems.length)} خدمات',
              style: AppTextStyles.captionAccent,
            ),
          ],
          verticalSpace(AppSpacing.subtitleToMeta),
          Row(
            children: [
              _MetaIcon(icon: Icons.calendar_today_rounded),
              horizontalSpace(AppSpacing.s4),
              Text(
                AppFormat.relativeDate(booking.startAt),
                style: AppTextStyles.captionInk,
              ),
              horizontalSpace(AppSpacing.s12),
              _MetaIcon(icon: Icons.access_time_rounded),
              horizontalSpace(AppSpacing.s4),
              Text(
                AppFormat.time(booking.startAt),
                style: AppTextStyles.captionInk,
              ),
              const Spacer(),
              // **الخصم بيبان من القايمة مش من التفاصيل بس.**
              //
              // الصف كان بيعرض «1125 ج.م» ساكت. الرقم ده صح، بس ساكت —
              // مفيش حاجة تقول إن ده أقل من العادي، فالخصم كان بيتكشف
              // بعد ضغطة على صفحة التفاصيل.
              //
              // وده بيضيّع الخصم في المكان الوحيد اللي بيهم فيه: العميل
              // بيمرّ على القايمة، مابيفتحش كل حجز. سعر مشطوب جنب السعر
              // الجديد بيقول القصة في نص ثانية من غير لابل ولا لون صارخ.
              if (booking.hasDiscount) ...[
                Text(
                  AppFormat.money(booking.originalPrice!),
                  style: AppTextStyles.captionStruck,
                ),
                horizontalSpace(AppSpacing.s4),
              ],
              Text(
                AppFormat.money(booking.price),
                style: AppTextStyles.bodyMdStrong,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// حالة الفرع اللي تستاهل شارة — أو `null`.
  ///
  /// **الحالة هي اللي بتقرر، مش التاريخ.** الكود القديم كان بيسأل
  /// `MockQueue` «الحجز ده النهاردة؟» وبس، فحجز النهاردة الساعة ١٠ وخلص
  /// كان بياخد «٣ قدامك» الساعة ٤. دلوقتي `isInBranch` بتيجي من
  /// `booking.status` اللي الفرع نفسه بيحرّكه.
  InBranchUiModel? get _inBranch =>
      MockInBranch.forBooking(booking, DateTime.now());
}

/// أيقونة بيانات صغيرة — رمادية دايمًا، حجم موحّد.
///
/// كان فيه ١١ حجم أيقونة لـ ٢٤ أيقونة في الأبلكيشن. الأحجام بقت ٤ بس:
/// **١٦ للبيانات · ٢٠ للأفعال · ٢٤ للتنقّل · ٣٢ للحالات الفاضية.**
class _MetaIcon extends StatelessWidget {
  final IconData icon;

  const _MetaIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 16.r, color: AppSemanticColors.textTertiary);
  }
}
