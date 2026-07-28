import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// عشان `BookingStatusLabel.isUpcoming` — الـ extension ساكن مع الموديل.
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/core/widgets/loading_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_actions_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_info_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_queue_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_rate_sheet_widget.dart';
import 'package:waqty_user_application/core/widgets/booking_status_chip_widget.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // `sectionHeader` محجوز لعناوين الـ AppBar والـ sheets — كان
        // `cardTitle` (١٦) هنا، يعني عنوان الشاشة كان بنفس حجم عنوان أي
        // كارت جواها.
        title: Text('تفاصيل الحجز', style: AppTextStyles.sectionHeader),
      ),
      body: BlocConsumer<BookingDetailsCubit, BookingDetailsState>(
        listener: (context, state) {
          if (state is CancelSuccessState) {
            context.pop();
          }
          if (state is RateSuccessState) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppSemanticColors.accent,
                content: Text(
                  'شكرًا، وصلنا تقييمك',
                  style: AppTextStyles.labelOnAccent,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = BookingDetailsCubit.get(context);

          if (state is BookingDetailsErrorState) {
            return Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: ErrorStateWidget(
                message: state.message,
                onRetry: cubit.loadBooking,
              ),
            );
          }

          final booking = cubit.booking;
          if (booking == null) {
            return const Center(
              child: LoadingWidget(color: AppSemanticColors.accent),
            );
          }

          return ListView(
            // `.all(16.r)` كان بيدي ١٦ تحت كمان — وآخر حاجة في الصفحة
            // زراير، فكانوا لازقين في حافة الجهاز. `screenBottom` هو
            // نفس الرقم اللي كل شاشة بتسكرول بتنتهي بيه.
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.pageGutter.w,
              end: AppSpacing.pageGutter.w,
              top: AppSpacing.s16.h,
              bottom: AppSpacing.screenBottom.h,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.providerName,
                      style: AppTextStyles.titleLg,
                    ),
                  ),
                  BookingStatusChipWidget(status: booking.status),
                ],
              ),
              verticalSpace(AppSpacing.s16),

              // الدور فوق التفاصيل — ده الرقم الوحيد في الصفحة اللي
              // بيتغيّر وإنت واقف تبصله. رقم الحجز والفرع والسعر ثابتين
              // ومحدش بيفتح الصفحة عشانهم وهو في الطريق للمحل.
              //
              // الحجوزات المنتهية والملغية مالهاش طابور، والبلوك مش
              // بيطوي نفسه (بيعرض «تمّت» في كل حالة) — فالـ `if` هنا
              // مطلوب، وحالة الحجز مابتتغيّرش والصفحة مفتوحة فمافيش
              // حركة بتتقتل.
              if (booking.status.isUpcoming) ...[
                BookingDetailsQueueWidget(booking: booking),
                verticalSpace(AppSpacing.s16),
              ],

              BookingDetailsInfoWidget(booking: booking),
              verticalSpace(AppSpacing.s24),
              BookingDetailsActionsWidget(
                booking: booking,
                onCancel: () => _confirmCancel(context, cubit),
                onRate: () => _showRateSheet(context, cubit),
                onRebook: () => context.pop(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// تأكيد الإلغاء — الإجراء ده مالوش رجعة، فبنسأل.
  void _confirmCancel(BuildContext context, BookingDetailsCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s16.w,
          end: AppSpacing.s16.w,
          top: AppSpacing.s8.h,
          // الكيبورد بيفتح على الحقل ده، فمحتاجين viewInsets كمان.
          bottom:
              MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تلغي الحجز؟', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s4),
            Text(
              'هتلغي حجزك في ${cubit.booking?.providerName ?? ''}',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s16),
            // الحشوة والحدود والخلفية كلهم من `inputDecorationTheme`.
            TextField(
              controller: cubit.cancelReasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'سبب الإلغاء (اختياري)',
              ),
            ),
            verticalSpace(AppSpacing.s16),
            ButtonWidget(
              isLoading: false,
              buttonText: 'تأكيد الإلغاء',
              backGroundColor: AppSemanticColors.danger,
              borderColor: AppSemanticColors.danger,
              textStyle: AppTextStyles.button,
              buttonHeight: 52.h,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                cubit.cancelBooking();
              },
            ),
            verticalSpace(AppSpacing.s8),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(
                'رجوع',
                style: AppTextStyles.bodyMdStrong.copyWith(
                  color: AppSemanticColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateSheet(BuildContext context, BookingDetailsCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider<BookingDetailsCubit>.value(
        value: cubit,
        child: BlocBuilder<BookingDetailsCubit, BookingDetailsState>(
          builder: (context, state) => BookingRateSheetWidget(
            rating: cubit.myRating,
            commentController: cubit.rateCommentController,
            isLoading: state is RateLoadingState,
            onRatingChanged: cubit.changeRating,
            onSubmit: cubit.submitRating,
          ),
        ),
      ),
    );
  }
}
