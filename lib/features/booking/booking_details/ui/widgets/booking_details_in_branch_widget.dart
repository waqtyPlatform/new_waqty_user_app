import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_cubit.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_state.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_block_widget.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/repo/in_branch_repo.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';

/// بلوك «إنت في الفرع» جوه صفحة تفاصيل الحجز — وبيعمل الـ [InBranchCubit]
/// بتاعه.
///
/// ## ليه نسخة تانية من الـ Cubit
///
/// `ButtonNavigationBarScreen` بتحط `InBranchCubit` **فوق** التبويبات
/// وبتربطه بالحجز الحي بتاع النهاردة. صفحة التفاصيل ممكن تتفتح على **أي**
/// حجز — بما فيه حجز تاني خالص — فقراءة الـ cubit اللي فوق كانت هتعرض
/// حالة حجز غير اللي إنت فاتحه.
///
/// المؤقت بيتقفل مع الصفحة (`InBranchCubit.close` بيلغيه)، فمفيش نبض
/// شارد ورا الشاشة.
class BookingDetailsInBranchWidget extends StatelessWidget {
  final BookingUiModel booking;

  const BookingDetailsInBranchWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // الحجز اللي مش في الفرع مالوش بلوك — ومابنعملّوش cubit ولا مؤقت.
    if (!shouldShowInBranch(booking, DateTime.now())) {
      return const SizedBox.shrink();
    }

    return BlocProvider<InBranchCubit>(
      create: (_) => InBranchCubit(getIt<InBranchRepo>(), booking: booking)..start(),
      child: BlocBuilder<InBranchCubit, InBranchState>(
        builder: (context, state) => AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          child: state is InBranchReadyState
              ? InBranchBlockWidget(data: state.data)
              : const SizedBox(width: double.infinity),
        ),
      ),
    );
  }
}
