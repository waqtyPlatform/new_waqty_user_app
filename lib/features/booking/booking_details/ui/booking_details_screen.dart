import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// عشان `BookingStatusLabel.isUpcoming` — الـ extension ساكن مع الموديل.
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_actions_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_info_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_in_branch_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_rate_sheet_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_block_widget.dart';
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
            _afterCancel(context, cubit: BookingDetailsCubit.get(context));
          }
          if (state is RateSuccessState) {
            Navigator.of(context).pop();
            // **`AppSnack` مش `SnackBar` مكتوب بالإيد.**
            //
            // اللي كان هنا `textOnAccent` (أبيض) على تعبئة `accent` —
            // **3.96:1**، راسب لنص. جدول README الكيت §٥ بيحط الحالة دي
            // بالاسم. `AppSnack` بيقعد على `surfaceInverse` بـ
            // `textOnInverse`، وبيلغي أي snackbar شغّال قبل ما يعرض.
            AppSnack.show(context, message: 'شكرًا، وصلنا تقييمك');
          }
        },
        builder: (context, state) {
          final cubit = BookingDetailsCubit.get(context);

          if (state is BookingDetailsErrorState) {
            return Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: AppErrorStateWidget(
                message: state.message,
                onRetry: cubit.loadBooking,
              ),
            );
          }

          final booking = cubit.booking;
          if (booking == null) {
            return Center(
              child: AppLoadingWidget(color: AppSemanticColors.accent),
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
              // الـ widget بيخفي نفسه لما الحجز مش في الفرع — والشرط
              // بقى حالة **الزيارة الحالية** مش `isUpcoming`. حجز بكرة
              // **مالوش** حالة فرع، والقديم كان بيبني `BranchQueueCubit`
              // بمؤقت لكل حجز جاي حتى لو معاده الأسبوع الجاي.
              //
              // ⚠ **نفس الدالة اللي جوه الـ widget بالظبط.** لو الاتنين
              // اختلفوا، الشرط ده بيعدّي والـ widget بيرجّع `shrink` —
              // فتفضل مسافة فاضية تحتها من غير أي حاجة فوقها.
              if (shouldShowInBranch(booking, DateTime.now())) ...[
                BookingDetailsInBranchWidget(booking: booking),
                verticalSpace(AppSpacing.s16),
              ],

              BookingDetailsInfoWidget(booking: booking),
              verticalSpace(AppSpacing.s24),
              BookingDetailsActionsWidget(
                booking: booking,
                onCancel: () => _confirmCancel(context, cubit),
                onRate: () => _showRateSheet(context, cubit),
                onRebook: () => _rebook(context, booking),
              ),
            ],
          );
        },
      ),
    );
  }

  /// «احجز تاني» — بيفتح الحجز على **نفس المحل**.
  ///
  /// كان `context.pop()`: زرار اسمه «احجز تاني» بيرجّع العميل لليستة وبس.
  /// و«زي المرة اللي فاتت» هو السلوك الغالب عند الكوافير والباربر، فده
  /// أعلى لحظة نية في الشاشة كلها وكانت بتترمي.
  ///
  /// **الخدمة بتتحدّد مسبقًا** — زي بطاقة الإشعار في «مواعيدي» بالظبط.
  ///
  /// كان مكتوب هنا إن ده مستحيل لأن `serviceUuid` مش موجود على
  /// `BookingItemUiModel`. **هو موجود** وحقل مطلوب من الأصل
  /// (`booking_item_ui_model.dart:51`)، و`my_bookings_screen.dart` كان
  /// بيبعته فعلاً. يعني مكانش فيه قرار تصميم — كان فيه مدخلين لنفس الـ
  /// sheet وواحد بس بينفّذ صح، والعميل بياخد نتيجة أحسن أو أوحش على حسب
  /// دخل منين.
  ///
  /// أول خدمة بس، زي المدخل التاني. حجز بكذا خدمة محتاج `List<String>` على
  /// الـ sheet — والاتساق بين المدخلين أهم من ده دلوقتي.
  Future<void> _rebook(BuildContext context, BookingUiModel booking) async {
    final didBook = await CreateBookingSheet.show(
      context,
      providerUuid: booking.providerUuid,
      providerName: booking.providerName,
      // نفس فرع الحجز القديم — «زي المرة اللي فاتت» معناها نفس المكان
      // كمان، مش أول فرع في القايمة.
      branchUuid: booking.branchUuid,
      serviceUuid: booking.items.first.serviceUuid,
    );

    if (didBook == true && context.mounted) {
      Navigator.of(context).pushNamed(Routes.bookingSuccessScreen);
    }
  }

  /// تأكيد الإلغاء — الإجراء ده مالوش رجعة، فبنسأل.
  ///
  /// **الكيبورد بقى شغل الكيت.** الورقة دي فيها حقل نص، وكانت بتحسب
  /// `viewInsets` بإيدها. `AppSheetWidget` بقى بيعملها لكل ورقة — شوف
  /// `app_sheet_widget.dart`.
  void _confirmCancel(BuildContext context, BookingDetailsCubit cubit) {
    AppSheetWidget.show<bool>(
      context,
      title: 'تلغي الحجز؟',
      message: 'هتلغي حجزك في ${cubit.booking?.providerName ?? ''}',
      // الحشوة والحدود والخلفية كلهم من `inputDecorationTheme`.
      content: TextField(
        controller: cubit.cancelReasonController,
        maxLines: 2,
        decoration: const InputDecoration(hintText: 'سبب الإلغاء (اختياري)'),
      ),
      actions: (sheetContext) => [
        AppButtonWidget(
          label: 'تأكيد الإلغاء',
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        AppButtonWidget(
          label: 'رجوع',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ).then((confirmed) {
      if (confirmed ?? false) cubit.cancelBooking();
    });
  }

  /// **بعد الإلغاء — نتيجة وخطوة جاية، مش سكوت.**
  ///
  /// الفلو القديم كان بيسأل العميل يكتب سبب وبيرد بـ `context.pop()`
  /// وبس. تلات حاجات غلط في السطر ده:
  ///
  /// **١. النتيجة مش مقولة.** «هتتحاسب على حاجة؟» سؤال العميل بيسأله
  /// وهو بيدوس. حتى «الإلغاء مجاني» **معلومة** — السكوت مش.
  ///
  /// **٢. أعلى لحظة نية اتضاعت.** حد لغى ميعاد قصافة معناه غالبًا إنه
  /// عايز ميعاد تاني مش إنه بطّل. ده أحسن وقت تعرض عليه الحجز.
  ///
  /// **٣. الرجوع من غير كلام** بيخلي العميل مش متأكد إن الإلغاء اتنفذ
  /// أصلاً.
  void _afterCancel(
    BuildContext context, {
    required BookingDetailsCubit cubit,
  }) {
    final booking = cubit.booking;

    AppSheetWidget.show<bool>(
      context,
      isDismissible: false,
      icon: Icons.check_circle_outline_rounded,
      iconTone: AppSemanticColors.positive,
      title: 'اتلغى الحجز',
      // TODO(api): سياسة الإلغاء من إعدادات الفرع — دلوقتي ثابتة.
      message: 'الإلغاء مجاني ومفيش أي رسوم عليك',
      actions: (sheetContext) => [
        AppButtonWidget(
          label: 'تحب تحجز ميعاد تاني؟',
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        AppButtonWidget(
          label: 'مش دلوقتي',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ).then((wantsRebook) {
      if (!context.mounted) return;
      // `isDismissible: false` يعني مافيش خروج من غير اختيار — والـ`null`
      // هنا احتياط لو حد شال المنع بكرة.
      if (wantsRebook == null) return;
      if (wantsRebook) {
        if (booking != null) _rebook(context, booking);
      } else {
        context.pop();
      }
    });
  }

  /// **خدمة واحدة بس بتتقيّم في المرة.**
  ///
  /// خدمة واحدة لسه؟ بنفتح التقييم على طول. أكتر من واحدة؟ بنسأل الأول
  /// على أنهي خدمة — لأن التقييم بيروح لـ `booking_item_id` بعينه، وشيت
  /// من غير سؤال كان هيخلي العميل يقيّم واحدة ويفتكر إنه قيّم الحجز كله.
  void _showRateSheet(BuildContext context, BookingDetailsCubit cubit) {
    final items = cubit.booking?.rateableItems ?? const <BookingItemUiModel>[];
    if (items.isEmpty) return;

    if (items.length == 1) {
      cubit.startRating(items.first);
      _openRateSheet(context, cubit);
      return;
    }

    // الورقة بترجّع الخدمة المختارة، والشاشة هي اللي بتفتح التقييم —
    // فورقة التقييم مابتتفتحش وورقة الاختيار لسه في الشجرة.
    //
    // الصفوف بقت [AppMenuRowWidget]: عنوان + «مع فلان» + سهم اتجاهي.
    // نفس اللي `ListTile` كان بيعمله، بس بحشوة من سلّم المسافات وسهم
    // بيتقلب صح لوحده (`chevron_left` المكتوبة بالإيد كانت بتشاور **يمين**
    // في العربي، يعني «ارجع» في صف معناه «كمّل»).
    AppSheetWidget.show<BookingItemUiModel>(
      context,
      title: 'تقيّم أنهي خدمة؟',
      message: 'كل خدمة ليها تقييمها لوحدها',
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              AppMenuRowWidget(
                title: item.serviceName,
                subtitle: 'مع ${item.employeeName}',
                onTap: () => Navigator.of(sheetContext).pop(item),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    ).then((item) {
      if (item == null || !context.mounted) return;
      cubit.startRating(item);
      _openRateSheet(context, cubit);
    });
  }

  void _openRateSheet(BuildContext context, BookingDetailsCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider<BookingDetailsCubit>.value(
        value: cubit,
        child: BlocBuilder<BookingDetailsCubit, BookingDetailsState>(
          builder: (context, state) => BookingRateSheetWidget(
            serviceName: cubit.ratingItem?.serviceName ?? '',
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
