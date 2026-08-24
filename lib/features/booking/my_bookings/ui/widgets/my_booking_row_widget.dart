import 'package:waqty_user_application/core/widgets/discount_price_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
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
  /// المسافات جوه عمود النص: ٤ (`titleToSubtitle`) + ٤ = **٣٢**.
  ///
  /// ⚠ **مشتق من التوكنز مش رقم مكتوب.** الرقم ده اتكتب ٣٦ أول ما الحشوة
  /// كانت ١٢، وبقى ٤٠ لما بقت ١٦ — ومع الكيت رجعت ١٢ تاني. تلات مرات
  /// نفس الرقم يتصلّح بالإيد كفاية: خلّيه يقرا من التوكن.
  ///
  /// والمسافة قبل صف البيانات نزلت من ٨ لـ ٤: التلات سطور دول بيانات الحجز
  /// نفسه، والفصل الحقيقي بين اسم المحل وبينهم.
  static const double _fixedPart =
      (AppSpacing.cardPadding * 2) + AppSpacing.titleToSubtitle + AppSpacing.s4;

  /// **الحسبة عند مقياس خط ١٫٠:**
  /// `cardTitle` ١٦×١٫٤٠ = ٢٢٫٤ · `caption` ١٢×١٫٤٠ = ١٦٫٨ · وسطر البيانات
  /// أطول حاجة فيه شارة الميعاد (١٤٫٣ + ٨ حشوة = ٢٢٫٣) أو السعر
  /// (`bodyMdStrong` ٢١) — بنحجز ٢٤٫٨. المجموع الحسابي **٦٤**، والرقم هنا ٦٨ — تلات سطور، وفلاتر بيقرّب كل واحد فيهم لأعلى
  /// لتقريب فلاتر لارتفاع السطر.
  ///
  /// الشارة `captionStrong` ١٢×١٫٤٠ =
  /// ١٦٫٨ زائد ٨ حشوة رأسية = **٢٤٫٨** — أطول من العنوان، فهي اللي
  /// بتحدد ارتفاع السطر التالت.
  static const double _textPart = 68;

  /// شارة «قيّم الخدمة» بتزوّد سطر — مسافة ٤ وحشوة الشارة ٨ ثابتين،
  /// ونصها (`captionStrong` = ١٢×١٫٤٠) بيكبر مع المقياس.
  static const double _ratingFixed = AppSpacing.s4 + AppSpacing.s8;
  static const double _ratingText = 16.8;

  /// المصدر الوحيد للارتفاع — **و`MyBookingRowSkeletonWidget` بيقراه من هنا**.
  ///
  /// ⚠ [hasRatingLine] **لازم يتبعت.** شارة التقييم كانت بتترسم من غير ما
  /// تتحسب خالص — يعني أي حجز مكتمل من غير تقييم كان صفه **بيفيض ٢٠ بكسل**.
  /// الـ skeleton بيسيبها `false` لأنه مابيعرفش إيه اللي جاي.
  static double heightOf(BuildContext context, {bool hasRatingLine = false}) =>
      AppSpacing.scaledHeight(
        context,
        fixed: _fixedPart + (hasRatingLine ? _ratingFixed : 0),
        text: _textPart + (hasRatingLine ? _ratingText : 0),
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
      height: heightOf(context, hasRatingLine: booking.hasPendingRatings).h,
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
            verticalSpace(AppSpacing.s4),
            // شارة مش نص أخضر — نفس لغة «أقرب موعد» في صف المحل: الحاجة
            // اللي عايزة فعل من العميل بتاخد حدود وخلفية عشان تتفرّق عن
            // الوصف اللي حواليها.
            AppPillWidget(
              label: booking.rateableItems.length == 1
                  ? 'قيّم الخدمة'
                  : 'قيّم ${AppFormat.digits(booking.rateableItems.length)} خدمات',
              icon: Icons.star_rounded,
              tone: AppPillTone.accent,
            ),
          ],
          verticalSpace(AppSpacing.s4),
          Row(
            children: [
              // **شارة واحدة بدل أربع عناصر.**
              //
              // كان: أيقونة + تاريخ + مسافة + أيقونة + وقت. الخمسة دول
              // بيتمدّوا مع مقياس الخط، وعند ١٫٣ الصف كان **بيفيض ١٠٣
              // بكسل عرضًا** — يعني السعر بيتقص من الشاشة في أهم صف.
              //
              // «النهاردة ٦:٠٠ م» نص واحد في شارة واحدة: أضيق، وبيقرا
              // كوحدة زمنية واحدة بدل حاجتين جنب بعض.
              Flexible(
                child: AppPillWidget(
                  label: AppFormat.relativeDateTime(booking.startAt),
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              horizontalSpace(AppSpacing.s8),
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
                DiscountPriceWidget(amount: booking.originalPrice!),
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

// `_MetaIcon` اتشال — التاريخ والوقت بقوا شارة واحدة، والأيقونة جوّاها.
