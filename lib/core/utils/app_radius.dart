import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// سلّم الاستدارة — **٤ قيم وpill**، نفس سلّم الـ design DNA بالظبط
/// (`8 / 12 / 16 / 24 / full`).
///
/// كان فيه ١٦ قيمة (٠ و٢ و٣ و٤ و٨ و٩ و١٠ و١٢ و١٤ و١٦ و١٨ و٢٠ و٢٢ و٢٤ و٣٢ و٣٦)،
/// والحبّة الواحدة كانت ٢٠ في تلات أماكن و٢٢ في تلاتة تانيين.
///
/// ## القيمة ٢٠ اتشالت
///
/// كانت استدارة الكارت. وحشوة الكارت في الـ DNA **١٦**، يعني الصورة اللي جواه
/// لازم تبقى ٢٠ − ١٦ = **٤** عشان التداخل يبقى مضبوط — ومحدش كان بيكتب ٤،
/// كلهم كانوا بيكتبوا ٨.
///
/// دلوقتي الكارت [m] (١٦) بحشوة ١٦ → الصورة جواه [xs] (٨) لما تبقى مُدرجة،
/// أو صفر لما تبقى full-bleed لحد الحافة. الاتنين قرار مكتوب مش صدفة.
class AppRadius {
  AppRadius._();

  /// الصور جوه الكروت · خطوط الـ skeleton · أطباق الأيقونات
  static const double xs = 8;

  /// **الزرار الأساسي · الحقول · البحث** · الكنترولات الصغيرة
  ///
  /// من الـ DNA: `Primary: … 12px border-radius` و`Inputs: Rounded 12px`.
  /// كانت ١٦ — الزرار كان بيقرا أنعم من اللازم جنب كارت استدارته ٢٠.
  static const double s = 12;

  /// **الكروت** · خلية اليوم · التصنيفات
  static const double m = 16;

  /// أعلى الـ sheets · اللوحات الكبيرة · مسار التبويبات
  static const double xl = 24;

  /// الشيبس والشارات — الاستدارة مابتعتمدش على الارتفاع
  static const double pill = 999;

  static BorderRadius get rXs => BorderRadius.circular(xs.r);
  static BorderRadius get rS => BorderRadius.circular(s.r);
  static BorderRadius get rM => BorderRadius.circular(m.r);
  static BorderRadius get rXl => BorderRadius.circular(xl.r);
  static BorderRadius get rPill => BorderRadius.circular(pill);

  /// أعلى الـ sheet بس.
  static BorderRadius get sheetTop =>
      BorderRadius.vertical(top: Radius.circular(xl.r));
}
