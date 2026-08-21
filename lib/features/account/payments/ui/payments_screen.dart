import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/payments/logic/payments_cubit.dart';
import 'package:waqty_user_application/features/account/payments/logic/payments_state.dart';
import 'package:waqty_user_application/features/account/payments/ui/widgets/payment_row_widget.dart';

/// سجل المدفوعات.
///
/// ⚠ **قراية بس ومفيش زرار دفع.** `/api/user/payments` فيه `index` و`show`
/// وخلاص — الأبلكيشن مايقدرش ياخد فلوس. الدفع بيتسجّل من الفرع، والشاشة دي
/// بتوري العميل اللي اتسجّل عليه.
///
/// وده مش نقص في الربط: مفيش تكامل بوابة دفع في المنصة كلها. أي «ادفع
/// دلوقتي» هنا هيبقى زرار بيكدب.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PaymentsCubit.get(context);

    return Scaffold(
      appBar: AppBar(title: const Text('مدفوعاتي')),
      body: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) => _body(context, cubit, state),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    PaymentsCubit cubit,
    PaymentsState state,
  ) {
    if (state is PaymentsLoadingState) return const AppLoadingWidget();

    if (state is PaymentsErrorState) {
      return AppErrorStateWidget(message: state.message, onRetry: cubit.load);
    }

    if (state is PaymentsEmptyState) {
      return const AppEmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: 'مفيش مدفوعات لسه',
        // ⚠ النص بيشرح **ليه** فاضية مش بيقول «فاضي» وخلاص — الحالة دي
        // طبيعية تمامًا لعميل بيدفع كاش في الفرع.
        message: 'أول ما تدفع في أي فرع، الدفعة هتتسجّل هنا.',
      );
    }

    final itemCount = cubit.payments.length + (cubit.hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.axis != Axis.vertical) return false;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            cubit.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.pageGutter.w,
          ),
          // **من غير السطر ده الـ`RefreshIndicator` ميت** لما القايمة أقصر
          // من الشاشة — نفس السبب في `MyBookingsScreen`.
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (_, index) {
            if (index >= cubit.payments.length) {
              return Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.s16.h,
                ),
                child: const AppLoadingWidget(),
              );
            }

            return PaymentRowWidget(
              payment: cubit.payments[index],
              showHairline:
                  index != cubit.payments.length - 1 || cubit.hasMore,
            );
          },
        ),
      ),
    );
  }
}
