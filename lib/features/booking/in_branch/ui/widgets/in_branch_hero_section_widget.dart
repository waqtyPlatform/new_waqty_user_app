import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_cubit.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_state.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_hero_widget.dart';

/// بيوصّل الـ Cubit بالبؤرة، وبيطلّع التنبيه لما الحالة تتحرّك.
///
/// ## ده **محاكاة** الـ push مش بديل ليه — والفرق مقصود
///
/// العميل اللي مستني دوره **مش ماسك الأبلكيشن**. تجربة الوصول push أولاً،
/// والشاشة هي اللي بيقع عليها **بعد** الإشعار. اختبار الشاشات من غير
/// المُطلِق بيختبر الحاجة الغلط.
///
/// ومفيش transport في المنظومة كلها: `POST /api/device-token` بيخزّن
/// التوكنات في `app_device_tokens` و**محدش بيقراها** — صفر sender وصفر
/// job وصفر listener وصفر package. والـ `notify()` في داشبورد المزود
/// `return $this->review($uuid)` يعني بيعلّم الإدخال «تحت المراجعة» وبس.
///
/// فبنحاكي **اللحظة** عشان نعرف لو التلات رسايل دول هما الصح:
/// *وصلت* · *إنت اللي جاي* · *الكرسي جاهز*.
///
/// مابنضيفش `flutter_local_notifications` عشان الإشعار يطلع في شريط
/// النظام، لأن ده **بيبان أقوى وهو مش أقوى**: الأبلكيشن لازم يفضل شغّال
/// عشان يعرف إن الحالة اتحركت أصلاً. الحل الحقيقي FCM من السيرفر،
/// و[InBranchCubit.shouldAnnounce] هو نقطة الدخول اللي بيدخل من تحتها.
class InBranchHeroSectionWidget extends StatelessWidget {
  const InBranchHeroSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InBranchCubit, InBranchState>(
      listener: (context, state) {
        if (state is! InBranchReadyState) return;

        final cubit = InBranchCubit.get(context);
        if (!cubit.shouldAnnounce(state.data)) return;

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 5),
          title: Text(state.data.announcement, style: AppTextStyles.cardTitle),
          description: Text(
            '${cubit.booking.providerName} · ${cubit.booking.branchName}',
            style: AppTextStyles.caption,
          ),
        );
      },
      builder: (context, state) {
        final cubit = InBranchCubit.get(context);

        // أول تحميل بس هو اللي بيوري مكان فاضي. النبض بعد كده صامت.
        if (state is InBranchInitialState || state is InBranchLoadingState) {
          return SizedBox(
            height: 148.h,
            child: ColoredBox(color: AppSemanticColors.surfaceInk),
          );
        }

        return AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          child: InBranchHeroWidget(
            booking: cubit.booking,
            data: cubit.data,
            // كان `onTap: () {}` — بؤرة الشاشة بتاخد ضغطة وبترد بلا شيء.
            onTap: () => context.pushNamed(
              Routes.bookingDetailsScreen,
              arguments: <String, dynamic>{'bookingUuid': cubit.booking.uuid},
            ),
          ),
        );
      },
    );
  }
}
