import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/policy_ui_model.dart';
import 'package:waqty_user_application/core/widgets/policy_note_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **«قبل ما تحجز»** — تعليمات الحجز وسياسة الإلغاء في أكورديون مقفول.
///
/// ## ليه مقفول افتراضيًا
///
/// السياسة معلومة **بتتراجع لما تلزم**، مش حاجة العميلة بتقراها كل مرة.
/// وفتحه افتراضيًا بيدفع الخدمات والأسعار — اللي هي سبب دخولها الشاشة —
/// تحت الطيّة.
///
/// ## الطي
///
/// بيرجّع [SizedBox.shrink] لما مافيش ولا سياسة من الاتنين. ده مش تفصيلة
/// جمالية: النهاردة **كل الفروع** مالهاش سياسات (BE-B1 لسه)، فالسلوك
/// الافتراضي للـwidget ده هو الاختفاء الكامل — ولو ظهر هيدر فاضي، هيظهر
/// في كل شاشة مزوّد في التطبيق.
class PolicyAccordionWidget extends StatelessWidget {
  const PolicyAccordionWidget({required this.policies, super.key});

  final PolicyUiModel policies;

  @override
  Widget build(BuildContext context) {
    if (!policies.hasPreBooking) return const SizedBox.shrink();

    return AppAccordionWidget(
      title: 'قبل ما تحجز',
      child: PolicyNoteWidget.column(<PolicyNoteWidget>[
        PolicyNoteWidget(
          label: 'تعليمات',
          text: policies.bookingInstructions,
        ),
        PolicyNoteWidget(label: 'الإلغاء', text: policies.cancellationPolicy),
      ], gap: AppSpacing.s12),
    );
  }
}

/// **تعليمات قبل الزيارة** — بانر بيظهر قبل الميعاد بـ٢٤ ساعة.
///
/// ## ليه ٢٤ ساعة
///
/// التعليمات دي أفعال («تعالى بشعر نضيف»، «ماتاكلش قبلها بساعتين») —
/// وبتنفع بس وهي لسه ممكنة. بانر بيقول «ماتاكلش» بعد الميعاد بيوم مش
/// معلومة، ده ضوضاء.
///
/// بيختفي لو النص فاضي **أو** الميعاد لسه بعيد أو عدّى.
class PreVisitBannerWidget extends StatelessWidget {
  const PreVisitBannerWidget({
    required this.policies,
    required this.startAt,
    super.key,
  });

  final PolicyUiModel policies;

  /// بداية أقرب زيارة في الحجز. `null` = مانرسمش.
  final DateTime? startAt;

  /// النافذة اللي البانر بيظهر فيها — من ٢٤ ساعة قبل الميعاد لحد بدايته.
  static bool isWithinWindow(DateTime? startAt, {DateTime? now}) {
    if (startAt == null) return false;
    final current = now ?? DateTime.now();
    if (startAt.isBefore(current)) return false;
    return startAt.difference(current) <= const Duration(hours: 24);
  }

  @override
  Widget build(BuildContext context) {
    if (policies.preVisitInstructions.isEmpty) return const SizedBox.shrink();
    if (!isWithinWindow(startAt)) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s12.h),
      child: AppBannerWidget(
        title: 'تعليمات قبل الزيارة',
        message: policies.preVisitInstructions,
        icon: Icons.info_outline_rounded,
      ),
    );
  }
}
