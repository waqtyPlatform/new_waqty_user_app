import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// سلّم الاستدارة.
///
/// employee-app فيه **١٥٩ رقم استدارة سايب**، بس التوزيع بيقول إن فيه سلّم
/// حقيقي محدش سمّاه:
///
/// ```
/// 10 ×٧٩   ← الكارت. نص كل استدارة في الأبلكيشن.
/// 100 ×٣١  ← pill
/// 20 ×١٣   ← الحقول والزرار
/// 8 ×٧ · 6 ×٧ · 12 ×٥ · 50 ×٤ · 4 ×٣ · 16 ×٣ · 9 ×٢ · 40 ×٢ · 30 ×٢
/// ```
///
/// ⚠ **السلّم ده مش سلّم user-app (8/12/16/24).** الاستدارة أوضح توقيع
/// بصري في أي هوية — كارت ١٠ جنب كارت ١٦ بيقروا منتجين مختلفين. الأمانة
/// كسبت هنا بقرار موثّق.
///
/// ## اللي اتشال
///
/// **8 و 9 اتلموا على 10** — الاتنين في حدود نقطتين من استدارة الكارت
/// وعمرهم ما كانوا اختيار: `SearchWidget` بيستخدم 9 والحقل اللي جنبه
/// بيستخدم 20. **16 اتلم على 10** (٣ استخدامات). **40 و 50 و 100 كلهم
/// [pill]** — تلات طرق لكتابة «نص الارتفاع». **4 اتلم على [xs]**.
class AppRadius {
  AppRadius._();

  /// شيبس داخلية، كنترولات صغيرة، الفاصل المنقّط.
  static const double xs = 6;

  /// ★ **الكارت** — ٧٩ استخدام.
  static const double s = 10;

  /// كروت المعلومات، والزرار الصغير.
  static const double m = 12;

  /// الحقول · البحث · الزرار الأساسي.
  static const double l = 20;

  /// أي حاجة نصف دايرة.
  static const double pill = 999;

  static BorderRadius get rXs => BorderRadius.circular(xs.r);
  static BorderRadius get rS => BorderRadius.circular(s.r);
  static BorderRadius get rM => BorderRadius.circular(m.r);
  static BorderRadius get rL => BorderRadius.circular(l.r);

  /// **مش `.r`** — الـ pill المفروض يفضل نص الارتفاع مهما كان المقياس.
  static BorderRadius get rPill => BorderRadius.circular(pill);

  /// أعلى الـ bottom sheet.
  static BorderRadius get sheetTop =>
      BorderRadius.vertical(top: Radius.circular(l.r));
}
