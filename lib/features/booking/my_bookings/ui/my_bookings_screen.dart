import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/empty_state_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_cubit.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_skeleton_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_bookings_tabs_widget.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      builder: (context, state) {
        final cubit = MyBookingsCubit.get(context);

        return Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.pageGutter.w,
                end: AppSpacing.pageGutter.w,
                top: AppSpacing.s8.h,
              ),
              child: Row(
                children: [Text('حجوزاتي', style: AppTextStyles.titleLg)],
              ),
            ),
            verticalSpace(AppSpacing.headerToContent),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
              ),
              child: MyBookingsTabsWidget(
                selectedTab: cubit.selectedTab,
                onTabChanged: cubit.changeTab,
              ),
            ),
            verticalSpace(AppSpacing.headerToContent),
            Expanded(child: _body(context, cubit, state)),
          ],
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    MyBookingsCubit cubit,
    MyBookingsState state,
  ) {
    // **الهامش الأفقي بقى صفر.** [MyBookingRowWidget] صف full-bleed شايل
    // الـ ١٦ بتاعه **جواه**، فلو الـ `ListView` كمان حطّ ١٦ يبقى النص على
    // ٣٢ والخط الشعري عمره ما هيوصل لحافة الشاشة.
    //
    // الهامش السفلي واحد في التحميل والمحمّل — من غير كده اللستة بتنطّ لما
    // الداتا توصل.
    final padding = EdgeInsetsDirectional.only(
      bottom: AppSpacing.screenBottom.h,
    );

    // مفيش `separatorBuilder` في اللستتين: الصف بيرسم خطه الشعري بنفسه، فأي
    // فاصل هنا معناه **فاصلين** — خط ومسافة ورا بعض.
    if (state is MyBookingsLoadingState || state is InitialState) {
      // خمسة مش تلاتة: الصف ٩٦٫٢ والنافذة ~٥٧٤، يعني تلاتة (٢٨٩) بيسيبوا
      // نص الشاشة فاضي وقت التحميل — والفراغ ده بيقرا «مفيش حاجة» مش
      // «بتحمّل». خمسة (٤٨١) بيوصلوا لحد الطية.
      const skeletonCount = 5;
      return ListView.builder(
        padding: padding,
        itemCount: skeletonCount,
        itemBuilder: (_, index) => MyBookingRowSkeletonWidget(
          showHairline: index != skeletonCount - 1,
        ),
      );
    }

    if (state is MyBookingsErrorState) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.pageGutter.w,
        ),
        child: ErrorStateWidget(
          message: state.message,
          onRetry: cubit.loadBookings,
        ),
      );
    }

    if (state is MyBookingsEmptyState) {
      return EmptyStateWidget(
        icon: Icons.event_note_outlined,
        title: cubit.selectedTab == 0
            ? 'مفيش حجوزات جاية'
            : 'مفيش حجوزات سابقة',
        message: cubit.selectedTab == 0
            ? 'أول ما تحجز، هتلاقيه هنا'
            : 'الحجوزات اللي خلصت هتظهر هنا',
        actionLabel: cubit.selectedTab == 0 ? 'دوّر على مكان قريب' : null,
        onAction: cubit.selectedTab == 0
            ? () => context.pushNamed(Routes.providersListScreen)
            : null,
      );
    }

    // لون المؤشر جاي من `colorScheme.primary` في الثيم.
    return RefreshIndicator(
      onRefresh: cubit.loadBookings,
      child: ListView.builder(
        // **من غير السطر ده الـ `RefreshIndicator` ميت.**
        //
        // تلات صفوف × ٩٦٫٢ + ٣٢ = ٣٢١ في نافذة ~٥٧٤ — يعني المحتوى أقصر
        // من الشاشة، فالـ `ListView` بيرفض السحب أصلاً والمؤشر عمره ما
        // بيتنادى. والتحويل من كروت لصفوف قصّر القايمة أكتر، فالباج بقى
        // مضمون بدل ما كان محتمل.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: cubit.bookings.length,
        itemBuilder: (context, index) {
          final booking = cubit.bookings[index];
          // آخر صف من غير خط — الخط تحت الأخير بيرسم حد لقايمة مالهاش حد.
          return MyBookingRowWidget(
            booking: booking,
            showHairline: index != cubit.bookings.length - 1,
            onTap: () => context.pushNamed(
              Routes.bookingDetailsScreen,
              arguments: {'bookingUuid': booking.uuid},
            ),
          );
        },
      ),
    );
  }
}
