import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
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
  const EntitlementBookingSheet({this.lockedEmployeeName, super.key});

  /// اسم الأخصائي لما القاعدة بتلزمه — بيتعرض كسطر ثابت من غير picker.
  final String? lockedEmployeeName;

  /// بيفتح الشيت وبيربطه بالـ[EntitlementsCubit] اللي فوق التبويبات.
  ///
  /// الـcubit بيتمرّر بـ`.value` مش بيتعمل جديد — الحجز بيغيّر الاستحقاق،
  /// ولازم نفس النسخة اللي القايمة والعدّاد بيقروا منها هي اللي تتحدّث.
  ///
  /// ⚠ **الزرار جوه [AppSheetWidget.content] مش في `actions`.** الـ`actions`
  /// بتتبني بره شجرة الـproviders، فزرار محتاج الكيوبتين ماينفعش يعيش
  /// هناك. و`content` بيوصل للاتنين.
  /// حجز جلسة من **باقة**.
  ///
  /// اتفتح مع BE-A1: قبله الرد مكانش فيه فرع، فمكانش فيه مواعيد نعرضها،
  /// فالزرار كان متعطّل بسبب مكتوب.
  static Future<bool> showForPackage(
    BuildContext context, {
    required EntitlementsCubit cubit,
    required PackageEntitlementUiModel package,
  }) => _show(
    context,
    cubit: cubit,
    title: 'احجز جلسة',
    createBooking: () =>
        EntitlementBookingCubit.forPackage(
          package: package,
          booking: getIt<CreateBookingRepo>(),
        )..start(),
    onConfirm: (entitlements, booking) => entitlements.bookPackageSession(
      uuid: booking.entitlementUuid,
      bookingDate: booking.bookingDate,
      startTime: booking.startTime,
      serviceUuid: booking.selectedServiceUuid,
    ),
  );

  /// حجز **متابعة**.
  static Future<bool> showForFollowUp(
    BuildContext context, {
    required EntitlementsCubit cubit,
    required FollowUpEntitlementUiModel followUp,
  }) => _show(
    context,
    cubit: cubit,
    title: 'احجز المتابعة',
    lockedEmployeeName:
        followUp.employeeRule == FollowUpEmployeeRule.sameRequired
        ? followUp.employee?.name
        : null,
    createBooking: () =>
        EntitlementBookingCubit.forFollowUp(
          followUp: followUp,
          booking: getIt<CreateBookingRepo>(),
        )..start(),
    onConfirm: (entitlements, booking) => entitlements.bookFollowUp(
      uuid: booking.entitlementUuid,
      bookingDate: booking.bookingDate,
      startTime: booking.startTime,
      employeeUuid: booking.lockedEmployeeUuid,
    ),
  );

  /// بترجّع `true` لو الحجز اتسجّل — واللي بينده بيوري التأكيد.
  static Future<bool> _show(
    BuildContext context, {
    required EntitlementsCubit cubit,
    required String title,
    required EntitlementBookingCubit Function() createBooking,
    required void Function(
      EntitlementsCubit entitlements,
      EntitlementBookingCubit booking,
    )
    onConfirm,
    String? lockedEmployeeName,
  }) async {
    final booked = await AppSheetWidget.show<bool>(
      context,
      title: title,
      content: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<EntitlementsCubit>.value(value: cubit),
          BlocProvider<EntitlementBookingCubit>(create: (_) => createBooking()),
        ],
        child: _SheetScope(
          onConfirm: onConfirm,
          child: EntitlementBookingSheet(
            lockedEmployeeName: lockedEmployeeName,
          ),
        ),
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
  static Future<void> showConfirmation(
    BuildContext context, {
    EntitlementBookingKind kind = EntitlementBookingKind.followUp,
  }) {
    return AppSheetWidget.show<void>(
      context,
      icon: Icons.check_circle_outline_rounded,
      iconTone: AppSemanticColors.positive,
      title: 'الحجز اتسجّل',
      // ⚠ النص بيتغيّر بالنوع. كان مكتوب «ميعاد المتابعة» ثابت، فحجز
      // جلسة باقة كان بيقول للعميلة إنها حجزت متابعة.
      message: switch (kind) {
        EntitlementBookingKind.package =>
          'هتلاقي ميعاد الجلسة في «حجوزاتي».',
        EntitlementBookingKind.followUp =>
          'هتلاقي ميعاد المتابعة في «حجوزاتي».',
      },
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
                    if (lockedEmployeeName != null) ...<Widget>[
                      // **مفيش picker — القاعدة مقفولة والسبب مكتوب.**
                      Text(
                        'المتابعة مع $lockedEmployeeName',
                        style: AppTextStyles.bodyMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(AppSpacing.s12),
                    ],

                    if (state is EntitlementBookingLoadingDates ||
                        state is EntitlementBookingResolving)
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
                        // ⚠ الاستحقاق **مدفوع أصلاً**، فمفيش سعر مرجعي.
                        // من غير `showPriceDelta: false` كل ميعاد ليه سعر
                        // كان بيبان كأنه «+٥٠» زيادة — العميلة اللي دفعت
                        // باقة تفتكر إن فيه فلوس تانية عليها.
                        baselinePrice: 0,
                        showPriceDelta: false,
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
                          ? () => _SheetScope.of(context).onConfirm(
                              EntitlementsCubit.get(context),
                              cubit,
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


/// بيمرّر دالة التأكيد لجوه الشجرة.
///
/// الزرار عايش جوه `content` (عشان يوصل للكيوبتين)، والدالة اللي بتقرر
/// أنهي endpoint بتتحدد بره في [EntitlementBookingSheet.showForPackage]
/// أو [EntitlementBookingSheet.showForFollowUp]. `InheritedWidget` أبسط
/// من تمرير الدالة عبر أربع طبقات builders.
class _SheetScope extends InheritedWidget {
  const _SheetScope({required this.onConfirm, required super.child});

  final void Function(
    EntitlementsCubit entitlements,
    EntitlementBookingCubit booking,
  )
  onConfirm;

  static _SheetScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheetScope>()!;

  @override
  bool updateShouldNotify(_SheetScope oldWidget) =>
      oldWidget.onConfirm != onConfirm;
}
