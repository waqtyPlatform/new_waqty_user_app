import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/repo/create_booking_repo.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_date_strip_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_slots_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_state.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';

/// **شيت حجز المتابعة** — تاريخ وميعاد وتأكيد.
///
/// ## ليه شيت مش ويزارد
///
/// ويزارد الحجز العادي بيسأل ٥ أسئلة: فرع · خدمة · أخصائي · تاريخ · ميعاد.
/// المتابعة **٣ منهم محسومين** من الاستحقاق نفسه — الخدمة معروفة، والفرع
/// جاي من الحجز الأصلي، والأخصائي إما مقفول بالقاعدة أو مفتوح للسيرفر.
/// فاللي فاضل سؤالين، ودول شيت مش رحلة.
class EntitlementBookingSheet extends StatelessWidget {
  const EntitlementBookingSheet({required this.followUp, super.key});

  final FollowUpEntitlementUiModel followUp;

  /// بيفتح الشيت وبيربطه بالـ[EntitlementsCubit] اللي فوق التبويبات.
  ///
  /// الـcubit بيتمرّر بـ`.value` مش بيتعمل جديد — الحجز بيغيّر الاستحقاق،
  /// ولازم نفس النسخة اللي القايمة والعدّاد بيقروا منها هي اللي تتحدّث.
  ///
  /// ⚠ **الزرار جوه [AppSheetWidget.content] مش في `actions`.** الـ`actions`
  /// بتتبني بره شجرة الـproviders، فزرار محتاج الكيوبتين ماينفعش يعيش
  /// هناك. و`content` بيوصل للاتنين.
  /// بترجّع `true` لو الحجز اتسجّل — واللي بينده بيوري التأكيد.
  static Future<bool> show(
    BuildContext context, {
    required EntitlementsCubit cubit,
    required FollowUpEntitlementUiModel followUp,
  }) async {
    final booked = await AppSheetWidget.show<bool>(
      context,
      title: 'احجز المتابعة',
      content: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<EntitlementsCubit>.value(value: cubit),
          BlocProvider<EntitlementBookingCubit>(
            create: (_) => EntitlementBookingCubit(
              followUp: followUp,
              bookings: getIt<BookingDetailsRepo>(),
              booking: getIt<CreateBookingRepo>(),
            )..start(),
          ),
        ],
        child: EntitlementBookingSheet(followUp: followUp),
      ),
      actions: (_) => const <Widget>[],
    );

    return booked ?? false;
  }

  /// **تأكيد بعد الحجز — بيقول اللي حصل ومكانه.**
  ///
  /// ## ليه مابنودّيهاش على الحجز الجديد على طول
  ///
  /// `bookFollowUp` بيرجّع `Booking` **خام** مش `UserBookingResource`
  /// (BE-A2)، يعني أسماء الحقول بتاعت Eloquent وماينفعش نعتمد على قراية
  /// `uuid` منه للتنقّل. الورقة دي هي البديل الصادق: بتقول الحجز اتسجّل
  /// وبتقول يلاقيه فين، من غير ما تدّعي إننا عارفين رقمه.
  ///
  /// TODO(api): BE-A2 — لما يرجّع مورد، ده يبقى تنقّل مباشر للتفاصيل.
  static Future<void> showConfirmation(BuildContext context) {
    return AppSheetWidget.show<void>(
      context,
      icon: Icons.check_circle_outline_rounded,
      iconTone: AppSemanticColors.positive,
      title: 'الحجز اتسجّل',
      message: 'هتلاقي ميعاد المتابعة في «حجوزاتي».',
      actions: (sheetContext) => <Widget>[
        AppButtonWidget(
          label: 'تمام',
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntitlementsCubit, EntitlementsState>(
      listener: (context, state) {
        // النجاح بيقفل الشيت. الشاشة اللي نادت هي اللي بتودّي «حجوزاتي».
        if (state is EntitlementBookingSucceeded) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, entitlementsState) {
        final isSubmitting = entitlementsState is EntitlementBookingSubmitting;

        return BlocBuilder<EntitlementBookingCubit, EntitlementBookingState>(
          builder: (context, state) {
            final cubit = EntitlementBookingCubit.get(context);

            if (state is EntitlementBookingError) {
              return AppErrorStateWidget(
                message: state.message,
                onRetry: cubit.start,
              );
            }

            if (state is EntitlementBookingResolving) {
              return Padding(
                padding: EdgeInsets.all(AppSpacing.s32.r),
                child: Center(
                  child: AppLoadingWidget(color: AppSemanticColors.accent),
                ),
              );
            }

            // **الشيت بيتقيّد بنص الشاشة وبيسكرول جواه.**
            //
            // شريط التواريخ + شبكة المواعيد أطول من نص الشاشة على ٣٦٠×٦٤٠،
            // ومن غير القيد ده الشيت بيفيض ويقص زرار التأكيد.
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.62,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (followUp.employeeRule ==
                            FollowUpEmployeeRule.sameRequired &&
                        followUp.employee != null) ...<Widget>[
                      // **مفيش picker — القاعدة مقفولة والسبب مكتوب.**
                      Text(
                        'المتابعة مع ${followUp.employee!.name}',
                        style: AppTextStyles.bodyMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(AppSpacing.s12),
                    ],

                    if (state is EntitlementBookingLoadingDates)
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.s24.r),
                        child: Center(
                          child: AppLoadingWidget(
                            color: AppSemanticColors.accent,
                          ),
                        ),
                      )
                    else
                      CreateBookingDateStripWidget(
                        availableDates: cubit.availableDates,
                        selectedDate: cubit.selectedDate,
                        currentMonth: cubit.currentMonth,
                        canGoToPreviousMonth: cubit.currentMonth.isAfter(
                          DateTime(DateTime.now().year, DateTime.now().month),
                        ),
                        onDateTap: cubit.selectDate,
                        onMonthChange: cubit.changeMonth,
                      ),

                    if (cubit.selectedDate != null) ...<Widget>[
                      verticalSpace(AppSpacing.s16),
                      CreateBookingSlotsWidget(
                        slots: cubit.slots,
                        selectedSlot: cubit.selectedSlot,
                        baselinePrice: followUp.effectivePrice.toDouble(),
                        isLoading: state is EntitlementBookingLoadingSlots,
                        onSlotTap: cubit.selectSlot,
                      ),
                    ],

                    // **الفشل بيتعرض جوه الشيت فوق زرار التأكيد.**
                    //
                    // قفل الشيت وعرض toast بيضيّع اختيار التاريخ والميعاد —
                    // والعميلة بتبدأ من الأول عشان السيرفر قال «الميعاد
                    // اتحجز توّه».
                    if (entitlementsState
                        is EntitlementBookingFailed) ...<Widget>[
                      verticalSpace(AppSpacing.s12),
                      AppBannerWidget(
                        message: entitlementsState.message,
                        tone: AppPillTone.danger,
                        icon: Icons.error_outline_rounded,
                      ),
                    ],

                    verticalSpace(AppSpacing.s24),
                    AppButtonWidget(
                      label: 'أكّد الحجز',
                      isLoading: isSubmitting,
                      onPressed: cubit.canConfirm && !isSubmitting
                          ? () => EntitlementsCubit.get(context).bookFollowUp(
                              uuid: followUp.uuid,
                              bookingDate: cubit.bookingDate,
                              startTime: cubit.startTime,
                              employeeUuid: cubit.employeeUuid,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
