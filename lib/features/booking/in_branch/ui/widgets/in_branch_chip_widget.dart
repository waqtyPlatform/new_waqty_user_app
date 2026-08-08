import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// مؤشر مصغّر — بيقعد **جنب** `BookingStatusChipWidget` في صف الحجز
/// جوه اللستة.
///
/// ## الحشوة متطابقة عن قصد
///
/// ٨ أفقي و٤ رأسي و`pill` و`overline` — نفس أرقام شارة الحالة بالظبط.
/// شارتين لازقين في بعض بحشوتين مختلفتين بيقروا كأنهم من أبلكيشنين، وده
/// بالظبط نوع التفكّك اللي إعادة التصميم دي بتصلحه.
///
/// ## بيرجع صفر لما مفيش حاجة تتقال
///
/// حجز مش في الفرع مالوش مؤشر. الشارة **مابتترسمش خالص**
/// ([SizedBox.shrink]) بدل ما تقول «—» أو تسيب مساحة فاضية: صف فيه شارة
/// وصف فيه فراغ بنفس المقاس بيخلي اللستة تبان مليانة خانات مكسورة.
///
/// ## وبيقول التقدير مش رقم الدور
///
/// القديم كان بيقول «٣ قدامك» — رقم مالوش معنى لما تلات كراسي بتشتغل
/// مع بعض. ده بيقول التقدير أو «الكرسي جاهز».
class InBranchChipWidget extends StatelessWidget {
  final InBranchUiModel data;

  const InBranchChipWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;

    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.standard,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      child: AnimatedDefaultTextStyle(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        style: AppTextStyles.overline.copyWith(color: foreground),
        child: Text(_label, maxLines: 1),
      ),
    );
  }

  String get _label => switch (data.status) {
    BookingStatus.arrived => 'هننده عليك',
    // من غير تقدير، الشيبة بتقول **الحالة** بدل الرقم. `estimateLabel`
    // بترجّع فاضي ساعتها، وشيبة فاضية بتسيب دايرة ملوّنة مالهاش معنى
    // على الصف — أسوأ من إنها ماتبانش.
    BookingStatus.waiting =>
      data.hasLiveEstimate ? data.estimateLabel : 'في الانتظار',
    BookingStatus.inProgress => 'جاري تنفيذها',
    _ => '',
  };

  /// الأخضر للحالة اللي محتاجة حركة من العميل بس. لو «جاري الخدمة» خدت
  /// أخضر كمان، مابقاش فيه فرق بين «تحرّك» و«اقعد مطمن».
  (Color, Color) get _colors => data.needsAttention
      ? (AppSemanticColors.accentSoft, AppSemanticColors.accent)
      : (AppSemanticColors.surfaceSunken, AppSemanticColors.textOnSunken);
}
