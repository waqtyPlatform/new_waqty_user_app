import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **مواصفة الأيقونات.**
///
/// ⚠ الاختبار ده موجود لسبب واحد: **`SvgPicture.asset` بمسار غلط مابيرميش
/// استثناء** — بيرسم مربع فاضي في صمت. يعني لا `flutter analyze` ولا
/// `gallery_render_test.dart` بيمسكوا أيقونة ناقصة. الحاجة الوحيدة اللي
/// بتمسكها هي `rootBundle.loadString`.
///
/// وبيقفل كمان المواصفة نفسها، لأن السبب اللي خلّى أيقونات employee-app
/// تتشال هو إنها **مالهاش مواصفة**: ٤ مقاسات `viewBox`، ٤ سُمك حد، و٧
/// ألوان متحطوطة جوه الملفات.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('كل مسار في AppIcons موجود في الـ bundle فعلًا', () async {
    for (final path in AppIcons.all) {
      final source = await rootBundle.loadString(path);
      expect(source, contains('<svg'), reason: '$path مش SVG');
      expect(source, contains('</svg>'), reason: '$path ناقص');
    }
  });

  test('كل أيقونة على نفس المواصفة', () async {
    for (final path in AppIcons.all) {
      final source = await rootBundle.loadString(path);

      expect(
        source,
        contains('viewBox="0 0 24 24"'),
        reason: '$path مقاسه مختلف — ده اللي خلّى طقم employee-app غير متجانس',
      );
      expect(source, contains('fill="none"'), reason: '$path متعبّي');
      expect(
        source,
        contains('stroke-width="2"'),
        reason: '$path سُمك حده مختلف',
      );
      expect(source, contains('stroke-linecap="round"'), reason: path);
      expect(source, contains('stroke-linejoin="round"'), reason: path);
    }
  });

  test('اللون بديل بيتحقن وقت الرسم — مش لون متحطوط', () async {
    for (final path in AppIcons.all) {
      final source = await rootBundle.loadString(path);

      expect(
        source,
        contains('stroke="#000000"'),
        reason: '$path لازم يبقى أسود بديل عشان ColorFilter يشتغل',
      );
      // أي hex تاني معناه لون متحطوط — ده اللي بيمنع الأيقونة إنها
      // تتبع الوضع الغامق.
      final hexes = RegExp(
        r'#[0-9a-fA-F]{3,8}',
      ).allMatches(source).map((m) => m.group(0)!.toUpperCase()).toSet();
      expect(hexes, {'#000000'}, reason: '$path فيه لون متحطوط: $hexes');
      expect(
        source,
        isNot(contains('currentColor')),
        reason: '$path — الكيت بيلوّن بـ ColorFilter مش بـ currentColor',
      );
    }
  });

  test('path واحد بس لكل ملف', () async {
    for (final path in AppIcons.all) {
      final source = await rootBundle.loadString(path);
      expect(
        '<path'.allMatches(source).length,
        1,
        reason: '$path فيه أكتر من path — استخدم subpaths في نفس الـ d',
      );
      // مفيش أشكال تانية بتتسلل جنب الـ path.
      for (final shape in ['<circle', '<rect', '<line', '<polyline', '<g ']) {
        expect(source, isNot(contains(shape)), reason: '$path فيه $shape');
      }
    }
  });

  test('مفيش أيقونة اتنست في AppIcons.all', () async {
    // لو حد ضاف ثابت جديد ونسي يحطه في `all`، الاختبارات اللي فوق
    // مش هتشوفه أصلًا.
    const declared = <String>{
      AppIcons.home,
      AppIcons.booking,
      AppIcons.account,
      AppIcons.money,
      AppIcons.notification,
      AppIcons.help,
      AppIcons.language,
      AppIcons.logout,
      AppIcons.notes,
      AppIcons.done,
      AppIcons.chevronUp,
      AppIcons.chevronDown,
    };
    expect(AppIcons.all.toSet(), declared);
    expect(AppIcons.all.length, declared.length, reason: 'فيه مسار متكرر');
  });
}
