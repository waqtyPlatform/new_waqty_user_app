import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/ui/account_screen.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_cubit.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_state.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_banner_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_cubit.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/my_bookings_screen.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/home/ui/home_screen.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_cubit.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/providers_list_screen.dart';

class ButtonNavigationBarScreen extends StatelessWidget {
  const ButtonNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButtonNavigationBarCubit, ButtonNavigationBarState>(
      buildWhen: (previous, current) => current is OnBottomNavBarChangedState,
      builder: (context, state) {
        final cubit = ButtonNavigationBarCubit.get(context);
        final live = cubit.liveBooking;

        // **نسخة واحدة من قائمة الانتظار للأبلكيشن كله** — لنفس سبب
        // `InBranchCubit` تحت بالظبط.
        //
        // الحجز المؤقت عدّاد بينبض **كل ثانية**. لو الرئيسية عملت نسخة
        // ومواعيدي عملت نسخة تانية، بيبقى فيه **مؤقتين ومصدرين حقيقة**
        // يقدروا يفترقوا: تبويب يقول ٤:٣٢ والتاني ٤:٣١، وواحد يعلن الانتهاء
        // والتاني لسه شغال. عدّاد بيكدب على نفسه أوحش من عدّاد مش موجود.
        //
        // وهي **برة** الشرط بتاع `live` عن قصد: كده مكانها في الشجرة ثابت
        // مهما اتغيّر الحجز الشغّال، فالمؤقت مابيتعملش من الأول.
        final shell = BlocProvider<WaitlistCubit>(
          create: (_) => WaitlistCubit()..start(),
          child: _shell(context, cubit, live),
        );

        // **الـ Cubit الوحيد لحالة الفرع في الأبلكيشن كله**، ومكانه فوق
        // الأربع تبويبات عشان الشريط (اللي تحت) والبؤرة (اللي جوه الهوم)
        // يقروا من نفس النسخة.
        if (live == null) return shell;

        return BlocProvider(
          create: (_) => InBranchCubit(booking: live)..start(),
          child: shell,
        );
      },
    );
  }

  Widget _shell(
    BuildContext context,
    ButtonNavigationBarCubit cubit,
    BookingUiModel? live,
  ) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      // IndexedStack بيخلي التبويبات كلها عايشة، فالسكرول والداتا مابيضيعوش
      // كل ما العميل يبدّل. القديم كان بيعمل Cubit جديد ونداء شبكة جديد مع
      // كل ضغطة.
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: cubit.currentIndex,
          children: [
            BlocProvider(
              create: (_) => HomeCubit()..loadHome(),
              child: const HomeScreen(),
            ),
            BlocProvider(
              create: (_) => ProvidersListCubit()..loadInitial(),
              child: const ProvidersListScreen(),
            ),
            BlocProvider(
              create: (_) => MyBookingsCubit()..loadBookings(),
              child: const MyBookingsScreen(),
            ),
            BlocProvider(
              create: (_) => AccountCubit()..getProfile(),
              child: const AccountScreen(),
            ),
          ],
        ),
      ),
      // `AppBottomNavWidget` شايل سطحه وظله بنفسه — الظل بيتلقّى **لفوق**
      // من حافته العليا، فلو اتلفّ في حاوية تانية ظلها كان هيقع عليه.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // فوق الـ SafeArea عن قصد — الـ inset التحتاني شغل شريط التبويبات
          // اللي تحته، والشريط ده مش ملزوق في حافة الجهاز.
          _inBranchBanner(context, live),
          // التحويل من `NavTab` لـ`AppNavItem` بيتعمل هنا مش في الـ cubit —
          // الـ cubit مايعرفش الديزاين سيستم، والشريط مايعرفش راوتات
          // التطبيق. الاتنين بيتقابلوا في الشاشة بس.
          AppBottomNavWidget(
            items: [
              for (final tab in ButtonNavigationBarCubit.tabs)
                AppNavItem(
                  label: tab.label,
                  icon: tab.icon,
                  activeIcon: tab.activeIcon,
                ),
            ],
            currentIndex: cubit.currentIndex,
            onTap: cubit.changeIndex,
          ),
        ],
      ),
    );
  }

  /// الشريط بيتبنى في الحالتين — هو اللي بيطوّي نفسه لصفر.
  ///
  /// لما مافيش حجز أصلاً، مفيش `InBranchCubit` فوقنا نقرا منه، والحالة دي
  /// مابتتغيّرش طول الجلسة — فالـ `if` هنا مابيقتلش أي حركة، عكس لو لفّينا
  /// الشريط نفسه في `if` على حالة الفرع.
  Widget _inBranchBanner(BuildContext context, BookingUiModel? live) {
    if (live == null) {
      return const InBranchBannerWidget(data: null, onTap: _noop);
    }

    return BlocBuilder<InBranchCubit, InBranchState>(
      builder: (context, state) => InBranchBannerWidget(
        data: state is InBranchReadyState ? state.data : null,
        onTap: () => context.pushNamed(
          Routes.bookingDetailsScreen,
          arguments: {'bookingUuid': live.uuid},
        ),
      ),
    );
  }

  /// الشريط مطوي ومفيش حاجة تتداس — بس `onTap` مطلوب، فبدل ما نعمل closure
  /// جديد كل build نستعمل دالة ثابتة تخلّي الـ widget `const`.
  static void _noop() {}
}
