import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/app_pill_widget.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// تفاصيل الحجز — **تلات مجموعات**: فين · إيه وإمتى · بكام.
///
/// ## عمود اللابلات اتشال
///
/// كان جدول من عمودين: لابل بعرض ٨٤ ثابت («الفرع» · «العنوان» · «الخدمة»
/// · «الأخصائي» · «التاريخ» · «الوقت») وقيمته جنبه. سبع صفوف، كل واحد
/// بيقول حاجتين — نص اللي بيتعرض كان **أسماء الحقول مش الحجز**.
///
/// دلوقتي المحتوى بيعرّف نفسه: اسم الفرع تحته عنوانه، اسم الخدمة تحته «مع
/// فلان»، والتاريخ والوقت والمدة **شارات**. نفس المعلومة في ٤ كتل بدل ٧
/// صفوف، والعين بتمسحها مرة واحدة بدل ما تلف يمين وشمال مع كل سطر.
///
/// اللابل فضل في مكانين بس — الملاحظات وسبب الإلغاء — لأن دول نص حر
/// مايعرّفش نفسه.
///
/// ## رقم الحجز نزل تحت
///
/// كان **أول سطر في الكارت**. وهو أقل حاجة تهم العميل: ده رقم للريسيبشن،
/// بيتقري مرة واحدة عند الباب. أهم حاجة في الشاشة هي «إمتى وفين»، فدي
/// اللي فوق دلوقتي.
///
/// ## ليه خطين بس
///
/// الخط بيفصل **نوع السؤال**: فين · إيه وإمتى · بكام. تلاتة أسئلة، فخطين.
/// و[AppHairlineWidget] مش `Divider`: الشعرة بكسل فيزيائي واحد (الـ
/// `Divider` بيرسم ١ منطقي، وده بيتلوّن على بكسلين على شاشة 3x).
///
/// ## الحجز المتعدد
///
/// الحجز ممكن يبقى فيه لحد ٥٠ خدمة على لحد ٢٠ زيارة. لما يكون فيه أكتر من
/// خدمة، المجموعة التانية بتتحوّل لتفصيل بالزيارة.
class BookingDetailsInfoWidget extends StatelessWidget {
  final BookingUiModel booking;

  const BookingDetailsInfoWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ١ · فين ──────────────────────────────────────────────────
          _place(),

          if (booking.notes.isNotEmpty) ...[
            verticalSpace(AppSpacing.s12),
            _labelled('ملاحظاتك', booking.notes),
          ],
          if (booking.cancellationReason.isNotEmpty) ...[
            verticalSpace(AppSpacing.s12),
            _labelled('سبب الإلغاء', booking.cancellationReason),
          ],

          _groupBreak(),

          // ── ٢ · إيه وإمتى ────────────────────────────────────────────
          if (booking.isMultiService)
            ..._visitBreakdown()
          else
            ..._singleService(),

          _groupBreak(),

