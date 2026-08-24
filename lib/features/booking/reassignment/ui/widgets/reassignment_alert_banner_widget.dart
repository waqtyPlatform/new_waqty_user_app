import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_cubit.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_state.dart';

/// بانر «فيه تغيير في حجزك» — **تعويض غياب الإشعارات**.
///
/// ## ليه موجود
///
/// `BookingReassignmentLifecycleEvent` بيتبعت في الباك-إند بفلاجات
/// `notifyCustomer` بس **مفيش أي listener مسجّل**، ومفيش مرسل FCM. يعني
/// العميل مايوصلوش أي إشعار لما الفرع يقترح بديل.
///
/// والمهلة **١٥ دقيقة**. مهلة العميل يعرف بيها بالصدفة لما يفتح الأبلكيشن
/// مش مهلة — التلات محاولات بيخلصوا في صمت والفرع يستنتج إن الفيتشر مش
/// شغالة.
///
/// فالبانر ده بيخلي أي فتحة للأبلكيشن تقول الخبر. **مش بديل عن الـpush**،
/// بس بيقلّل حالات «العميل عرف بعد ما المهلة راحت».
///
/// ⚠ بيختفي بالكامل (`SizedBox.shrink`) لما مفيش طلب — الحالة الغالبة إن
/// مفيش، ومساحة فاضية فوق الشاشة كل يوم أوحش من إعلان نادر.
class ReassignmentAlertBannerWidget extends StatelessWidget {
  const ReassignmentAlertBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReassignmentCubit, ReassignmentState>(
      builder: (context, _) {
        final cubit = ReassignmentCubit.get(context);
        if (!cubit.hasOpenRequest) return const SizedBox.shrink();

        return AppBannerWidget(
          tone: AppPillTone.warning,
          icon: Icons.schedule_rounded,
          title: 'فيه تغيير في حجزك',
          message: 'الفرع اقترحلك ميعاد بديل ومستني ردك.',
          actionLabel: 'شوف الاقتراح',
          onAction: () => context.pushNamed(Routes.reassignmentScreen),
        );
      },
    );
  }
}
