import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
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
        // يقدروا يفترقوا: تبويب يقول ٤:٣٢ والتاني ٤:٣١، وواحد يعلن
        // الانتهاء والتاني لسه شغال. عدّاد بيكدب على نفسه أوحش من عدّاد
        // مش موجود.
        //
        // وهي **برة** الشرط بتاع `live` عن قصد: كده مكانها في الشجرة
        // ثابت مهما اتغيّر الحجز الشغّال، فالمؤقت مابيتعملش من الأول.
        final shell = BlocProvider<WaitlistCubit>(
          create: (_) => WaitlistCubit()..start(),
          child: _shell(context, cubit, live),
        );

        // **الـ Cubit الوحيد لحالة الفرع في الأبلكيشن كله**، ومكانه فوق
        // الأربع تبويبات عشان الشريط (اللي تحت) والبؤرة (اللي جوه الهوم)
        // يقروا من نفس النسخة. `create` مابيتنادش تاني مع تبديل التبويب —
        // الـ Element ثابت في مكانه، فالمؤقت بيتعمل مرة واحدة.
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
      // جاي من `scaffoldBackgroundColor` في الثيم — كان أبيض متكتوب
      // بالإيد وده كان هيمنع الصفحة الدافية على التبويبات الأربعة.
      backgroundColor: AppSemanticColors.page,
      // IndexedStack بيخلي التبويبات كلها عايشة، فالسكرول والداتا
      // مابيضيعوش كل ما العميل يبدّل. القديم كان بيعمل Cubit جديد
      // ونداء شبكة جديد مع كل ضغطة.
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
      // كان ظل مكتوب بالإيد بـ `offset (0,-10)` و`blur 40` **من غير
      // `.r`** (يعني بنفس البكسلات على كل الأجهزة) وبأسود صافي.
      // `AppShadows.floatingUp` موجود لنفس الغرض بالظبط وبيتقاس صح،
      // وهو اللي فوتر الحجز بيستخدمه أصلاً.
      //
      // ## ليه الشريط جوه نفس الحاوية بتاعة الظل
      //
      // الظل بيتلقّى **لفوق** من الحافة العليا للحاوية. لو الشريط قعد
      // برة الحاوية وفوقها، الحاوية هتترسم بعده فظلها الغامق هيقع على
      // ٢٤ بكسل من تحت الشريط ويوسّخ لونه. وهو جوه، الحافة العليا بقت
      // حافة الشريط نفسه — فالظل فوق الشريط مش عليه، والتبويبات
      // والشريط بقوا لوح واحد مرفوع، وده هو الصح: لما الشريط يبان،
      // هما حاجة واحدة قاعدة فوق الصفحة.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppSemanticColors.surfaceRaised,
          boxShadow: AppShadows.floatingUp,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // فوق الـ SafeArea عن قصد — الـ inset التحتاني شغل شريط
            // التبويبات اللي تحته، والشريط ده مش ملزوق في حافة الجهاز.
            _inBranchBanner(context, live),
            SafeArea(
              child: SizedBox(
                height: 62.h,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: cubit.currentIndex,
                  selectedItemColor: AppSemanticColors.accent,
                  // greyColor500 بدل greyColor3003 — القديم كان تباينه
                  // ٢٫٣ تقريبًا، أقل بكتير من الحد الأدنى ٤٫٥، وده أصغر
                  // خط في الأبلكيشن كله.
                  unselectedItemColor: AppColors.greyColor500,
                  // الشريط **مرفوع** مش صفحة — عنده ظل `floatingUp`،
                  // فلازم يبقى أبيض صافي فوق الصفحة الدافية.
                  backgroundColor: AppSemanticColors.surfaceRaised,
                  selectedLabelStyle: AppTextStyles.captionAccent,
                  unselectedLabelStyle: AppTextStyles.caption,
                  elevation: 0,
                  onTap: cubit.changeIndex,
                  items: cubit.buttonNavigationBarItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// الشريط بيتبنى في الحالتين — هو اللي بيطوّي نفسه لصفر.
  ///
  /// لما مافيش حجز أصلاً، مفيش `InBranchCubit` فوقنا نقرا منه، والحالة
  /// دي مابتتغيّرش طول الجلسة — فالـ `if` هنا مابيقتلش أي حركة، عكس لو
  /// لفّينا الشريط نفسه في `if` على حالة الفرع.
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

  /// الشريط مطوي ومفيش حاجة تتداس — بس `onTap` مطلوب، فبدل ما نعمل
  /// closure جديد كل build نستعمل دالة ثابتة تخلّي الـ widget `const`.
  static void _noop() {}
}