          // ── ٣ · بكام ─────────────────────────────────────────────────
          // السعر هو السطر الوحيد هنا اللي بياخد حجم كبير. باقي الكارت
          // كله ١٤، فالـ ٢٠ دي كفاية إنها تبان من غير لون ولا خلفية.
          // **`Expanded` على اللابل مش `Spacer` بينهم.**
          //
          // مع `Spacer` التلات عناصر بياخدوا مقاسهم الطبيعي، وعند مقياس خط
          // ١٫٣ «الإجمالي» + السعر المشطوب + السعر **بيفيضوا ٦٤ بكسل** —
          // يعني السعر بيتقص من الشاشة. باللابل `Expanded` هو اللي بيتضغط
          // الأول، والسعر عمره ما يتلمس.
          Row(
            children: [
              Expanded(
                child: Text(
                  'الإجمالي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdMuted,
                ),
              ),
              horizontalSpace(AppSpacing.s8),
              // **«كان ٢٥٠ · بقى ٢٠٠».**
              //
              // خصم مجموعة العميل بيتحسب وبيتخزّن في السيرفر
              // (`CustomerGroupPricingService`) بس **مش مكشوف في أي
              // resource** — فالعميل كان بيشوف رقم أقل من اللي في القايمة
              // من غير أي تفسير، والرقم من غير سبب بيتقري «غلطة».
              if (booking.hasDiscount) ...[
                Text(
                  AppFormat.money(booking.originalPrice!),
                  style: AppTextStyles.captionStruck,
                ),
                horizontalSpace(AppSpacing.s8),
              ],
              Text(
                AppFormat.money(booking.price),
                style: AppTextStyles.titleLg,
              ),
            ],
          ),
          verticalSpace(AppSpacing.s4),
          Row(
            children: [
              // «الدفع في الفرع» مش «غير مدفوع» — التانية بتتقري كأنها
              // مديونية على العميل وهي مش كده.
              Expanded(
                child: Text(
                  booking.paymentStatus.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
              horizontalSpace(AppSpacing.s8),
              // رقم الحجز. نص لاتيني جوه واجهة عربي — من غير الاتجاه ده
              // ترتيبه بيتقلب على الشاشة، والعميل يقرا للموظف حاجة تانية.
              Text(
                '#${booking.reference}',
                maxLines: 1,
                style: AppTextStyles.caption,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// الفرع وعنوانه — كتلة واحدة بأيقونة، مش صفّين بلابلات.
  Widget _place() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 20.r,
          color: AppSemanticColors.textTertiary,
        ),
        horizontalSpace(AppSpacing.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.branchName, style: AppTextStyles.bodyMdStrong),
              if (booking.branchAddress.isNotEmpty) ...[
                verticalSpace(AppSpacing.s4),
                Text(booking.branchAddress, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// خدمة واحدة — الاسم، مع مين، وشارات الميعاد.
  List<Widget> _singleService() {
    final item = booking.items.first;

    return <Widget>[
      Text(item.serviceName, style: AppTextStyles.bodyMdStrong),
      verticalSpace(AppSpacing.s4),
      Text('مع ${item.employeeName}', style: AppTextStyles.caption),
      verticalSpace(AppSpacing.s8),
      // **التاريخ والوقت والمدة شارات مش صفوف.**
      //
      // التلاتة دول هما اللي العميل فاتح الشاشة عشانهم. كصفوف في جدول
      // كانوا بياخدوا ٣ سطور ونصهم أسماء حقول؛ كشارات في سطر واحد بيتقروا
      // في نظرة، و`Wrap` بينزّلهم سطر تاني لوحده لما الخط يكبر.
      Wrap(
        spacing: AppSpacing.chipGap.w,
        runSpacing: AppSpacing.chipGap.h,
        children: [
          AppPillWidget(
            label: AppFormat.fullDate(item.startAt),
            icon: Icons.calendar_today_rounded,
          ),
          AppPillWidget(
            label: AppFormat.timeRange(item.startAt, item.endAt),
            icon: Icons.schedule_rounded,
          ),
          AppPillWidget(
            label: AppFormat.duration(item.durationMinutes),
            icon: Icons.hourglass_bottom_rounded,
          ),
          if (item.rating != null) _ratingPill(item),
        ],
      ),
    ];
  }

  /// أكتر من خدمة — تفصيل بالزيارة.
  List<Widget> _visitBreakdown() {
    final visits = booking.visits;

    return <Widget>[
      for (var i = 0; i < visits.length; i++) ...<Widget>[
        if (i > 0) verticalSpace(AppSpacing.s16),
        Row(
          children: [
            if (visits.length > 1) ...[
              Text(_visitTitle(i), style: AppTextStyles.sectionLabel),
              horizontalSpace(AppSpacing.s8),
            ],
            Expanded(
              child: Text(
                AppFormat.fullDate(visits[i].startAt),
                style: AppTextStyles.bodyMdStrong,
              ),
            ),
          ],
        ),
        verticalSpace(AppSpacing.headerToContent),
        ...visits[i].items.map(_itemLine),
      ],
    ];
  }

  Widget _itemLine(BookingItemUiModel item) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.serviceName, style: AppTextStyles.bodyMd),
                verticalSpace(AppSpacing.titleToSubtitle),
                Text(
                  '${AppFormat.timeRange(item.startAt, item.endAt)}'
                  ' · مع ${item.employeeName}',
                  style: AppTextStyles.caption,
                ),
                // **حالة التقييم لكل خدمة لوحدها.**
                //
                // التقييم بيتعمل `active: false` في السيرفر وبيفضل مخفي
                // لحد المراجعة. من غير السطر ده، العميل بيقيّم وبيشوف لا
                // شيء ويستنتج إنه ما اتسجّلش، فيقيّم تاني.
                if (item.rating != null) ...[
                  verticalSpace(AppSpacing.titleToSubtitle),
                  _ratingPill(item),
                ],
                // **كلام العميل بيرجع له.**
                //
                // مش جوه الشارة عن قصد — تعليق من سطرين مايدخلش في pill،
                // والشارة معمولة للنجوم والحالة.
                //
                // سطرين وقص: ده صف في كارت مش شاشة تقييم، والمقصود إنه
                // يشوف كلامه وصل مش يقراه من الأول.
                if (item.ratingComment.isNotEmpty) ...[
                  verticalSpace(AppSpacing.titleToSubtitle),
                  Text(
                    item.ratingComment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          horizontalSpace(AppSpacing.s8),
          Text(AppFormat.money(item.price), style: AppTextStyles.bodyMdStrong),
        ],
      ),
    );
  }

  /// تقييم الخدمة — والحالة معاه لو لسه تحت المراجعة.
  Widget _ratingPill(BookingItemUiModel item) => AppPillWidget(
    label: item.ratingStatus == RatingStatus.pending
        ? '${AppFormat.digits(item.rating!)} · ${item.ratingStatus.label}'
        : AppFormat.digits(item.rating!),
    icon: Icons.star_rounded,
    tone: item.ratingStatus == RatingStatus.pending
        ? AppPillTone.warning
        : AppPillTone.neutral,
  );

  String _visitTitle(int index) {
    const ordinals = <String>[
      'الزيارة الأولى',
      'الزيارة التانية',
      'الزيارة التالتة',
      'الزيارة الرابعة',
      'الزيارة الخامسة',
    ];
    if (index < ordinals.length) return ordinals[index];
    return 'الزيارة ${AppFormat.digits(index + 1)}';
  }

  /// فاصل مجموعة. ١٢ فوق و١٢ تحت — متساوية عن قصد، عشان الخط يقرا كأنه
  /// بين المجموعتين مش تابع لواحدة فيهم.
  Widget _groupBreak() => Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s12.h),
    // من غير إزاحة: ده فاصل أقسام مش فاصل صفوف.
    child: const AppHairlineWidget(),
  );

  /// لابل + قيمة — **للنص الحر بس** (الملاحظات وسبب الإلغاء).
  ///
  /// اللابل فوق مش جنب: النص الحر بيتلف أسطر، وعمود ثابت جنبه بيضيّق
  /// المساحة اللي هو محتاجها أصلاً.
  Widget _labelled(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.sectionLabel),
      verticalSpace(AppSpacing.s4),
      Text(value, style: AppTextStyles.bodyMd),
    ],
  );
}
