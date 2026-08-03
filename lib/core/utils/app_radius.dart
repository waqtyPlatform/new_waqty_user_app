import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// سلّم الاستدارة — من ١٦ قيمة لستة.
///
/// كان فيه ٠ و٢ و٣ و٤ و٨ و٩ و١٠ و١٢ و١٤ و١٦ و١٨ و٢٠ و٢٢ و٢٤ و٣٢ و٣٦.
/// والحبّة الواحدة كانت ٢٠ في تلات أماكن و٢٢ في تلاتة تانيين.
///
/// **التداخل بقى مضبوط رياضيًا:** كارت [l] بحشوة ١٢ → الصورة جواه [xs].
/// ٢٠ − ١٢ = ٨. قبل كده الصور كانت ١٠ أو ١٢ جوه كروت ١٦ — يعني مش متداخلة
/// مع أي كارت في الأبلكيشن.
class AppRadius {
  AppRadius._();

  /// الصور جوه الكروت · خطوط الـ skeleton · أطباق الأيقونات
  static const double xs = 8;

  /// كنترولات صغيرة: صف الخدمة · مواعيد العمل · مربعات الإجراءات
  static const double s = 12;

  /// الزرار الأساسي · البحث · الحقول · خلية اليوم · التصنيفات
  static const double m = 16;

  /// الكروت المرفوعة
  static const double l = 20;

  /// أعلى الـ sheets · مسار التبويبات
  static const double xl = 24;

  /// الشيبس والشارات — الاستدارة مابتعتمدش على الارتفاع
  static const double pill = 999;

  static BorderRadius get rXs => BorderRadius.circular(xs.r);
  static BorderRadius get rS => BorderRadius.circular(s.r);
  static BorderRadius get rM => BorderRadius.circular(m.r);
  static BorderRadius get rL => BorderRadius.circular(l.r);
  static BorderRadius get rXl => BorderRadius.circular(xl.r);
  static BorderRadius get rPill => BorderRadius.circular(pill);

  /// أعلى الـ sheet بس.
  static BorderRadius get sheetTop =>
      BorderRadius.vertical(top: Radius.circular(xl.r));
}
