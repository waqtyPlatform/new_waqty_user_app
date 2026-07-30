import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// تفاصيل الحجز — **تلات مجموعات**، مش تسع سطور ورا بعض.
///
/// ## ليه خطين بس
///
/// أسهل حاجة إن كل سطر ياخد فاصل تحته. وده بيحوّل الكارت لجدول: تسع
/// خطوط رمادية بتقول «كل سطر منفصل عن اللي فوقه» — وهي مش منفصلة، دي
/// كلها معلومة واحدة عن حجز واحد.
///
/// الخط هنا بيفصل **نوع السؤال**: فين ومين · إيه وإمتى · بكام. تلاتة
/// أسئلة، فخطين.
///
/// و[AppHairlineWidget] مش `Divider` لسببين: الشعرة **بكسل فيزيائي واحد**
/// (الـ `Divider` بيرسم ١ منطقي، وده بيتلوّن على بكسلين على شاشة 3x)،
/// وارتفاعها هو سُمكها بالظبط فالمسافة حوليها قرار مكتوب هنا مش أثر جانبي.
///
/// ## الحجز المتعدد
///
/// الحجز ممكن يبقى فيه لحد ٥٠ خدمة على لحد ٢٠ زيارة. الشكل القديم كان
/// سطر «الخدمة» وسطر «الأخصائي» وسطر «التاريخ» — يعني حجز بتلات خدمات
/// كان بيتعرض كواحدة والعميل يروح المحل ويتفاجئ. لما يكون فيه أكتر من
/// خدمة، المجموعة التانية بتتحوّل لتفصيل بالزيارة.
class BookingDetailsInfoWidget extends StatelessWidget {
  final BookingUiModel booking;

  const BookingDetailsInfoWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      padding: AppSpacing.cardLoose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ١ · فين ومين ─────────────────────────────────────────────
          _row('رقم الحجز', booking.reference),
          _row('الفرع', booking.branchName),
          if (booking.branchAddress.isNotEmpty)
            _row('العنوان', booking.branchAddress),
          // الملاحظات وسبب الإلغاء تبع الحجز مش تبع الوقت ولا الفلوس —
          // فبيقعدوا في آخر المجموعة دي بدل ما ياخدوا مجموعة رابعة
          // بتظهر وتختفي وبتخلي الكارت بيتنفّس.
          if (booking.notes.isNotEmpty) _row('ملاحظاتك', booking.notes),
          if (booking.cancellationReason.isNotEmpty)
            _row('سبب الإلغاء', booking.cancellationReason),

          _groupBreak(),

          // ── ٢ · إيه وإمتى ────────────────────────────────────────────
          if (booking.isMultiService) ..._visitBreakdown() else ..._singleService(),

          _groupBreak(),

          // ── ٣ · بكام ─────────────────────────────────────────────────
          // السعر هو السطر الوحيد هنا اللي بياخد حجم كبير. باقي الكارت
          // كله ١٤، فالـ ٢٠ دي كفاية إنها تبان من غير لون ولا خلفية.
          Row(
            children: [
              Text('الإجمالي', style: AppTextStyles.bodyMdMuted),
              const Spacer(),
              Text(AppFormat.money(booking.price), style: AppTextStyles.titleLg),
            ],
          ),
          verticalSpace(AppSpacing.s4),
          Row(
            children: [
              const Spacer(),
              // «الدفع في الفرع» مش «غير مدفوع» — التانية بتتقري كأنها
              // مديونية على العميل وهي مش كده.
              Text(booking.paymentStatus.label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  /// خدمة واحدة — الشكل المسطّح زي ما كان.
  List<Widget> _singleService() {
    final item = booking.items.first;
    return <Widget>[
      _row('الخدمة', item.serviceName),
      _row('الأخصائي', item.employeeName),
      _row('التاريخ', AppFormat.fullDate(item.startAt)),
      _row(
        'الوقت',
        '${AppFormat.timeRange(item.startAt, item.endAt)}'
            ' · ${AppFormat.duration(item.durationMinutes)}',
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
                AppFormat.fullDate(visits[i].first.startAt),
                style: AppTextStyles.bodyMdStrong,
              ),
            ),
          ],
        ),
        verticalSpace(AppSpacing.headerToContent),
        ...visits[i].map(_itemLine),
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
              ],
            ),
          ),
          horizontalSpace(AppSpacing.s8),
          Text(AppFormat.money(item.price), style: AppTextStyles.bodyMdStrong),
        ],
      ),
    );
  }

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
    // من غير إزاحة: ده فاصل أقسام مش فاصل صفوف. الإزاحة تحت النص كانت
    // هتخلي الخطين التنين يقروا كأنهم بيفصلوا سطرين بعينهم.
    child: const AppHairlineWidget(),
  );

  Widget _row(String label, String value) => Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: (AppSpacing.s8 / 2).h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عمود ثابت للّابل عشان القيم كلها تبدأ من نفس الخط الرأسي —
        // من غيره العين بتلف مع كل سطر تدوّر على أول القيمة.
        SizedBox(
          width: 84.w,
          child: Text(label, style: AppTextStyles.bodyMdMuted),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodyMdStrong)),
      ],
    ),
  );
}
