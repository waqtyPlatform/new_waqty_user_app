import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/widgets/reassignment_comparison_widget.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/widgets/reassignment_countdown_widget.dart';

/// كارت الاقتراح — المقارنة والعدّاد والتلات أفعال.
///
/// ⚠ **الأفعال التلاتة مش متساوية.**
///
/// | الفعل | النتيجة |
/// |---|---|
/// | اقبل | الحجز بيتنقل للميعاد الجديد |
/// | مش مناسب | الفرع بيدوّر تاني — **بس ٣ محاولات كحد أقصى** |
/// | إلغاء | **بيلغي الحجز كله** مش بيرجّعه لميعاده القديم |
///
/// فالقبول أساسي، وطلب التغيير ثانوي، والإلغاء نص هادي. عرضهم بنفس الوزن
/// بيخلي العميل يدوس «إلغاء» وهو فاكر إنه بيرفض الاقتراح بس.
class ReassignmentProposalCardWidget extends StatelessWidget {
  const ReassignmentProposalCardWidget({
    required this.request,
    required this.onAccept,
    required this.onRequestChange,
    required this.onCancel,
    this.isBusy = false,
    super.key,
  });

  final ReassignmentUiModel request;
  final VoidCallback onAccept;
  final VoidCallback onRequestChange;
  final VoidCallback onCancel;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final proposal = request.activeProposal;
    final isHoldActive = request.isHoldActive(DateTime.now());
    final canAct = proposal != null && isHoldActive && !isBusy;

    return AppSurfaceWidget(
      level: AppElevation.raised,
      padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⚠ `Wrap` مش `Row`: العنوان والشارة الاتنين مايتقصّوش — الخدمة
          // اسمها ممكن يطول، وعدّاد المحاولات رقم. عند ١٫٣ الـ`Row` بيفيض.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s4.h,
            children: [
              Text(
                request.serviceName.isEmpty ? 'حجزك' : request.serviceName,
                style: AppTextStyles.sectionHeader,
              ),
              AppPillWidget(
                label:
                    'محاولة ${AppFormat.digits(request.attempts)} '
                    'من ${AppFormat.digits(request.maxAttempts)}',
                tone: request.isLastAttempt
                    ? AppPillTone.warning
                    : AppPillTone.neutral,
              ),
            ],
          ),

          verticalSpace(AppSpacing.s16),
          ReassignmentComparisonWidget(request: request),

          if (proposal != null && proposal.branchMessage.isNotEmpty) ...[
            verticalSpace(AppSpacing.s16),
            AppBannerWidget(
              title: 'رسالة من الفرع',
              message: proposal.branchMessage,
              icon: Icons.storefront_rounded,
            ),
          ],

          if (proposal != null) ...[
            verticalSpace(AppSpacing.s16),
            ReassignmentCountdownWidget(proposal: proposal),
          ],

          if (request.isLastAttempt && isHoldActive) ...[
            verticalSpace(AppSpacing.s12),
            Text(
              'دي آخر محاولة. لو الميعاد ده مش مناسب، الفرع هيتواصل معاك '
              'على طول بدل الأبلكيشن.',
              style: AppTextStyles.caption.copyWith(
                color: AppSemanticColors.dangerOnSoft,
              ),
            ),
          ],

          verticalSpace(AppSpacing.s20),

          AppButtonWidget(
            label: 'يناسبني، اقبل',
            onPressed: canAct ? onAccept : null,
            isLoading: isBusy,
          ),
          verticalSpace(AppSpacing.s8),
          AppButtonWidget(
            label: 'الميعاد ده مش مناسب',
            variant: AppButtonVariant.secondary,
            onPressed: canAct ? onRequestChange : null,
          ),
          verticalSpace(AppSpacing.s8),

          // ⚠ نص هادي مش زرار: ده بيلغي **الحجز كله**، والوزن البصري لازم
          // يقول إنه الطريق الأبعد مش بديل مساوي.
          Center(
            child: TextButton(
              onPressed: canAct ? onCancel : null,
              child: Text(
                'إلغاء الحجز خالص',
                style: AppTextStyles.caption.copyWith(
                  color: AppSemanticColors.dangerOnSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
