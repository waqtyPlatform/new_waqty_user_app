import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
/// الخط هنا بيفصل **نوع السؤال**: إيه ومين وفين · إمتى · بكام. تلاتة
/// أسئلة، فخطين. والسطور اللي جوه المجموعة الواحدة بتتلزق ببعضها بمسافة
/// ٤ فوق و٤ تحت وبس — القرب هو اللي بيجمّعهم، مش برواز.
///
/// و[AppHairlineWidget] مش `Divider` لسببين: الشعرة **بكسل فيزيائي واحد**
/// (الـ `Divider` بيرسم ١ منطقي، وده بيتلوّن على بكسلين على شاشة 3x)،
/// وارتفاعها هو سُمكها بالظبط فالمسافة حوليها قرار مكتوب هنا مش أثر جانبي.
class BookingDetailsInfoWidget extends StatelessWidget {
  final BookingUiModel booking;

  const BookingDetailsInfoWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      padding: AppSpacing.cardLoose,
      child: Column(
        children: [
          // ── ١ · الحجز نفسه: إيه ومين وفين ────────────────────────────
          _row('رقم الحجز', booking.reference),
          _row('الخدمة', booking.serviceName),
          _row('الأخصائي', booking.employeeName),
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

          // ── ٢ · إمتى ─────────────────────────────────────────────────
          _row('التاريخ', AppFormat.fullDate(booking.startAt)),
          _row(
            'الوقت',
            '${AppFormat.timeRange(booking.startAt, booking.endAt)} · ${AppFormat.duration(booking.durationMinutes)}',
          ),

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
