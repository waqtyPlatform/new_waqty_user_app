import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_footer_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_item_card_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_service_picker_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_header_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_summary_widget.dart';

/// الحجز — sheet فوق صفحة المحل، مش wizard بخمس شاشات.
///
/// ليه sheet: الـ wizard بيحوّل مهمة ٣٠ ثانية لاستمارة، وكل رجوع بيفك
/// stack. والصفحة الطويلة بتتهزّ تحت صباع العميل كل ما اختيار يتحمّل.
/// الـ sheet بيسيب المحل باين ورا العتمة، فسؤال «أنا لسه في المحل الصح؟»
/// مجاوب طول الوقت من غير أي شغل زيادة.
///
/// ## سلة خدمات، والشكل زي ما هو
///
/// الحجز بقى بياخد أكتر من خدمة وأكتر من زيارة — نفس قدرة داشبورد
/// المزود بالظبط. اللي **ماتنقلش** هو شكل الداشبورد: هو استمارة من عمود
/// واحد بكروت بتتكرر، على شاشة عريضة بشريط جانبي ثابت. نفس الشكل على
/// ٣٧٥ بكسل بيبقى سكرول مالوش قاع. فالقدرة اتنقلت والشكل فضل: خطوة
/// الخدمة بقت اختيار متعدد، وخطوة الميعاد بقت أكورديون كارت واحد مفتوح
/// في المرة.
class CreateBookingSheet extends StatelessWidget {
  const CreateBookingSheet({super.key});

  /// بيفتح الـ sheet فوق الصفحة اللي العميل واقف فيها.
  ///
  /// [branch] هو الفرع اللي العميل مختاره في شاشة المحل. لو اتساب فاضي
  /// بيقع على أول فرع — وده اللي كان بيحصل دايمًا وبيضيّع اختياره.
  static Future<bool?> show(
    BuildContext context, {
    required String providerUuid,
    required String providerName,
    String? serviceUuid,
    BranchUiModel? branch,
    String? branchUuid,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // **السحب لتحت والضغط على العتمة مقفولين** — الخروج من الزرار بس.
      //
      // الـ sheet ده بيشيل من تلات لخمس دقايق شغل في حالة متطايرة: خدمات
      // وأخصائيين ومواعيد وملاحظات، كلهم على `CreateBookingCubit` اللي
      // بيتعمل جوه الـ builder. سحبة واحدة لتحت على ليستة مسحوبة لفوق
      // كانت بترجّع `null` وتفضّي السلة **في صمت**.
      //
      // الشكل نفسه كان بيكدب: الـ sheet بيقول «حاجة صغيرة تتلغي بسهولة»
      // والمحتوى بيقول العكس.
      isDismissible: false,
      enableDrag: false,
      builder: (_) => BlocProvider(
        create: (_) => CreateBookingCubit(
          providerUuid: providerUuid,
          providerName: providerName,
          initialServiceUuid: serviceUuid,
          initialBranch: branch,
          initialBranchUuid: branchUuid,
        )..enterDateTimeStep(),
        child: const CreateBookingSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _guarded(
      context,
      child: DraggableScrollableSheet(
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
                top: Radius.circular(AppRadius.l.r),
              ),
              boxShadow: AppShadows.floatingUp,
            ),
            clipBehavior: Clip.hardEdge,
            child: BlocConsumer<CreateBookingCubit, CreateBookingState>(
              listener: (context, state) {
                if (state is CreateBookingSuccessState) {
                  Navigator.of(context).pop(true);
                }
                if (state is JoinedWaitlistState) {
                  // الرد لازم يقول **إيه اللي هيحصل بعد كده** — «تمام»
                  // لوحدها بتسيب العميل مستني حاجة مش عارف شكلها.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'ضفناك لقائمة انتظار «${state.serviceName}» — '
                        'هتلاقيها في مواعيدك',
                      ),
                    ),
                  );
                }
                if (state is SlotTakenState) {
                  // شكل الـ SnackBar جاي من `snackBarTheme` — كان مصمّم
                  // بالإيد في موضعين بشكلين مختلفين.
                  //
                  // وأسماء الخدمات في النص مقصودة: في حجز بتلات خدمات، «الموعد
                  // اتحجز» لوحدها بتسيب العميل يدوّر على أنهي واحدة فيهم.
                  // وبنعدّهم كلهم لو أكتر من واحد راح مع بعض.
                  final names = state.serviceNames
                      .map((n) => '«$n»')
                      .join(' و');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.serviceNames.length == 1
                            ? 'ميعاد $names اتحجز من شوية — اختار بديل'
                            : 'مواعيد $names اتحجزوا من شوية — اختار بدائل',
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
                    CreateBookingHeaderWidget(
                      currentStep: cubit.currentStep,
                      scheduledCount: cubit.items
                          .where((i) => i.isScheduled)
                          .length,
                      totalCount: cubit.items.length,
                      // أول خطوة مالهاش رجوع — الخروج من الـ sheet هو
                      // الرجوع، والحارس تحت بيحميه.
                      onBack: cubit.currentStep == BookingStep.service
                          ? null
                          : cubit.previousStep,
                    ),
                    CreateBookingBranchChipWidget(
                      branch: cubit.selectedBranch,
                      onChangeBranch: cubit.branches.length > 1
                          ? () => _showBranchSheet(context, cubit)
                          : null,
                    ),
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
      ),
    );
  }

