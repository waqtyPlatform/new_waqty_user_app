import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **قفل قابلية النسخ.**
///
/// ده الاختبار اللي بيخلي «انسخ فولدر» ادّعاء **مثبت** مش أمنية. وهو
/// الحاجة الوحيدة اللي user-app مش عنده — لأنه مش محتاجها، مافيش حد
/// بينسخ منه.
///
/// بيمشي على `lib/design_system/` كلها وبيتأكد إن مافيش:
///
/// | الممنوع | ليه |
/// |---|---|
/// | `package:waqty_user_application` | الـ imports لازم relative عشان الفولدر ينسخ بأي اسم |
/// | `flutter_bloc` · `get_it` · `provider` | الكيت مالوش state management ولا DI |
/// | `easy_localization` · `.tr()` | الكيت مالوش لوكلة — النصوص بتدخله جاهزة |
/// | `http` · `dio` | مالوش شبكة |
/// | `Navigator.push` · `Navigator.pop` | اللي بينده هو اللي بيملك التنقّل |
/// | `dart:io` | مابيتكمبلش على الويب |
/// | `EdgeInsets.only` · `.fromLTRB` · `Positioned(` | مابيتقلبوش في الـ RTL |
/// | `Color(0x` بره الـ palette | أي لون جديد = دور ناقص |
/// | `Colors.` غير `transparent` | نفس السبب |
/// | `BorderRadius.circular(<رقم>)` بره app_radius | الاستدارة من السلّم |
///
/// ⚠ **بيشيل التعليقات قبل الفحص.** القواعد دي عن **الكود**، والتوثيق
/// في الكيت بيذكر الممنوعات دي بالاسم عشان يشرح ليه اتشالت.
///
/// الملف ده **بيتنسخ مع الكيت** — المتبنّي اللي يكسر العقد بيعرف في CI
/// بتاعه، مش بعد ٦ شهور.
void main() {
  final root = Directory('lib/design_system');

  /// بيشيل تعليقات السطر والبلوك عشان الفحص يقع على الكود بس.
  String codeOnly(String source) {
    final withoutBlocks = source.replaceAll(
      RegExp(r'/\*.*?\*/', dotAll: true),
      '',
    );
    return withoutBlocks
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');
  }

  List<File> dartFiles() => root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  String nameOf(File f) => f.uri.pathSegments.last;

  test('الفولدر موجود وفيه ملفات', () {
    expect(root.existsSync(), isTrue, reason: 'lib/design_system مش موجود');
    expect(dartFiles().length, greaterThan(20));
  });

  test('كل الـ imports relative — مافيش package: بتاع الكيت', () {
    for (final file in dartFiles()) {
      expect(
        codeOnly(file.readAsStringSync()),
        isNot(contains('package:waqty_user_application')),
        reason:
            '${nameOf(file)} بيستخدم import مطلق — مش هينسخ في تطبيق باسم تاني',
      );
    }
  });

  test('مفيش تبعيات تطبيق', () {
    const banned = <String, String>{
      'package:flutter_bloc': 'state management',
      'package:bloc': 'state management',
      'package:provider': 'state management',
      'package:get_it': 'DI',
      'package:easy_localization': 'لوكلة',
      'package:http': 'شبكة',
      'package:dio': 'شبكة',
      'package:cached_network_image': 'كاش صور',
      'package:intl': 'تنسيق — AppFormat بيعمله بالإيد',
      'dart:io': 'مابيتكمبلش على الويب',
    };

    for (final file in dartFiles()) {
      final code = codeOnly(file.readAsStringSync());
      for (final entry in banned.entries) {
        expect(
          code,
          isNot(contains(entry.key)),
          reason: '${nameOf(file)} بيجرّ ${entry.key} (${entry.value})',
        );
      }
    }
  });

  test('مفيش لوكلة ولا تنقّل ولا cubit جوه أي widget', () {
    const banned = <String>[
      '.tr()',
      'context.tr',
      'context.read<',
      'context.watch<',
      'BlocBuilder',
      'BlocProvider',
      'Navigator.push',
      'Navigator.pop',
      'Navigator.of(',
      'navigatorKey',
    ];

    for (final file in dartFiles()) {
      final code = codeOnly(file.readAsStringSync());
      for (final pattern in banned) {
        expect(
          code,
          isNot(contains(pattern)),
          reason: '${nameOf(file)} فيه "$pattern"',
        );
      }
    }
  });

  test('كل المسافات اتجاهية — RTL مش اختياري', () {
    // ⚠ `EdgeInsets.symmetric` و`.all` و`.zero` متماثلين فمسموحين.
    // اللي بيكسر الاتجاه هو غير المتماثل.
    const banned = <String>[
      'EdgeInsets.only(',
      'EdgeInsets.fromLTRB(',
      'Positioned(',
      'Alignment.centerLeft',
      'Alignment.centerRight',
      'Alignment.topLeft',
      'Alignment.topRight',
      'Alignment.bottomLeft',
      'Alignment.bottomRight',
      'TextDirection.ltr',
    ];

    // ⚠ حدود كلمة: `Border(` من غيرها بتطابق `OutlineInputBorder(`
    // و`CircleBorder(` و`RoundedRectangleBorder(` — تلاتتهم مالهمش
    // اتجاه أصلاً. اللي ممنوع هو `Border(top:, left:, …)` بس.
    final nonDirectionalBorder = RegExp(r'(?<![A-Za-z])Border\(');

    for (final file in dartFiles()) {
      // الاستثناء الوحيد: حقل الـ PIN بيقفل LTR بقصد موثّق.
      if (nameOf(file) == 'app_pin_code_field_widget.dart') continue;

      final code = codeOnly(file.readAsStringSync());
      for (final pattern in banned) {
        expect(
          code,
          isNot(contains(pattern)),
          reason: '${nameOf(file)} فيه "$pattern" — مش هيتقلب في العربي',
        );
      }
      expect(
        nonDirectionalBorder.hasMatch(code),
        isFalse,
        reason:
            '${nameOf(file)} فيه Border() غير اتجاهي — استخدم BorderDirectional',
      );
    }
  });

  test('مفيش لون خام بره app_palette.dart', () {
    for (final file in dartFiles()) {
      if (nameOf(file) == 'app_palette.dart') continue;

      final code = codeOnly(file.readAsStringSync());

      expect(
        code,
        isNot(contains('Color(0x')),
        reason: '${nameOf(file)} فيه لون متكتوب — الدور هو اللي ناقص مش اللون',
      );

      // `Colors.transparent` هو الاستثناء الوحيد: الشفاف مالوش دور.
      //
      // ⚠ حد الكلمة مهم: من غيره الـ regex بيطابق
      // `AppSemanticColors.isDark` — الاسم بينتهي بـ`Colors.`.
      final colorsUse = RegExp(r'(?<![A-Za-z])Colors\.(\w+)')
          .allMatches(code)
          .map((m) => m.group(1)!)
          .where((name) => name != 'transparent')
          .toSet();

      expect(
        colorsUse,
        isEmpty,
        reason: '${nameOf(file)} بيستخدم Colors.$colorsUse',
      );
    }
  });

  test('مفيش استدارة خام بره app_radius.dart', () {
    final literal = RegExp(r'BorderRadius\.circular\(\s*\d');

    for (final file in dartFiles()) {
      if (nameOf(file) == 'app_radius.dart') continue;

      expect(
        literal.hasMatch(codeOnly(file.readAsStringSync())),
        isFalse,
        reason: '${nameOf(file)} فيه استدارة برقم — كلها من AppRadius',
      );
    }
  });

  test('كل widget مصدّر من الـ barrel', () {
    final barrel = File(
      'lib/design_system/design_system.dart',
    ).readAsStringSync();

    final widgetFiles = dartFiles()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/widgets/'))
        .map(nameOf);

    expect(widgetFiles, isNotEmpty);

    for (final name in widgetFiles) {
      expect(
        barrel,
        contains('widgets/$name'),
        reason: '$name مش مصدّر — اللي بيتبنّى الكيت مش هيشوفه',
      );
    }
  });

  test('كل توكن مصدّر من الـ barrel', () {
    final barrel = File(
      'lib/design_system/design_system.dart',
    ).readAsStringSync();

    final tokenFiles = dartFiles()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/tokens/'))
        .map(nameOf);

    for (final name in tokenFiles) {
      expect(barrel, contains('tokens/$name'), reason: '$name مش مصدّر');
    }
  });

  test('الوزن مايعديش w600 — مافيش ملف Bold', () {
    for (final file in dartFiles()) {
      final code = codeOnly(file.readAsStringSync());
      for (final weight in [
        'FontWeight.w700',
        'FontWeight.w800',
        'FontWeight.w900',
        'FontWeight.bold',
      ]) {
        expect(
          code,
          isNot(contains(weight)),
          reason: '${nameOf(file)} فيه $weight — الكيت بيشحن ٣ أوزان بس',
        );
      }
    }
  });

  test('مفيش letterSpacing موجب متكتوب بالإيد', () {
    // فلاتر بيطبّقه **بعد** تشكيل العربي فبيفكّك وصلات الحروف.
    final positive = RegExp(r'letterSpacing:\s*(?!-)(?!0)\d');

    for (final file in dartFiles()) {
      expect(
        positive.hasMatch(codeOnly(file.readAsStringSync())),
        isFalse,
        reason: '${nameOf(file)} فيه letterSpacing موجب',
      );
    }
  });
}
