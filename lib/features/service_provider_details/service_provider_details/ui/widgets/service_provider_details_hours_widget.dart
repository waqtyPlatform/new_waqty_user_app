import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// مواعيد العمل — [AppAccordionWidget] بسبع صفوف جواه.
///
/// ## الحالة انتقلت من الـ cubit للـ widget
///
/// `isWorkingHoursExpanded` + `toggleWorkingHours` +
/// `OnWorkingHoursToggledState` اتشالوا: تلات أعضاء شغلهم يفتحوا ويقفلوا
/// لوح. أكورديون الكيت شايل الحالة جواه، فكل ضغطة بقت تبني الأكورديون بس
/// بدل ما تبني الصفحة كلها (فيها قايمة خدمات وشبكة أخصائيين).
///
/// ## ⚠ نقطة الحالة الوحيدة
///
/// أكورديون الكيت `StatefulWidget`، فحالته بتتربط بمكانه في الشجرة. هنا
/// هو جوّه `SliverToBoxAdapter` ثابت مش جوه لستة كسولة، فالفتح بيفضل
/// بعد السكرول. لو اتنقل جوه `SliverList` يوم، الحالة هترجع تتقفل.
///
/// ## اللي اتشال كمان
///
/// **النقطة الملوّنة.** كانت دايرة ٦ بكسل خضرا/رمادية جنب اللابل. أكورديون
/// الكيت مالوش خانة أمامية، واللابل نفسه بيقول الحالة بالكلام («مفتوح
/// دلوقتي · بيقفل ٩ م»). النقطة كانت إشارة تانية بتساعد المسح السريع —
/// وده **نقص حقيقي** مكتوب هنا عشان محدش يفتكره سهو.
class ServiceProviderDetailsHoursWidget extends StatelessWidget {
  final BranchUiModel branch;

  const ServiceProviderDetailsHoursWidget({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return AppAccordionWidget(
      title: branch.openStatusLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: branch.workingHours.map((day) => _DayRow(day: day)).toList(),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final BranchWorkingDay day;

  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day.dayName,
              style: day.isToday
                  ? AppTextStyles.bodyMdStrong
                  : AppTextStyles.bodyMdMuted,
            ),
          ),
          // اليوم المقفول بيتعرض «مغلق» مش بيتشال — الفراغ بيعلّم العميل
          // إيقاع المحل.
          Text(
            day.hoursLabel,
            style: day.isClosed
                ? AppTextStyles.captionInk
                : AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