  /// حارس الخروج — **بيسأل قبل ما يرمي شغل**.
  ///
  /// زرار الرجوع بتاع النظام (وإيماءة الرجوع في أندرويد) بيقفلوا الـ
  /// sheet ويرجّعوا `null`. مع سلة فيها خدمات، ده بيمسح كل حاجة من غير
  /// ما حد يسأل. `PopScope` بيوقف الخروج ويسأل الأول.
  ///
  /// **مفيش حارس والسلة فاضية** — سؤال «متأكد؟» على لا شيء بيعلّم العميل
  /// إنه يدوس «أيوة» من غير ما يقرا، وبعدين السؤال الحقيقي مابيتقراش.
  Widget _guarded(BuildContext context, {required Widget child}) {
    return BlocBuilder<CreateBookingCubit, CreateBookingState>(
      builder: (context, _) {
        final cubit = CreateBookingCubit.get(context);
        final hasWork = cubit.items.isNotEmpty;

        return PopScope(
          canPop: !hasWork,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || !context.mounted) return;
            final leave = await _confirmDiscard(context);
            if (leave == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: child,
        );
      },
    );
  }

  Future<bool?> _confirmDiscard(BuildContext context) {
    // **الزراير فوق بعض مش جنب بعض.**
    //
    // `AlertDialog.actions` بيحط الزرارين في صف — وعند مقياس خط ١٫٣
    // «أكمّل» و«اسيبه» بيتزنقوا. `AppDialogWidget` بيرصّهم عمودي بعرض
    // كامل، والأساسي فوق.
    return AppDialogWidget.show<bool>(
      context,
      icon: Icons.delete_outline_rounded,
      iconTone: AppSemanticColors.danger,
      title: 'تسيب الحجز؟',
      message: 'الخدمات والمواعيد اللي اخترتها هتتمسح',
      actions: (dialogContext) => [
        AppButtonWidget(
          label: 'اسيبه',
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
        AppButtonWidget(
          label: 'أكمّل',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
      ],
    );
  }

  /// تغيير الفرع من جوه الحجز.
  ///
  /// **بيحذّر لأن التغيير بيمسح شغل.** الأخصائيين والمواعيد والأسعار كلهم
  /// متعلقين بالفرع، فـ `selectBranch` بيصفّي جدولة كل الخدمات. لو غيّرنا
  /// من غير سؤال، العميل بيرجع يلاقي سلته فاضية من المواعيد ومش عارف ليه.
  void _showBranchSheet(BuildContext context, CreateBookingCubit cubit) {
    AppSheetWidget.show<BranchUiModel>(
      context,
      title: 'تحجز في أنهي فرع؟',
      message: cubit.items.any((i) => i.isScheduled)
          ? 'تغيير الفرع هيمسح المواعيد اللي اخترتها — الأخصائيين '
                'والمواعيد بيختلفوا من فرع للتاني'
          : 'الأخصائيين والمواعيد والأسعار بيختلفوا من فرع للتاني',
      // راديو مش علامة صح: ده اختيار واحد من عدة، والصح بيقول «ده اتعمل».
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final branch in cubit.branches)
              AppChoiceRowWidget(
                title: branch.name,
                subtitle: branch.address,
                selected: branch.uuid == cubit.selectedBranch?.uuid,
                style: AppChoiceStyle.radio,
                onTap: () => Navigator.of(sheetContext).pop(branch),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    ).then((branch) {
      // `selectBranch` بيتكفّل بإعادة التحميل بنفسه — الشاشة مابتعرفش
      // إن الكارت المفتوح محتاج يتحدّث.
      if (branch != null) cubit.selectBranch(branch);
    });
  }

  Widget _stepBody(
    BuildContext context,
    CreateBookingCubit cubit,
    CreateBookingState state,
  ) {
    if (state is CreateBookingErrorState) {
      return AppErrorStateWidget(
        message: state.message,
        onRetry: () => _retry(cubit),
      );
    }

    return switch (cubit.currentStep) {
      BookingStep.service => CreateBookingServicePickerWidget(
        services: cubit.services,
        isSelected: cubit.isServiceSelected,
        onToggle: cubit.toggleService,
      ),
      BookingStep.dateTime => _dateTimeStep(cubit, state),
      BookingStep.confirm => CreateBookingSummaryWidget(cubit: cubit),
    };
  }

  /// إعادة المحاولة بتخص **الكارت المفتوح** — مش الفلو كله.
  void _retry(CreateBookingCubit cubit) {
    for (final item in cubit.items) {
      if (item.isExpanded) {
        cubit.loadDatesFor(item.key);
        return;
      }
    }
    cubit.enterDateTimeStep();
  }

  Widget _dateTimeStep(CreateBookingCubit cubit, CreateBookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List<Widget>.generate(cubit.items.length, (i) {
          final item = cubit.items[i];
          return CreateBookingItemCardWidget(
            // الـ key من هوية العنصر مش من ترتيبه — من غيره شيل خدمة من
            // النص بيخلي Flutter يعيد استخدام الـ state في الكارت الغلط.
            key: ValueKey(item.key),
            item: item,
            index: i,
            isLoadingSlots: _isLoading(state, item),
            canGoToPreviousMonth: cubit.canGoToPreviousMonth(item),
            onExpand: () => cubit.expandItem(item.key),
            onEmployeeSelected: (employee) =>
                cubit.selectEmployee(item.key, employee),
            onDateTap: (date) => cubit.selectDate(item.key, date),
            onMonthChange: (offset) => cubit.changeMonth(item.key, offset),
            onSlotTap: (slot) => cubit.selectSlot(item.key, slot),
            onRemove: cubit.items.length > 1
                ? () => cubit.removeItem(item.key)
                : null,
            onPickAnotherService: () => cubit.goToStep(BookingStep.service),
            onJoinWaitlist: () => cubit.joinWaitlist(item.key),
            onPeriodToggle: (period) => cubit.togglePeriod(item.key, period),
            onBrowseAll: () => cubit.toggleBrowseAll(item.key),
          );
        }),

        // الرجوع لخطوة الخدمات — بغرض واضح مش سهم رجوع عام.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => cubit.goToStep(BookingStep.service),
            icon: Icon(Icons.add_rounded, size: 20.r),
            label: Text('ضيف خدمة تانية', style: AppTextStyles.label),
          ),
        ),

        if (cubit.items.length > 1) _visitsHint(cubit),
        verticalSpace(AppSpacing.s16),
      ],
    );
  }

  /// تلميح بيظهر أول ما الخدمات تتوزّع على أكتر من رحلة.
  ///
  /// **مش «أيام»** — ممكن يكونوا رحلتين في نفس اليوم (صبغة الصبح وحمام
  /// كريم بالليل). من غير التلميح ده العميل بيكتشف إنه رايح المحل مرتين
  /// في شاشة التأكيد بس، ودي متأخرة.
  Widget _visitsHint(CreateBookingCubit cubit) {
    final count = cubit.visits.length;
    if (count < 2) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsetsDirectional.only(top: AppSpacing.s8.h),
      child: Row(
        children: [
          Icon(
            Icons.event_repeat_rounded,
            size: 16.r,
            color: AppSemanticColors.textTertiary,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(
            child: Text(
              'ده ${AppFormat.digits(count)} رحلات للمحل — تقدر تعدّلها في التأكيد',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  /// الكارت ده بالذات هو اللي بيحمّل؟
  bool _isLoading(CreateBookingState state, BookingDraftItem item) {
    if (state is LoadingSlotsState) return state.itemKey == item.key;
    if (state is LoadingDatesState) return state.itemKey == item.key;
    return false;
  }

  Widget _footer(
    BuildContext context,
    CreateBookingCubit cubit,
    CreateBookingState state,
  ) {
    final isConfirm = cubit.currentStep == BookingStep.confirm;

    return CreateBookingFooterWidget(
      price: cubit.items.isEmpty ? null : cubit.totalPrice,
      metaLabel: _metaLabel(cubit),
      buttonLabel: isConfirm ? 'تأكيد الحجز' : 'التالي',
      isEnabled: cubit.canGoNext,
      isLoading: state is CreateBookingLoadingState,
      onPressed: isConfirm ? cubit.confirmBooking : cubit.nextStep,
    );
  }

  /// «٤٥ دقيقة» لخدمة واحدة · «٣ خدمات · ١ س ٣٠ د» للسلة.
  String? _metaLabel(CreateBookingCubit cubit) {
    if (cubit.items.isEmpty) return null;

    final duration = AppFormat.duration(cubit.totalDuration);
    if (cubit.items.length == 1) return duration;

    return '${AppFormat.digits(cubit.items.length)} خدمات · $duration';
  }
}
