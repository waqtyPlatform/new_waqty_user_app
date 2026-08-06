import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// عشان `BookingStatusLabel.isUpcoming` — الـ extension ساكن مع الموديل.
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/core/widgets/loading_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_actions_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_info_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_in_branch_widget.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_rate_sheet_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
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
            return Center(
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
              // الـ widget بيخفي نفسه لما الحجز مش في الفرع — والشرط
              // بقى `isInBranch` مش `isUpcoming`. حجز بكرة **مالوش**
              // حالة فرع، والقديم كان بيبني `BranchQueueCubit` بمؤقت
              // لكل حجز جاي حتى لو معاده الأسبوع الجاي.
              if (booking.status.isInBranch) ...[
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
  /// **الخدمة لسه مش متحدّدة مسبقًا.** ده محتاج `serviceUuid` على
  /// `BookingItemUiModel` وهو مش موجود — بيتضاف مع شغل التقييم لكل خدمة
  /// (البند 1.4) لأنه لازم ليه برضه. لحد ساعتها العميل بيقع على مختار
  /// الخدمات بتاع المحل الصح، وده أحسن من الرجوع لليستة.
  Future<void> _rebook(BuildContext context, BookingUiModel booking) async {
    final didBook = await CreateBookingSheet.show(
      context,
      providerUuid: booking.providerUuid,
      providerName: booking.providerName,
      // نفس فرع الحجز القديم — «زي المرة اللي فاتت» معناها نفس المكان
      // كمان، مش أول فرع في القايمة.
      branchUuid: booking.branchUuid,
    );

    if (didBook == true && context.mounted) {
      Navigator.of(context).pushNamed(Routes.bookingSuccessScreen);
    }
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
            AppButtonWidget(
              label: 'تأكيد الإلغاء',
              variant: AppButtonVariant.danger,
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
  void _afterCancel(BuildContext context, {required BookingDetailsCubit cubit}) {
    final booking = cubit.booking;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppSemanticColors.positive,
                  size: 22.r,
                ),
                horizontalSpace(AppSpacing.s8),
                Text('اتلغى الحجز', style: AppTextStyles.sectionHeader),
              ],
            ),
            verticalSpace(AppSpacing.s4),
            // TODO(api): سياسة الإلغاء من إعدادات الفرع — دلوقتي ثابتة.
            Text(
              'الإلغاء مجاني ومفيش أي رسوم عليك',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s24),
            AppButtonWidget(
              label: 'تحب تحجز ميعاد تاني؟',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                if (booking != null) _rebook(context, booking);
              },
            ),
            verticalSpace(AppSpacing.listRowGap),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.pop();
                },
                child: Text(
                  'مش دلوقتي',
                  style: AppTextStyles.bodyMdStrong.copyWith(
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تقيّم أنهي خدمة؟', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s4),
            Text(
              'كل خدمة ليها تقييمها لوحدها',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s16),
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.serviceName, style: AppTextStyles.cardTitle),
                subtitle: Text(
                  'مع ${item.employeeName}',
                  style: AppTextStyles.caption,
                ),
                trailing: Icon(
                  Icons.chevron_left_rounded,
                  color: AppSemanticColors.textSecondary,
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.startRating(item);
                  _openRateSheet(context, cubit);
                },
              ),
          ],
        ),
      ),
    );
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
