import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';

/// ٤ تبويبات — مش ٥.
///
/// زرار الـ `+` الكبير في النص اتشال. ده كلام إنستجرام وتيك توك ومعناه
/// «اعمل حاجة الناس تشوفها». العميل في تطبيق حجوزات مش بيعمل حاجة —
/// المحلات هي اللي بتعمل. وكمان كان بيفتح شاشة بيضا فاضية، ومالوش label
/// فقارئ الشاشة كان بيقول «تبويب ٣ من ٥» وبس.
///
/// و«استكشاف» كان بيعرض نفس شاشة الهوم بالظبط — تبويبين بنفس المحتوى
/// شكلهم غلطة برمجية، وكمان كان بيضيّع مكان السكرول كل مرة.
class ButtonNavigationBarCubit extends Cubit<ButtonNavigationBarState> {
  ButtonNavigationBarCubit({int initialIndex = 0})
    : currentIndex = initialIndex,
      liveBooking = _resolveLiveBooking(),
      super(InitialState());

  int currentIndex;

  /// الحجز اللي ممكن يبقى له حالة فرع حية دلوقتي، أو `null` لو مفيش حجوزات.
  ///
  /// ## ليه القشرة هي اللي شايلاه مش الهوم
  ///
  /// شريط «الكرسي جاهز» بيظهر فوق التبويبات — يعني على **أي** تبويب، حتى
  /// وإنت في حسابك. فمصدر الحالة لازم يعيش فوق التبويبات الأربعة، مش
  /// جوه واحد منهم.
  ///
  /// والأهم: ده بيخلي في الأبلكيشن **مؤقت واحد بس**. لو الهوم عملت
  /// `InBranchCubit` والقشرة عملت واحد تاني، بيبقى فيه نبضتين
  /// مستقلتين وحقيقتين ممكن يختلفوا في نفس اللحظة — الشريط يقول «دورك
  /// دلوقتي» والبؤرة في الهوم لسه بتقول «اتنين قدامك». ده أوحش من إن
  /// مايبقاش فيه شريط أصلاً.
  final BookingUiModel? liveBooking;

  /// نفس التعبير الموجود في `HomeCubit.loadHome` بالحرف، وبيقرا من نفس
  /// المصدر — عشان لو الهوم لقت حجز تبقى القشرة أكيد لاقياه، والعكس.
  /// أول ما ده يبقى نداء شبكة حقيقي لازم يفضل **نفس الـ endpoint**.
  static BookingUiModel? _resolveLiveBooking() {
    // TODO(api): GET /api/user/bookings?upcoming=true&per_page=1
    final bookings = MockBookings.upcoming;
    return bookings.isEmpty ? null : bookings.first;
  }

  void changeIndex(int i) {
    currentIndex = i;
    emit(OnBottomNavBarChangedState());
  }

  List<BottomNavigationBarItem> buttonNavigationBarItems() => [
    _item(ImageAsset.homeIcon, ImageAsset.selectedHomeIcon, 'الرئيسية'),
    _item(ImageAsset.exploreIcon, ImageAsset.selectedExploreIcon, 'استكشاف'),
    _item(ImageAsset.bookingIcon, ImageAsset.selectedBookingIcon, 'الحجوزات'),
    // «حسابي» مش «البروفايل» — التلات تبويبات التانية عربي، ودي كانت
    // كلمة إنجليزي مكتوبة بحروف عربية جنبهم.
    _item(ImageAsset.accountIcon, ImageAsset.selectedAccountIcon, 'حسابي'),
  ];

  BottomNavigationBarItem _item(String icon, String activeIcon, String label) =>
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsetsDirectional.only(bottom: 4.h),
          child: SvgPicture.asset(icon, height: 22.r, width: 22.r),
        ),
        activeIcon: Padding(
          padding: EdgeInsetsDirectional.only(bottom: 4.h),
          child: SvgPicture.asset(activeIcon, height: 22.r, width: 22.r),
        ),
        label: label,
      );

  static ButtonNavigationBarCubit get(context) => BlocProvider.of(context);
}
