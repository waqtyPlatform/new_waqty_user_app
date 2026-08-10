import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_state.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/widgets/waitlist_card_widget.dart';

/// العرض اللي عليه عدّاد شغّال — **فوق كل حاجة في الرئيسية**.
///
/// ## ليه موجود أصلاً
///
/// الفرع بيعرض ميعاد وبيحجزه **٥ دقايق**. قبل ده، الكارت كان في تبويب
/// الحجوزات بس — يعني الشاشة اللي العميل بيفتح عليها الأبلكيشن مافيهاش
/// ولا كلمة عن أهم حاجة بتحصل له دلوقتي.
///
/// خمس دقايق مدة قصيرة لدرجة إن «هيلاقيه لما يفتح التبويب» رهان مش خطة.
/// وبعد ما تعدّي، الميعاد بيروح لحد تاني.
///
/// ## اللي بيتعرض هنا **العروض بس**
///
/// إدخال `pending` (مستني في الطابور من غير عرض) **مالوش وقت بيجري**،
/// فمالوش لزمة فوق الرئيسية — مكانه تبويب الحجوزات. القسم ده بيتفلتر على
/// [WaitlistUiModel.isHoldActive] عشان مايتحوّلش لقسم دايم يقعد فوق
/// الشاشة ومحدش يبص له.
///
/// ## وليه الكارت كامل مش شريط مختصر
///
/// العدّاد لوحده بيسيب العميل قدام رقم بينزل من غير ما يعرف يعمل إيه.
/// السطر الأخير في الكارت («الفرع بيأكّد الحجز ده دلوقتي — استنى مكالمة»)
/// هو **الجزء اللي بيمنع الذعر**، فاختصاره بيخلي القسم أوحش من عدمه.
///
/// و`onRemove` مش متمرّر عن قصد: «اخرج من القائمة» فعل ماله رجعة، ومكانه
/// مش شاشة العميل بيمرّ عليها بعينه.
class HomeWaitlistOfferWidget extends StatelessWidget {
  const HomeWaitlistOfferWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // الـ cubit جاي من `ButtonNavigationBarScreen` فوق التبويبات — نفس
    // النسخة اللي تبويب الحجوزات بيقرا منها، فالعدّاد رقم واحد في
    // الأبلكيشن كله.
    return BlocBuilder<WaitlistCubit, WaitlistState>(
      builder: (context, state) {
        if (state is! WaitlistReadyState) return const SizedBox.shrink();

        // `DateTime.now()` بيتقرا مرة واحدة هنا وبيتمرّر لكل الكروت —
        // لو كل كارت قرا لوحده، اتنين في نفس البناء ممكن يطلعوا على
        // ثانيتين مختلفتين.
        final now = DateTime.now();
        final offers = state.entries.where((e) => e.isHoldActive(now)).toList();

        if (offers.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsetsDirectional.only(
            top: AppSpacing.sectionBreak.h,
            start: AppSpacing.pageGutter.w,
            end: AppSpacing.pageGutter.w,
          ),
          child: WaitlistSectionWidget(entries: offers, now: now),
        );
      },
    );
  }
}
