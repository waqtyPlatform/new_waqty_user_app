import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// شريط التواريخ الأفقي.
///
/// **مش `showDatePicker`** — الـ picker بتاع النظام مش بيعرف يقول «اليوم ده
/// مليان»، وبيفتح dialog فوق sheet، وشكله بيتخانق مع تصميم الأبلكيشن.
///
/// **الأيام المليانة بتفضل ظاهرة، مش بتتشال.** الفراغ نفسه بيعلّم العميل
/// إيقاع المحل (مقفول الجمعة مثلاً). لو شلناها الشريط بيكدب ويقول إن
/// كل الأيام متاحة.
///
/// ## «مقفول» غير «مليان» — والفرق بيغيّر الرد
///
/// الاتنين كانوا شخطة رمادية واحدة، ومعناهم عكس بعض:
///
///  • **مقفول** حقيقة عن المحل. بتقفل الكلام — مفيش حاجة تتعمل.
///  • **مليان** طلب قابل قدامه عرض فاضي. ده **أحسن مدخل لقائمة الانتظار
///    في المنتج كله**، وكان متعرض كطريق مسدود.
///
/// فاليوم المليان بقى قابل للضغط وبيودّي لقائمة الانتظار، والمقفول لأ.
class CreateBookingDateStripWidget extends StatelessWidget {
  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final DateTime currentMonth;
  final bool canGoToPreviousMonth;

  /// مدة الخدمة — عشان حالة اليوم تتحسب صح. يوم فيه فرجة ساعة «مليان»
  /// لخدمة ساعتين ومفتوح لخدمة نص ساعة.
  final int durationMinutes;

  final ValueChanged<DateTime> onDateTap;
  final ValueChanged<int> onMonthChange;

  /// الضغط على يوم **مليان** — بيودّي لقائمة الانتظار.
  final VoidCallback? onFullDayTap;

