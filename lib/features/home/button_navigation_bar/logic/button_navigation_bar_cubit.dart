import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';

/// تبويب واحد في الشريط.
///
/// كان `BottomNavigationBarItem` جاي من الـ cubit — يعني الـ cubit كان بيرجّع
/// **widgets**. ده خلّى شكل الشريط مربوط بـ `BottomNavigationBar` بتاعة
/// ماتيريال، واللي مابتعرفش ترسم زرار وسطاني مرفوع.
@immutable
class NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// **٤ تبويبات — مفيش زرار وسطاني.**
///
/// الزرار الوسطاني بتاع الـ design DNA اتجرّب واتشال: في أبلكيشن حجز
/// مافيش «إنشاء»، فالزرار كان لازم يفتح sheet يسأل «تحب تحجز إزاي؟» —
/// خطوة زيادة قبل نفس الشاشتين اللي التبويبات بتوصّلهم أصلاً. التفاصيل في
/// `AppBottomNavWidget`.
///
/// و«استكشاف» بقى **بيعرض لستة المحلات** مش نسخة تانية من الرئيسية — ده كان
/// سبب إن الشريط القديم بيبان مكرّر.
class ButtonNavigationBarCubit extends Cubit<ButtonNavigationBarState> {
  final HomeRepo _repo;

  ButtonNavigationBarCubit(this._repo, {int initialIndex = 0})
    : currentIndex = initialIndex,
      super(InitialState());

  int currentIndex;

  /// الحجز اللي ممكن يبقى له حالة فرع حية دلوقتي، أو `null` لو مفيش حجوزات.
  ///
  /// ## ليه القشرة هي اللي شايلاه مش الهوم
  ///
  /// شريط «الكرسي جاهز» بيظهر فوق التبويبات — يعني على **أي** تبويب، حتى
  /// وإنت في حسابك. فمصدر الحالة لازم يعيش فوق التبويبات الأربعة.
  ///
  /// والأهم: ده بيخلي في الأبلكيشن **مؤقت واحد بس**. لو الهوم عملت
  /// `InBranchCubit` والقشرة عملت واحد تاني، بيبقى فيه نبضتين مستقلتين
  /// وحقيقتين ممكن يختلفوا في نفس اللحظة — الشريط يقول «دورك دلوقتي»
  /// والبؤرة في الهوم لسه بتقول «اتنين قدامك».
  ///
  /// ⚠ **بيتحمّل في [start] مش في الكونستركتور.** كان بيتقرا من الموك
  /// بشكل متزامن، وده مايتحوّلش لنداء شبكة. القشرة بتتبني الأول بشريط
  /// من غير حالة فرع، وبيظهر لما الحجز يوصل.
  BookingUiModel? liveBooking;

  /// بيجيب أقرب حجز جاي — مصدر حالة «جوّه الفرع».
  Future<void> start() async {
    final result = await _repo.upcomingBooking();
    if (isClosed) return;

    // فشل الجلب معناه مفيش شريط فرع — مش شاشة خطأ. الشريط ده إضافة
    // على القشرة، مش شرط لتشغيلها.
    liveBooking = result.getOrElse(() => null);
    emit(OnBottomNavBarChangedState());
  }

  void changeIndex(int i) {
    if (i == currentIndex) return;
    currentIndex = i;
    emit(OnBottomNavBarChangedState());
  }

  /// الأيقونات ماتيريال `_rounded` — **مش الـ SVG القديمة**.
  ///
  /// الـ SVG كانت ملفين لكل تبويب (عادي/مختار) بلون مطبوع جواها، يعني في
  /// الوضع الغامق كانت هتفضل سودا على شريط غامق. والحالة المختارة دلوقتي
  /// بقت **دايرة خلف الأيقونة** (من الـ DNA) مش أيقونة تانية، فالملف
  /// التاني بطّل يبقى ليه لازمة أصلاً.
  static const List<NavTab> tabs = [
    NavTab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    NavTab(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'استكشاف',
    ),
    NavTab(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'الحجوزات',
    ),
    // «حسابي» مش «البروفايل» — التلات تبويبات التانية عربي، ودي كانت كلمة
    // إنجليزي مكتوبة بحروف عربية جنبهم.
    NavTab(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'حسابي',
    ),
  ];

  static ButtonNavigationBarCubit get(BuildContext context) =>
      BlocProvider.of(context);
}
