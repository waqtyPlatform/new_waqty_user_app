import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_cubit.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_state.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/widgets/reassignment_change_request_sheet.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/widgets/reassignment_conversation_widget.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/widgets/reassignment_proposal_card_widget.dart';

/// شاشة إعادة توزيع الحجز.
///
/// ## ليه الشاشة دي موجودة
///
/// الموظف بيخرج إجازة أو بيسيب الشغل، والفرع لازم ينقل حجوزاته. قبل كده
/// ده كان بيحصل بمكالمة تليفون — أو بالنقل من غير سؤال أصلاً. الفلو ده
/// بيدي العميل القرار: يقبل البديل، أو يطلب غيره، أو يلغي.
///
/// ⚠ **بيشتغل للحجوزات المعمولة من الأبلكيشن بس** (`booking_source =
/// 'mobile_app'`). أي حجز اتعمل بالتليفون أو في الفرع بيتنقل مباشرة.
///
/// ⚠ **الشاشة دي مش في التبويبات.** الحالة الطبيعية إن مفيش أي طلب، وتبويب
/// فاضي طول الوقت بياخد مساحة من غير قيمة. المداخل: بانر على الرئيسية،
/// وكارت على تفاصيل الحجز، و(لما الـpush ينزل) الإشعار نفسه.
class ReassignmentScreen extends StatelessWidget {
  const ReassignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReassignmentCubit.get(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تغيير في حجزك')),
      body: BlocConsumer<ReassignmentCubit, ReassignmentState>(
        listener: (context, state) => _onState(context, state),
        builder: (context, state) => _body(context, cubit, state),
      ),
    );
  }

  void _onState(BuildContext context, ReassignmentState state) {
    switch (state) {
      case ReassignmentAcceptedState():
        AppSnack.show(context, message: 'تمام، حجزك اتنقل للميعاد الجديد');
        context.pop();

      case ReassignmentCancelledState():
        AppSnack.show(context, message: 'الحجز اتلغى');
        context.pop();

      case ReassignmentActionFailedState(:final message):
        AppSnack.show(context, message: message, isError: true);

      case _:
        break;
    }
  }

  Widget _body(
    BuildContext context,
    ReassignmentCubit cubit,
    ReassignmentState state,
  ) {
    if (state is ReassignmentLoadingState) return const AppLoadingWidget();

    if (state is ReassignmentErrorState) {
      return AppErrorStateWidget(
        message: state.message,
        onRetry: cubit.load,
      );
    }

    if (state is ReassignmentEmptyState || cubit.entries.isEmpty) {
      return const AppEmptyStateWidget(
        icon: Icons.event_available_rounded,
        title: 'مفيش تغييرات على حجوزاتك',
        message: 'كل حاجة ماشية زي ما اتفقنا.',
      );
    }

    final isBusy = state is ReassignmentActionLoadingState;

    return ListView.separated(
      padding: EdgeInsetsDirectional.all(AppSpacing.pageGutter.r),
      itemCount: cubit.entries.length,
      separatorBuilder: (_, __) => verticalSpace(AppSpacing.s16),
      itemBuilder: (_, index) {
        final request = cubit.entries[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.needsMyAnswer)
              ReassignmentProposalCardWidget(
                request: request,
                isBusy: isBusy,
                onAccept: () =>
                    cubit.acceptProposal(request.activeProposal!.uuid),
                onRequestChange: () => _requestChange(context, cubit, request),
                onCancel: () => _confirmCancel(context, cubit, request),
              )
            else
              _StatusCard(request: request),

            if (request.conversation.isNotEmpty) ...[
              verticalSpace(AppSpacing.s20),
              const AppSectionHeaderWidget(title: 'المحادثة'),
              verticalSpace(AppSpacing.s12),
              ReassignmentConversationWidget(
                messages: request.conversation,
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _requestChange(
    BuildContext context,
    ReassignmentCubit cubit,
    ReassignmentUiModel request,
  ) async {
    final controller = TextEditingController();
    final note = await ReassignmentChangeRequestSheet.show(
      context,
      controller: controller,
    );
    controller.dispose();

    if (note == null) return;
    await cubit.requestChange(
      proposalUuid: request.activeProposal!.uuid,
      note: note,
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ReassignmentCubit cubit,
    ReassignmentUiModel request,
  ) async {
    final confirmed = await AppSheetWidget.show<bool>(
      context,
      icon: Icons.warning_amber_rounded,
      iconTone: AppSemanticColors.danger,
      title: 'تلغي الحجز خالص؟',
      // ⚠ الصياغة صريحة بقصد: الإلغاء هنا **مش رفض للاقتراح** — الحجز
      // الأصلي بيتلغي كمان. العميل لازم يعرف ده قبل ما يأكّد.
      message:
          'ده هيلغي حجزك كله، مش هيرجّعك لميعادك القديم — الأخصائي مش '
          'متاح فيه أصلاً.',
      actions: (sheetContext) => [
        AppButtonWidget(
          label: 'أيوه، ألغي الحجز',
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        AppButtonWidget(
          label: 'رجوع',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    );

    if (confirmed != true) return;
    await cubit.cancelProposal(request.activeProposal!.uuid);
  }
}

/// حالة مفيهاش دور للعميل — الفرع بيدوّر، أو خلص الموضوع.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.request});

  final ReassignmentUiModel request;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPillWidget(
            label: request.status.label,
            tone: switch (request.status) {
              ReassignmentStatus.applied => AppPillTone.positive,
              ReassignmentStatus.cancelled => AppPillTone.danger,
              ReassignmentStatus.noAgreement => AppPillTone.warning,
              _ => AppPillTone.info,
            },
          ),
          verticalSpace(AppSpacing.s12),
          Text(
            request.serviceName.isEmpty ? 'حجزك' : request.serviceName,
            style: AppTextStyles.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (request.originalStartAt != null) ...[
            verticalSpace(AppSpacing.s4),
            Text(
              '${AppFormat.relativeDate(request.originalStartAt!)} · '
              '${AppFormat.time(request.originalStartAt!)}',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
