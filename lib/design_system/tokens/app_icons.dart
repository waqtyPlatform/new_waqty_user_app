/// مسارات أيقونات الكيت.
///
/// ## ليه الأيقونات اتعادت رسمها بدل ما تتنسخ
///
/// الـ **٢٧ أيقونة** في `employee-app/assets/icons/` **مش طقم**:
/// أربع مقاسات `viewBox` مختلفة (`24×24` ×٦ · `15×15` ×١٤ · `14×14` ×٥ ·
/// `6×6` ×٢)، أربع سُمك حد (`0.5` · `1.05` · `1.06667` · `2`)، و**كل ملف
/// فيهم لونه متحطوط جوّه** — `#A3A3A3` ×٥٥ لوحده، و٧ ألوان مختلفة، ولا
/// ملف واحد فيه `currentColor`.
///
/// نتيجتها تلاتة: الأيقونات **مش قادرة تتبع الثيم** (في الوضع الغامق
/// بتفضل رمادي فاتح على أسود)، وأيقونة `15×15` جنب `24×24` بترسم بسُمك
/// حد مختلف بصريًا، ومافيش مواصفة يتكتب عليها اختبار.
///
/// ## المواصفة
///
/// ```
/// viewBox="0 0 24 24" · fill="none" · stroke-width="2"
/// stroke-linecap="round" · stroke-linejoin="round"
/// <path> واحد بس (subpaths مسموحة) · stroke="#000000"
/// ```
///
/// الـ `#000000` **بديل مش لون** — بيتغيّر وقت الرسم بـ
/// `ColorFilter.mode(color, BlendMode.srcIn)`.
///
/// ## ليه ١٢ مش ٢٧
///
/// الـ١٥ الباقية بتوع feature (`profile_biometric_icon`،
/// `contact_manager_icon`، أيقونات الـ payslip…) وبيخصّوا التطبيق اللي
/// هيتبنّى الكيت، مش الكيت.
///
/// ## ⚠ الأيقونات الاتجاهية **مش هنا** — بقصد
///
/// `Icons.arrow_back_rounded` و `Icons.chevron_left_rounded` و
/// `Icons.chevron_right_rounded` معرّفين في فلاتر بـ`matchTextDirection:
/// true` — يعني **بيتقلبوا لوحدهم** في الـRTL. رسم SVG ثابت مابيتقلبش.
///
/// فلو بدّلت `arrow_back_rounded` بـ`arrow_back.svg`، زرار «رجوع» هيشاور
/// **شمال** في العربي — وده معناه «كمّل» مش «رجوع».
///
/// اللي محتاج اتجاه بيعدّي على `DirectionalChevronWidget` وهو بيستخدم
/// أيقونات ماتيريال عن قصد. `chevron_up` و `chevron_down` هنا لأنهم
/// **رأسيين** — مالهمش دعوة باتجاه القراية.
///
/// ⚠ **أي إضافة هنا لازم تعدّي `icons_test.dart`.** `SvgPicture.asset`
/// بمسار غلط **مابيرميش استثناء** — بيرسم مربع فاضي في صمت، فلا
/// `flutter analyze` ولا اختبارات الرسم بيمسكوه.
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons';

  // ── التنقّل والقايمة — الطقم الأصلي ────────────────────────────────
  static const String home = '$_base/home.svg';
  static const String booking = '$_base/booking.svg';
  static const String account = '$_base/account.svg';
  static const String money = '$_base/money.svg';
  static const String notification = '$_base/notification.svg';
  static const String help = '$_base/help.svg';
  static const String language = '$_base/language.svg';
  static const String logout = '$_base/logout.svg';
  static const String notes = '$_base/notes.svg';
  static const String done = '$_base/done.svg';
  static const String chevronUp = '$_base/chevron_up.svg';
  static const String chevronDown = '$_base/chevron_down.svg';

  // ── الأفعال ────────────────────────────────────────────────────────
  static const String close = '$_base/close.svg';
  static const String add = '$_base/add.svg';
  static const String remove = '$_base/remove.svg';
  static const String check = '$_base/check.svg';
  static const String search = '$_base/search.svg';
  static const String refresh = '$_base/refresh.svg';

  // ── الحالات ────────────────────────────────────────────────────────
  static const String checkCircle = '$_base/check_circle.svg';
  static const String error = '$_base/error.svg';
  static const String warning = '$_base/warning.svg';
  static const String info = '$_base/info.svg';
  static const String wifiOff = '$_base/wifi_off.svg';
  static const String inbox = '$_base/inbox.svg';
  static const String eventBusy = '$_base/event_busy.svg';

  // ── متنوّع ─────────────────────────────────────────────────────────
  static const String schedule = '$_base/schedule.svg';
  static const String image = '$_base/image.svg';
  static const String location = '$_base/location.svg';
  static const String visibility = '$_base/visibility.svg';
  static const String visibilityOff = '$_base/visibility_off.svg';
  static const String trendingUp = '$_base/trending_up.svg';
  static const String trendingDown = '$_base/trending_down.svg';

  /// كل اللي الكيت شاحنه — `icons_test.dart` بيمشي على اللستة دي.
  static const List<String> all = [
    home,
    booking,
    account,
    money,
    notification,
    help,
    language,
    logout,
    notes,
    done,
    chevronUp,
    chevronDown,
    close,
    add,
    remove,
    check,
    search,
    refresh,
    checkCircle,
    error,
    warning,
    info,
    wifiOff,
    inbox,
    eventBusy,
    schedule,
    image,
    location,
    visibility,
    visibilityOff,
    trendingUp,
    trendingDown,
  ];
}