  const CreateBookingDateStripWidget({
    super.key,
    required this.availableDates,
    required this.selectedDate,
    required this.currentMonth,
    required this.canGoToPreviousMonth,
    required this.onDateTap,
    required this.onMonthChange,
    this.durationMinutes = 45,
    this.onFullDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = _daysOfMonth();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // `Expanded` مش نص سايب: «سبتمبر ٢٠٢٦» مع سهمين ٤٤ لكل واحد
            // بيضيّقوا السطر عند مقياس خط عالي.
            Expanded(
              child: Text(
                AppFormat.monthYear(currentMonth),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMdStrong,
              ),
            ),
            _ArrowButton(
              // «الشهر اللي فات» = عكس اتجاه القراءة
              direction: ChevronDirection.back,
              // مانرجعش لشهر فات — مواعيده عدّت أصلاً
              onTap: canGoToPreviousMonth ? () => onMonthChange(-1) : null,
            ),
            horizontalSpace(4),
            _ArrowButton(
              direction: ChevronDirection.forward,
              onTap: () => onMonthChange(1),
            ),
          ],
        ),
        verticalSpace(AppSpacing.headerToContent),
        SizedBox(
          // كان ٧٢ والمحتوى بياخد ٤٦٫٨ — **٣٥٪ من الخلية فاضية**.
          height: 64.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => horizontalSpace(AppSpacing.chipGap),
            itemBuilder: (context, index) {
              final day = days[index];
              final status = MockSlots.dayStatus(
                day,
                durationMinutes: durationMinutes,
              );
              final isSelected =
                  selectedDate != null && _isSame(selectedDate!, day);
              return _DayCell(
                day: day,
                status: status,
                isSelected: isSelected,
                isToday: _isSame(day, DateTime.now()),
                onTap: status.isBookable
                    ? () => onDateTap(day)
                    : status.offersWaitlist
                    ? onFullDayTap
                    : null,
              );
            },
          ),
        ),
        // **مفتاح الشكل — سطر واحد بيشرح الفرق مرة.**
        //
        // من غيره العميل لازم يستنتج إن الحد الأخضر معناه «اضغط»
        // والشخطة معناها «خلاص». الاستنتاج ده بيتعلّم بالتجربة والخطأ،
        // والتجربة والخطأ في شاشة حجز غالية.
        verticalSpace(AppSpacing.s8),
        // `_LegendDot` جوه `Expanded` — النص طويل ومالوش سقف، وعند مقياس
        // خط ١٫٣ كان **بيفيض ١٤٣ بكسل** على حافة الشاشة.
        Row(
          children: [
            Expanded(
              child: _LegendDot(
                color: AppSemanticColors.accent,
                label: 'مليان — ينفع تدخل قائمة الانتظار',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// أيام الشهر من النهاردة لقدام — مش من أول الشهر.
  List<DateTime> _daysOfMonth() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );

    final result = <DateTime>[];
    for (var i = 1; i <= daysInMonth; i++) {
      final day = DateTime(currentMonth.year, currentMonth.month, i);
      if (day.isBefore(today)) continue;
      result.add(day);
    }
    return result;
  }

  bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 8.r,
          width: 8.r,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(AppRadius.pill.r),
          ),
        ),
        horizontalSpace(AppSpacing.s4),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.overline,
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final ChevronDirection direction;
  final VoidCallback? onTap;

  const _ArrowButton({required this.direction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.touchTarget.r,
      width: AppSpacing.touchTarget.r,
      child: IconButton(
        onPressed: onTap,
        icon: DirectionalChevronWidget(
          direction: direction,
          size: 24,
          color: onTap == null
              ? AppSemanticColors.borderStrong
              : AppSemanticColors.textPrimary,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final DayAvailability status;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isSelected,
    required this.isToday,
    this.onTap,
  });

  bool get isAvailable => status.isBookable;

  @override
  Widget build(BuildContext context) {
    // اليوم المليان: رمادي غامق كفاية يتقرا + شخطة مايلة — عشان الحالة
    // تبان حتى لو الشاشة أبيض وأسود أو العميل عنده عمى ألوان.
    final textColor = isSelected
        ? AppSemanticColors.textOnAccent
        : isAvailable
        ? AppSemanticColors.textPrimary
        : AppSemanticColors.textSecondary;

    return AppSurfaceWidget(
      onTap: onTap,
      // المتاح **مرفوع** والمقفول **غاطس** — الفرق في العمق مش في حد
      // رمادي تباينه ٧٪ تقريبًا مش باين على 3x.
      level: isAvailable || isSelected
          ? AppElevation.raised
          : AppElevation.sunken,
      color: isSelected ? AppSemanticColors.accent : null,
      // **اليوم المليان ليه حد أخضر — هو قابل للضغط.**
      //
      // ده الفرق الشكلي بين «مقفول» (مشخوط، ميت) و«مليان» (محدود،
      // بيودّي لقائمة الانتظار). من غيره الاتنين شكلهم واحد ومعناهم
      // عكس بعض.
      border: status == DayAvailability.fullyBooked
          ? Border.all(color: AppSemanticColors.accent)
          : null,
      radius: AppRadius.m,
      width: 56.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // النص بيتحرّك مع الخلفية — من غير كده اللون بينطّ
              // والصندوق بيتلاشى، فالحركة بتحس نص خلصانة.
              AnimatedDefaultTextStyle(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                style: AppTextStyles.caption.copyWith(color: textColor),
                child: Text(AppFormat.shortDayName(day)),
              ),
              verticalSpace(AppSpacing.s4),
              AnimatedDefaultTextStyle(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                style: AppTextStyles.cardTitle.copyWith(color: textColor),
                child: Text(AppFormat.digits(day.day)),
              ),
            ],
          ),
          // الشخطة للمقفول واللي عدّى بس — المليان مش ميت، هو مليان.
          if (status == DayAvailability.closed ||
              status == DayAvailability.passed)
            Positioned.fill(child: CustomPaint(painter: _StrikePainter())),
          if (isToday)
            PositionedDirectional(
              bottom: AppSpacing.s8.h,
              child: Container(
                height: 2.h,
                width: 16.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppSemanticColors.textOnAccent
                      : AppSemanticColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// شخطة مايلة على اليوم المليان.
class _StrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppSemanticColors.borderStrong
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(size.width * .22, size.height * .76),
      Offset(size.width * .78, size.height * .24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
