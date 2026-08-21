import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
// `show` مش استيراد كامل: `account_state` و`my_bookings_state` الاتنين
// فيهم `InitialState`، والتصادم بيوقف الترجمة.
import 'package:waqty_user_application/features/account/account/logic/account_state.dart'
    show AccountState;
import 'package:waqty_user_application/features/account/phone_verification/ui/widgets/phone_claim_result_sheet.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_cubit.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_skeleton_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_bookings_notice_widget.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/waitlist_screen.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_state.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/widgets/waitlist_card_widget.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/widgets/waitlist_change_request_sheet.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      builder: (context, state) {
        final cubit = MyBookingsCubit.get(context);

        return Column(
          children: [
            // **[AppScreenHeaderWidget] من غير `onBack`** — ده تبويب مش
            // شاشة مدفوعة، فمافيش دايرة رجوع. الارتفاع بيكبر مع مقياس
            // الخط بدل ما يفضل `titleLg` في `Row` مالوش ارتفاع معرّف.
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.pageGutter.w,
                end: AppSpacing.pageGutter.w,
                top: AppSpacing.s8.h,
              ),
              child: const AppScreenHeaderWidget(title: 'حجوزاتي'),
            ),
            verticalSpace(AppSpacing.headerToContent),
            // **[AppTabBarWidget] مش مقسّم بحبّة بتزحلق.**
            //
            // التقسيم هنا **حالات لنفس المحتوى** (حجز قادم / حجز خلص) —
            // وده تعريف التبويب في الكيت. المقسّم بيغيّر **مدى** نفس
            // المحتوى (الشهر ده / الشهر اللي فات)، وده مش اللي بيحصل.
            //
            // اللي اتشال معاه: ٧٨ سطر `Stack` + `AnimatedAlign` +
            // `FractionallySizedBox`، والارتفاع الخام `48.h`.
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
              ),
              child: AppTabBarWidget<int>(
                value: cubit.selectedTab,
                onChanged: cubit.changeTab,
                tabs: const [
                  AppSegment(value: 0, label: 'القادمة'),
                  AppSegment(value: 1, label: 'السابقة'),
                ],
              ),
            ),
            verticalSpace(AppSpacing.headerToContent),
            Expanded(child: _body(context, cubit, state)),
          ],
        );
      },
    );
  }

  /// قوائم الانتظار — فوق قايمة الحجوزات في تبويب «القادمة».
  ///
  /// **مكانها هنا مش تبويب لوحدها.** إدخال في قائمة انتظار مش حجز، بس
  /// هو **نية حجز مستنية رد** — يعني بينتمي لنفس السؤال اللي العميل
  /// بيفتح التبويب ده عشانه: «أنا مستني إيه؟». تبويب تالت كان هيخلي
  /// حاجة بتحصل مرة كل شهر تاخد تلت الشريط.
  ///
  /// وبيختفي بالكامل لما مفيش إدخالات.
  ///
  /// [fallback] بيترسم مكانه لما مفيش إدخالات — بيستخدمه الفرع الفاضي
  /// عشان **الحالة الفاضية ماتظهرش تحت عرض شغّال**. من غير كده الشاشة
  /// كانت بتقول «مفيش حجوزات جاية · أول ما تحجز هتلاقيه هنا» تحت كارت
  /// بيقول «محجوز ليك · 4:21» بالحرف — الجملتين بيتناقضوا وهما على بعد
  /// سنتيمتر، والعميل مش عارف يصدّق أنهي واحدة.
  Widget _waitlist(BuildContext context, {Widget? fallback}) {
    if (MyBookingsCubit.get(context).selectedTab != 0) {
      return fallback ?? const SizedBox.shrink();
    }

    // **مفيش `BlocProvider` هنا.** الـ `WaitlistCubit` بيتعمل مرة واحدة
    // في `ButtonNavigationBarScreen` فوق التبويبات الأربعة، والرئيسية
    // وهنا بيقروا **من نفس النسخة** — عشان العدّاد مايبقاش رقمين
    // مختلفين في تبويبين.
    return BlocBuilder<WaitlistCubit, WaitlistState>(
      builder: (context, state) {
        if (state is! WaitlistReadyState || state.entries.isEmpty) {
          return fallback ?? const SizedBox.shrink();
        }

        return WaitlistSectionWidget(
          entries: state.entries,
          now: DateTime.now(),
          onRemove: WaitlistCubit.get(context).leaveQueue,
          onAccept: WaitlistCubit.get(context).acceptOffer,
          onRequestChange: (entry) => _requestChange(context, entry),
          // الشاشة الكاملة بتوري كمان اللي **خلص** — اتحوّل لحجز أو
          // الميعاد راح. القسم هنا بيعرض الشغّال، وده صح: التبويب بيجاوب
          // «أنا مستني إيه؟» مش «حصل إيه قبل كده؟».
          onSeeAll: () => WaitlistScreen.push(context),
        );
      },
    );
  }

  /// نفس فلو الشاشة المستقلة — السبب مطلوب في السيرفر.
  Future<void> _requestChange(
    BuildContext context,
    WaitlistUiModel entry,
  ) async {
    final cubit = WaitlistCubit.get(context);
    final reason = await WaitlistChangeRequestSheet.show(context, entry);

    if (reason == null) return;

    cubit.requestChange(entry.uuid, reason);
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
        child: AppErrorStateWidget(
          message: state.message,
          onRetry: cubit.loadBookings,
        ),
      );
    }

    // **القايمة فاضية بس فيه حاجة تانية؟ هي دي المحتوى.**
    //
    // حالتين بتقعوا هنا:
    //  • كل الحجوزات السابقة اتلغت → الإشعارات هي اللي حصل فعلاً
    //  • مفيش حجز جاي بس فيه إدخال في قائمة انتظار → **دي أهم حاجة
    //    على الشاشة**، وكانت بتختفي تمامًا لأن قسم القائمة كان بيترسم
    //    جوه أول صف في الليستة — ومفيش صفوف أصلاً.
    //
    // من غير الفرع ده الشاشة بتقول «مفيش حاجة» وهي عندها حاجة.
    if (state is MyBookingsEmptyState) {
      final hasNotices = cubit.notices.isNotEmpty;
      final showsWaitlist = cubit.selectedTab == 0;

      if (hasNotices || showsWaitlist) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.pageGutter.w,
            end: AppSpacing.pageGutter.w,
            bottom: AppSpacing.screenBottom.h,
          ),
          children: [
            // الحالة الفاضية بتترسم **مكان** كارت القائمة لو مفيش
            // إدخالات — مش تحته. لو فيه إشعارات، هي اللي حصل فعلاً
            // فمفيش داعي لأي حالة فاضية أصلاً.
            _waitlist(
              context,
              fallback: hasNotices ? null : _emptyState(context, cubit),
            ),
            _notices(context, cubit),
          ],
        );
      }
    }

    if (state is MyBookingsEmptyState) return _emptyState(context, cubit);

    // لون المؤشر جاي من `colorScheme.primary` في الثيم.
    return RefreshIndicator(
      onRefresh: cubit.loadBookings,
      // **التحميل بيبدأ قبل ما العميل يوصل الآخر.**
      //
      // `GET /user/bookings` مقسّم لصفحات (١٥ افتراضي)، فعميل عنده ٤٠
      // حجز بيوصله تلات صفحات. لو استنينا لآخر صف، بيشوف فراغ لحد ما
      // الرد ييجي. ٤٠٠ بكسل قبل النهاية تقريبًا أربع صفوف — كفاية إن
      // الصفحة الجاية توصل وهو لسه بيسحب.
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.axis != Axis.vertical) return false;
          if (metrics.pixels >= metrics.maxScrollExtent - 400) {
            cubit.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          // **من غير السطر ده الـ `RefreshIndicator` ميت.**
          //
          // تلات صفوف × ٩٦٫٢ + ٣٢ = ٣٢١ في نافذة ~٥٧٤ — يعني المحتوى أقصر
          // من الشاشة، فالـ `ListView` بيرفض السحب أصلاً والمؤشر عمره ما
          // بيتنادى. والتحويل من كروت لصفوف قصّر القايمة أكتر، فالباج بقى
          // مضمون بدل ما كان محتمل.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          // صف زيادة للمؤشر لما فيه صفحة جاية.
          itemCount: cubit.bookings.length + (cubit.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // قوائم الانتظار قبل أول صف — جوه الـ builder عشان تتحرك
            // مع السكرول بدل ما تاخد مساحة ثابتة فوق القايمة.
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _waitlist(context),
                  _notices(context, cubit),
                  _row(context, cubit, 0),
                ],
              );
            }

            if (index >= cubit.bookings.length) {
              return Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.s16.h,
                ),
                // `AppLoadingWidget` مش `CircularProgressIndicator` عاري:
                // المقاس والسُمك كانوا رقمين خام (`20` و`strokeWidth: 2`)،
                // وده مؤشر التحميل الوحيد في الأبلكيشن اللي كان بيرسم
                // بمقاس مختلف عن باقي المؤشرات.
                child: const Center(child: AppLoadingWidget(size: 20)),
              );
            }

            return _row(context, cubit, index);
          },
        ),
      ),
    );
  }

  /// **فاضيتين بسببين مختلفين — ونصين مختلفين.**
  ///
  /// العميلة اللي حجزت من الفرع ورقمها مش مأكّد **عندها حجوزات فعلاً**،
  /// التطبيق بس مش شايفها: `Booking.user_id` مابيتحطش غير لما
  /// `provider_customers` يترّبط بحساب المنصة، واللي بيحصل في `verify-phone`.
  ///
  /// فـ«مفيش حجوزات جاية» في الحالة دي **معلومة غلط**، و«دوّر على مكان
  /// قريب» بتبعتها تحجز حاجة هي حاجزاها. الفرع ده بيحوّل الطريق المسدود
  /// لفعل.
  Widget _emptyState(BuildContext context, MyBookingsCubit cubit) {
              // ⚠ **`BlocBuilder` على `AccountCubit` مش قراية مباشرة.**
              //
              // النص هنا بيتفرّع على `phone_verified_at`، والحساب
              // والاستحقاقات بيتحمّلوا **متوازيين**. لو الحساب خلص بعد
              // الاستحقاقات، القراية المباشرة كانت بتشوف `null` وترسم
              // «لسه مافيش باقات» — و**مافيش حاجة بترجع تبنيها تاني**،
              // فالعميلة اللي رقمها مش مأكّد كانت بتقعد على النص الغلط.
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, _) => _emptyStateBody(context, cubit),
    );
  }

  Widget _emptyStateBody(BuildContext context, MyBookingsCubit cubit) {
    final isUpcoming = cubit.selectedTab == 0;
    final account = AccountCubit.get(context).account;

    // `null` = الحساب لسه بيتحمّل. مابنفترضش إنه مأكّد ولا مش مأكّد —
    // بنعرض النص المحايد لحد ما نعرف.
    final needsVerification = account != null && !account.isPhoneVerified;

    if (needsVerification) {
      return AppEmptyStateWidget(
        icon: Icons.phone_iphone_rounded,
        title: 'مش لاقي حجوزاتك؟',
        message: 'لو حجزت من الفرع، أكّد رقم تليفونك عشان تظهر هنا.',
        actionLabel: 'أكّد رقمي',
        onAction: () => _verifyPhone(context, cubit),
      );
    }

    return AppEmptyStateWidget(
      icon: Icons.event_note_outlined,
      title: isUpcoming ? 'مفيش حجوزات جاية' : 'مفيش حجوزات سابقة',
      message: isUpcoming
          ? 'أول ما تحجز، هتلاقيه هنا'
          : 'الحجوزات اللي خلصت هتظهر هنا',
      actionLabel: isUpcoming ? 'دوّر على مكان قريب' : null,
      onAction: isUpcoming
          ? () => context.pushNamed(Routes.providersListScreen)
          : null,
    );
  }

  /// بيفتح التأكيد، وبعد النجاح **بيعيد تحميل الحساب والحجوزات**.
  ///
  /// الترتيب مهم: الحساب الأول عشان الشيب والحالة الفاضية يعرفوا إن الرقم
  /// بقى مأكّد، وبعدين الحجوزات عشان اللي اترّبط يظهر.
  Future<void> _verifyPhone(BuildContext context, MyBookingsCubit cubit) async {
    final accountCubit = AccountCubit.get(context);
    final result = await Navigator.of(
      context,
    ).pushNamed(Routes.phoneVerificationScreen);

    if (!context.mounted) return;
    if (result is! PhoneClaimResultUiModel) return;

    await accountCubit.getProfile();
    if (!context.mounted) return;
    await cubit.loadBookings();

    if (!context.mounted) return;
    await PhoneClaimResultSheet.show(context, result: result);
  }

  /// إشعارات الإلغاء و«ما حضرش» — فوق «السابقة»، وكل واحد بيتقفل.
  Widget _notices(BuildContext context, MyBookingsCubit cubit) {
    final notices = cubit.notices;
    if (notices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final booking in notices) ...[
          MyBookingsNoticeWidget(
            booking: booking,
            onDismiss: () => cubit.dismissNotice(booking.uuid),
            onRebook: () async {
              await CreateBookingSheet.show(
                context,
                providerUuid: booking.providerUuid,
                providerName: booking.providerName,
                branchUuid: booking.branchUuid,
                serviceUuid: booking.items.first.serviceUuid,
              );
              if (context.mounted) cubit.refreshAfterChange();
            },
          ),
          verticalSpace(AppSpacing.listRowGap),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, MyBookingsCubit cubit, int index) {
    final booking = cubit.bookings[index];

    // آخر صف من غير خط — الخط تحت الأخير بيرسم حد لقايمة مالهاش حد.
    return MyBookingRowWidget(
      booking: booking,
      showHairline: index != cubit.bookings.length - 1,
      onTap: () async {
        await context.pushNamed(
          Routes.bookingDetailsScreen,
          arguments: {'bookingUuid': booking.uuid},
        );
        // **الرجوع من التفاصيل بيعيد التحميل.**
        //
        // الـ cubit عايش في الـ `IndexedStack` بتاع القشرة فمابيتعملش
        // من جديد. من غير السطر ده، حجز اتلغى من صفحة التفاصيل بيفضل
        // ظاهر تحت «القادمة».
        if (context.mounted) cubit.refreshAfterChange();
      },
    );
  }
}
