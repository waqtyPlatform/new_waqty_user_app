import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// محادثة العميل مع الفرع حوالين الطلب.
///
/// ⚠ **مش شات لحظي.** مفيش websockets ولا polling — الرسايل بتتحدّث لما
/// الشاشة تعيد القراءة (بعد إرسال، أو رجوع من الخلفية). الشكل بيقول ده:
/// فقاعات بسيطة بتاريخ، من غير «بيكتب دلوقتي» ولا علامات قراءة.
class ReassignmentConversationWidget extends StatelessWidget {
  const ReassignmentConversationWidget({required this.messages, super.key});

  final List<ReassignmentMessageUiModel> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final message in messages) ...[
          _Bubble(message: message),
          verticalSpace(AppSpacing.s8),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ReassignmentMessageUiModel message;

  @override
  Widget build(BuildContext context) {
    final isSystem = message.sender == ReassignmentSender.system;
    final isMine = message.isMine;

    // ⚠ رسايل النظام **وسط وبلا فقاعة** — دي مش طرف في المحادثة، دي
    // إعلان عن حاجة حصلت. لو خدت فقاعة زي الفرع، العميل يفتكر إن حد
    // كتبها بإيده.
    if (isSystem) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          message.body,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        // ٨٠٪ من العرض — عشان يبان مين بيتكلم من الشكل مش من اللون بس.
        constraints: BoxConstraints(maxWidth: 0.8.sw),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12.w,
            vertical: AppSpacing.s8.h,
          ),
          decoration: BoxDecoration(
            color: isMine
                ? AppSemanticColors.surfaceAccentSoft
                : AppSemanticColors.surfaceSunken,
            borderRadius: BorderRadius.circular(AppRadius.m.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.body,
                style: AppTextStyles.bodyMd,
              ),
              verticalSpace(AppSpacing.s4),
              Text(
                AppFormat.relativeDateTime(message.createdAt),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
