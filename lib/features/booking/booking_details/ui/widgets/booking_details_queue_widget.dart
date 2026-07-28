import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_cubit.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_state.dart';
import 'package:waqty_user_application/features/booking/branch_queue/ui/widgets/branch_queue_block_widget.dart';

/// بلوك الدور جوه صفحة تفاصيل الحجز — وبيعمل الـ [BranchQueueCubit] بتاعه.
///
/// ## ليه نسخة تانية من الـ Cubit والقشرة عندها واحد
///
/// `ButtonNavigationBarScreen` بتحط `BranchQueueCubit` **فوق** التبويبات
/// الأربعة عشان الشريط اللي تحت والبؤرة اللي جوه الهوم يقروا من نفس
/// النسخة. الصفحة دي مش تبويب — هي `MaterialPageRoute` على الـ Navigator
/// الجذري، يعني **أخت** للقشرة مش بنت ليها، فالـ provider بتاعها مش جد
/// وماينفعش نوصله بـ `BlocProvider.of`.
///
/// وحتى لو كان ينفع: الصفحة دي بتتفتح لأي حجز من «حجوزاتي»، والقشرة
/// بتنبض على حجز واحد بعينه (`liveBooking`). فالنسخة المشتركة كانت
/// هتعرض طابور حجز تاني خالص.
///
/// المؤقت بيتقفل مع الصفحة (`BranchQueueCubit.close` بيلغيه)، فمفيش نبض
/// شارد بعد الرجوع.
///
/// ## ومفيش تنبيه هنا
///
/// قسم البؤرة في الهوم بيطلّع toast لما `shouldAnnounce` ترجّع `true`.
/// هنا لأ: البلوك **هو** الإعلان — عنوانه بيبقى «دورك» بالأخضر في نفس
/// اللحظة بالظبط. التنبيه كان هيغطي الحاجة اللي جاي يقول عليها.
class BookingDetailsQueueWidget extends StatelessWidget {
  final BookingUiModel booking;

  const BookingDetailsQueueWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BranchQueueCubit>(
      create: (_) => BranchQueueCubit(booking: booking)..start(),
      child: BlocBuilder<BranchQueueCubit, BranchQueueState>(
        // البلوك بيقصر لما الطابور يخلص (بيرمي شريط التقدّم وسطر آخر
        // تحديث)، وبيطول تاني لو الحالة رجعت حية. من غير ده الكارت
        // بينط والصفحة كلها بتتزحلق تحته.
        builder: (context, state) => AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          // الحافة العليا ثابتة — الكارت بيتطوي لتحت، فاسم المزود اللي
          // فوقه مابيتحركش.
          alignment: AlignmentDirectional.topCenter,
          child: state is BranchQueueReadyState
              ? BranchQueueBlockWidget(queue: state.queue)
              // `start()` بيعمل أول نبضة **متزامنة** قبل ما الابن يتبني
              // أصلاً، فالحالة دي عمرها ما بتتعرض. موجودة عشان الـ
              // switch يفضل كامل مش عشان العميل يشوفها.
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
