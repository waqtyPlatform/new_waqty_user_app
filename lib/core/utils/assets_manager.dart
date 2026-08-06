class ImageAsset {
  ///test

  static const String t1 = 'assets/test/te1.png';
  static const String t2 = 'assets/test/te2.png';
  static const String t3 = 'assets/test/te3.png';
  static const String t4 = 'assets/test/te4.png';
  static const String t5 = 'assets/test/te5.png';

  ///  ///images

  static const String logoImage = 'assets/images/waty_logo_image.png';
  static const String doneImage = 'assets/images/done_image.png';

  ///icons
  ///

  static const String appleIcon = 'assets/icons/apple_icon.svg';
  static const String googleICon = 'assets/icons/google_icon.svg';

  // ── أيقونات شريط التبويبات اتشالت ────────────────────────────────────
  //
  // كانت ٨ ملفات SVG (عادي/مختار لكل تبويب) **بلون مطبوع جواها**، يعني في
  // الوضع الغامق كانت هتفضل سودا على شريط غامق.
  //
  // الشريط بقى بياخد `Icons.*_rounded` من ماتيريال وبيلوّنها من التوكن،
  // والحالة المختارة بقت دايرة خلف الأيقونة (من الـ design DNA) مش أيقونة
  // تانية — فالملف التاني بطّل يبقى ليه لازمة أصلاً.
  //
  // الملفات لسه في `assets/icons/` لو حد احتاج يرجّعها.

  static const String notificationIcon = 'assets/icons/notification_icon.svg';
  static const String filterIcon = 'assets/icons/filter_icon.svg';
}
