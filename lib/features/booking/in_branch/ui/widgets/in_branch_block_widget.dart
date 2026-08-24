import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// بلوك «إنت في الفرع» — بيقعد في **صفحة تفاصيل الحجز**.
///
/// ## ليه ده كارت مش شريط زي بؤرة الهوم
///
/// الشريط الغامق الممتد من حافة لحافة هو **الحاجة الوحيدة** في الأبلكيشن
/// اللي بتكسر الاستدارة والإضاءة مع بعض. لو اتكرر في صفحة تانية بيبطّل
/// يعني «دي البؤرة» ويبقى مجرد لون. فهنا سطح مرفوع عادي، والفرق إنه
/// **بيقول أكتر** مش إنه بيصرّخ أعلى.
///
/// ## اللي اتغيّر عن بلوك الطابور القديم
///
/// راح: «٣ قدامك» و«الدور دلوقتي ١٢» وشريط التقدّم. رقم الدور استعارة
/// بنك — طابور واحد وشبّاك واحد. الصالون تلات كراسي ومواعيد، ورقمك
/// مابيتحركش لما حد يخلص عند أخصائي تاني.
///
/// جه: **الشخص والوقت**. «أحمد لسه مع عميل — تقريبًا ١٠–٢٠ دقيقة» هي
/// الجملة اللي الريسيبشن بيقولها فعلاً.
///
/// ## قاعدتين مش قابلين للتفاوض — منقولين من القديم
///
/// **١. التقدير مدى دايمًا.** [InBranchUiModel.estimateLabel] عمره ما
/// بيرجّع رقم واحد. «باقي ٢٧ دقيقة» بيتكسر مرة واحدة والعميل بيبطّل
/// يصدّق أي رقم بنعرضه بعدها.
///
/// **٢. وقت آخر تحديث ظاهر دايمًا** طول ما فيه تقدير حي على الشاشة.
class InBranchBlockWidget extends StatelessWidget {
  final InBranchUiModel data;

  const InBranchBlockWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final accentedColor = data.needsAttention
        ? AppSemanticColors.accent
        : AppSemanticColors.textPrimary;

    return AppSurfaceWidget(
      padding: AppSpacing.cardLoose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اللابل من ألفاظ السيرفر — نفس الكلمة اللي على الداشبورد.
          Text(data.label, style: AppTextStyles.overline),
          verticalSpace(AppSpacing.s4),

          // العنوان بيتبدّل بتلاشي لما الحالة تتقدّم. الـ key على **نص**
          // العنوان مش على الحالة — لو كان على الحالة، تغيّر التقدير
          // جوه نفس الحالة مكانش هيتحرّك.
          AnimatedSwitcher(
            duration: AppMotion.base,
            switchInCurve: AppMotion.standard,
            // الافتراضي بيكوّم النصين بـ `Alignment.center` — يعني النص
            // الطالع بيزحف أفقيًا وهو بيختفي. الوقوف على بداية السطر
            // بيخلي التبديل في مكانه.
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: Text(
              data.headline,
              key: ValueKey<String>(data.headline),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              // `displayLg` (٣٢) مش `displayXl` (٤٠) — الأربعين محجوزة
              // لبؤرة الهوم، ولو اتكررت هنا الاتنين بيفقدوا معناهم.
              style: AppTextStyles.displayLg.copyWith(color: accentedColor),
            ),
          ),

          if (data.subline.isNotEmpty) ...[
            verticalSpace(AppSpacing.s4),
            Text(data.subline, style: AppTextStyles.bodyMdMuted),
          ],

          if (data.hasLiveEstimate) ...[
            verticalSpace(AppSpacing.s12),
            const AppHairlineWidget(),
            verticalSpace(AppSpacing.s8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.freshnessLabel(DateTime.now()),
                    style: AppTextStyles.overline.copyWith(
                      color: AppSemanticColors.textSecondary,
                    ),
                  ),
                ),
                // **الشفافية دي مقصودة.** التقدير مضروب — مفيش endpoint
                // بيحسبه — فبنقول إنه تقدير بدل ما نعرضه كأنه حقيقة.
                Text(
                  'تقدير',
                  style: AppTextStyles.overline.copyWith(
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// بيقرر البلوك يظهر ولا لأ من حالة **الزيارة الحالية**.
///
/// الحجز اللي مش في الفرع مالوش بلوك — **مش بلوك فاضي**. سطح مرفوع فيه
/// شرطة بيقرا كأنه معطّل، والشاشة بتبان مليانة خانات مكسورة.
///
/// ⚠ **الزيارة هي اللي بتقرر مش الحجز.** الحجز الأب بياخد حالة ملمومة من
/// زياراته، فحجز بزيارتين اللي أولاهم `arrived` بيبقى `arrived` كله —
/// والشرط القديم كان بيوري «إنت في الفرع» في الست ساعات اللي بين
/// الزيارتين والعميل قاعد في بيته.
bool shouldShowInBranch(BookingUiModel booking, DateTime now) =>
    booking.currentVisit(now).status.isInBranch;
