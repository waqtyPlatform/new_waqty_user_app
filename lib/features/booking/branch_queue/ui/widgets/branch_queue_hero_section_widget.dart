import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_cubit.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_state.dart';
import 'package:waqty_user_application/features/booking/branch_queue/ui/widgets/branch_queue_hero_widget.dart';

/// بيوصّل الـ Cubit بالبؤرة، وبيطلّع التنبيه لما الدور يقرب.
///
/// ## التنبيه داخل الأبلكيشن بس — والحد ده مقصود
///
/// مفيش أي حزمة إشعارات في المشروع، ومفيش Firebase، ومفيش بروادكاست في
/// الباك إند. يعني «قول لي لما دوري يقرب» **مش هتصحّيك** — هتشوفها لما
/// تفتح الأبلكيشن.
///
/// مابنضيفش `flutter_local_notifications` عشان الإشعار يطلع في الشريط،
/// لأن ده **بيبان أقوى وهو مش أقوى**: الأبلكيشن لازم يفضل شغّال عشان
/// يعرف إن الدور اتحرك أصلاً. الحل الحقيقي FCM push من السيرفر، والطبقة
/// دي مكتوبة عشان يدخل من تحتها من غير إعادة كتابة —
/// [BranchQueueCubit.shouldAnnounce] هو نقطة الدخول.
class BranchQueueHeroSectionWidget extends StatelessWidget {
  const BranchQueueHeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BranchQueueCubit, BranchQueueState>(
      listener: (context, state) {
        if (state is! BranchQueueReadyState) return;

        final cubit = BranchQueueCubit.get(context);
        if (!cubit.shouldAnnounce(state.queue.state)) return;

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 5),
          title: Text(
            state.queue.state == QueueState.yourTurn
                ? 'دورك دلوقتي'
                : 'دورك قرب — ابدأ تتحرك',
            style: AppTextStyles.cardTitle,
          ),
          description: Text(
            state.queue.state == QueueState.yourTurn
                ? 'اتوجّه للريسيبشن'
                : 'فاضل ${state.queue.aheadOfMe} قدامك',
            style: AppTextStyles.caption,
          ),
        );
      },
      builder: (context, state) {
        final cubit = BranchQueueCubit.get(context);
        final queue = cubit.queue;

        // أول تحميل بس هو اللي بيوري مكان فاضي. النبض بعد كده صامت.
        if (queue == null) {
          return SizedBox(height: 148.h, child: const ColoredBox(
            color: AppSemanticColors.surfaceInk,
          ));
        }

        return AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          child: BranchQueueHeroWidget(
            booking: cubit.booking,
            queue: queue,
            onTap: () {},
          ),
        );
      },
    );
  }
}
