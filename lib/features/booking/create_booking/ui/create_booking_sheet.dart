import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_date_strip_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_footer_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_slots_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_staff_row_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_stepper_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_summary_widget.dart';

/// الحجز — sheet فوق صفحة المحل، مش wizard بخمس شاشات.
///
/// ليه sheet: الـ wizard بيحوّل مهمة ٣٠ ثانية لاستمارة، وكل رجوع بيفك
/// stack. والصفحة الطويلة بتتهزّ تحت صباع العميل كل ما اختيار يتحمّل.
/// الـ sheet بيسيب المحل باين ورا العتمة، فسؤال «أنا لسه في المحل الصح؟»
/// مجاوب طول الوقت من غير أي شغل زيادة.
class CreateBookingSheet extends StatelessWidget {
  const CreateBookingSheet({super.key});

  /// بيفتح الـ sheet فوق الصفحة اللي العميل واقف فيها.
  static Future<bool?> show(
    BuildContext context, {
    required String providerUuid,
    required String providerName,
    String? serviceUuid,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CreateBookingCubit(
          providerUuid: providerUuid,
          providerName: providerName,
          initialServiceUuid: serviceUuid,
        )..loadDateTimeStep(),
        child: const CreateBookingSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        // الـ sheet ده بيبني الحاوية بتاعته لأن `DraggableScrollableSheet`
        // جوه modal شفاف — فمش بياخد حاجة من `bottomSheetTheme`. الاستدارة
        // والظل مكتوبين هنا بالتوكنات عشان يفضلوا متسقين مع الباقي.
        return Container(
          decoration: BoxDecoration(
            color: AppSemanticColors.surfaceRaised,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl.r),
            ),
            boxShadow: AppShadows.floatingUp,
          ),
          clipBehavior: Clip.hardEdge,
          child: BlocConsumer<CreateBookingCubit, CreateBookingState>(
            listener: (context, state) {
              if (state is CreateBookingSuccessState) {
                Navigator.of(context).pop(true);
              }
              if (state is SlotTakenState) {
                // شكل الـ SnackBar جاي من `snackBarTheme` — كان مصمّم
                // بالإيد في موضعين بشكلين مختلفين.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'الموعد ده اتحجز من شوية — اخترنالك أقرب بديل',
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = CreateBookingCubit.get(context);

              return Column(
                children: [
                  const CreateBookingGrabberWidget(),
                  CreateBookingStepperWidget(currentStep: cubit.currentStep),
                  verticalSpace(AppSpacing.headerToContent),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.pageGutter.w,
                      ),
                      child: _stepBody(context, cubit, state),
                    ),
                  ),
                  _footer(context, cubit, state),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _stepBody(
    BuildContext context,
    CreateBookingCubit cubit,
    CreateBookingState state,
  ) {
    if (state is CreateBookingErrorState) {
      return ErrorStateWidget(message: state.message, onRetry: cubit.loadDates);
    }

    return switch (cubit.currentStep) {
      BookingStep.service => _serviceStep(cubit),
      BookingStep.dateTime => _dateTimeStep(cubit, state),
      BookingStep.confirm => CreateBookingSummaryWidget(cubit: cubit),
    };
  }

  Widget _serviceStep(CreateBookingCubit cubit) {
    final bookableServices = cubit.services
        .where((s) => !s.isCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر الخدمة', style: AppTextStyles.sectionHeader),
        verticalSpace(AppSpacing.headerToContent),
        ...bookableServices.map((service) {
          final isSelected = cubit.selectedService?.uuid == service.uuid;
          return Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.chipGap.h),
            child: AppSurfaceWidget(
              onTap: () => cubit.selectService(service),
              radius: AppRadius.m,
              height: 64.h,
              color: isSelected ? AppSemanticColors.accentSoft : null,
              // **الحالة المختارة هي واحدة من تلات حالات بس بتاخد حد.**
              // الحد هنا معناه دلالي («ده اختيارك») مش فصل بصري.
              border: isSelected
                  ? Border.all(color: AppSemanticColors.accent, width: 1.5)
                  : null,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMdStrong,
                        ),
                        verticalSpace(AppSpacing.titleToSubtitle),
                        Text(
                          AppFormat.duration(service.durationMinutes),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace(AppSpacing.s8),
                  Text(
                    AppFormat.money(service.price),
                    style: AppTextStyles.bodyMdStrong,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _dateTimeStep(CreateBookingCubit cubit, CreateBookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateBookingStaffRowWidget(
          employees: cubit.employees,
          selectedEmployee: cubit.selectedEmployee,
          onEmployeeSelected: cubit.selectEmployee,
        ),
        verticalSpace(AppSpacing.s24),
        CreateBookingDateStripWidget(
          availableDates: cubit.availableDates,
          selectedDate: cubit.selectedDate,
          currentMonth: cubit.currentMonth,
          canGoToPreviousMonth: cubit.canGoToPreviousMonth,
          onDateTap: cubit.selectDate,
          onMonthChange: cubit.changeMonth,
        ),
        // ٢٤ في المكانين — كانوا ١٦ و٢٠، نفس العلاقة بقيمتين.
        verticalSpace(AppSpacing.s24),
        CreateBookingSlotsWidget(
          slots: cubit.slots,
          selectedSlot: cubit.selectedSlot,
          takenSlot: cubit.takenSlot,
          isLoading: state is LoadingSlotsState || state is LoadingDatesState,
          baselinePrice: cubit.selectedService?.price ?? 0,
          onSlotTap: cubit.selectSlot,
        ),
        // سطر الالتزام — العميل بيدي ٤٥ دقيقة من وقته، مش نقطة في الزمن.
        // بيتلاشى داخل بدل ما يظهر فجأة ويزحلق الفوتر.
        AnimatedSize(
          duration: AppMotion.base,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: cubit.selectedSlot == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.s12.h),
                  child: AppSurfaceWidget(
                    level: AppElevation.sunken,
                    radius: AppRadius.m,
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.cardPadding.r),
                    child: Text(
                      '${AppFormat.timeRange(cubit.selectedSlot!.startAt, cubit.selectedSlot!.endAt)} · '
                      '${AppFormat.duration(cubit.selectedSlot!.durationMinutes)}'
                      '${cubit.selectedEmployee.isAnyAvailable ? ' · مع ${cubit.selectedSlot!.employeeName}' : ''}',
                      style: AppTextStyles.bodyMdStrong,
                    ),
                  ),
                ),
        ),
        verticalSpace(AppSpacing.s16),
      ],
    );
  }

  Widget _footer(
    BuildContext context,
    CreateBookingCubit cubit,
    CreateBookingState state,
  ) {
    final isConfirm = cubit.currentStep == BookingStep.confirm;

    return CreateBookingFooterWidget(
      price: cubit.selectedSlot?.price ?? cubit.selectedService?.price,
      durationMinutes: cubit.selectedSlot?.durationMinutes,
      buttonLabel: isConfirm ? 'تأكيد الحجز' : 'التالي',
      isEnabled: cubit.canGoNext,
      isLoading: state is CreateBookingLoadingState,
      onPressed: isConfirm ? cubit.confirmBooking : cubit.nextStep,
    );
  }
}
