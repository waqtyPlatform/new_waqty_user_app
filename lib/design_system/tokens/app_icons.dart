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
/// ⚠ **أي إضافة هنا لازم تعدّي `icons_test.dart`.** `SvgPicture.asset`
/// بمسار غلط **مابيرميش استثناء** — بيرسم مربع فاضي في صمت، فلا
/// `flutter analyze` ولا اختبارات الرسم بيمسكوه.
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons';

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
  ];
}
