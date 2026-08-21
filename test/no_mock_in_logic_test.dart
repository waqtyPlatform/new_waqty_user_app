import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **الـcubit مابيعرفش عن الموك حاجة.**
///
/// ده التعريف الميكانيكي لـ«الفيتشر دي اتربطت». الـcubit بيكلّم repo واحد،
/// والـrepo هو اللي بيختار بين `<Name>RemoteService` و`<Name>MockService`
/// من `DataSource`. لو cubit بيعمل `import '…/core/mock/…'` يبقى المصدر
/// متزرّع في المنطق، والمبدّل مالوش أي أثر عليه.
///
/// ## الحالة دلوقتي
///
/// **[notMigratedYet] فاضية.** كل الـcubits بتعدّي على repo، ومفيش واحد
/// بيقرا من الموك مباشرة.
///
/// الاختبار بيفضل موجود **كحارس ضد الرجوع لورا**: أي cubit جديد يستورد
/// `core/mock` هيوقّع البناء.
///
/// ⚠ **ماتزوّدش سطر في القايمة عشان تخلي الاختبار يعدّي.** ده بيعكس اتجاه
/// الأداة: هي موجودة عشان الربط مايرجعش لورا، مش عشان تسجّل التراجع.
void main() {
  /// الـcubits اللي **لسه** بتقرا من الموك مباشرة — **فاضية**.
  ///
  /// المسارات نسبية لـ`lib/features/`.
  const Set<String> notMigratedYet = <String>{};

  // اللي اتربط، بالترتيب:
  //
  // المرحلة ١ — مسار التصفّح:
  //    home/home/logic/home_cubit.dart
  //    providers/providers_list/logic/providers_list_cubit.dart
  //    service_provider_details/…/service_provider_details_cubit.dart
  //
  // المرحلة ٢ — قراية الحجوزات:
  //    booking/my_bookings/logic/my_bookings_cubit.dart
  //    booking/booking_details/logic/booking_details_cubit.dart
  //
  // المرحلة ٣ — إنشاء الحجز:
  //    booking/create_booking/logic/create_booking_cubit.dart
  //
  // المرحلة ٥ — قايمة الانتظار:
  //    booking/waitlist/logic/waitlist_cubit.dart
  //
  // المرحلة ٦ — الحساب والمدفوعات:
  //    account/account/logic/account_cubit.dart
  //
  // المرحلة ٨ — داخل الفرع والقشرة:
  //    booking/in_branch/logic/in_branch_cubit.dart
  //    home/button_navigation_bar/logic/button_navigation_bar_cubit.dart

  final featuresDir = Directory('lib/features');

  /// كل ملفات الـ`logic/` تحت `lib/features/`، بمسار نسبي بشرطة عادية.
  List<String> logicFiles() {
    if (!featuresDir.existsSync()) return const [];

    return featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceAll(r'\', '/'))
        .where((p) => p.endsWith('.dart'))
        .where((p) => p.contains('/logic/'))
        .map((p) => p.split('lib/features/').last)
        .toList()
      ..sort();
  }

  bool importsMock(String relativePath) =>
      File('lib/features/$relativePath')
          .readAsStringSync()
          .contains('core/mock/');

  test('مفيش cubit بيقرا من core/mock', () {
    final offenders = logicFiles()
        .where(importsMock)
        .where((p) => !notMigratedYet.contains(p))
        .toList();

    expect(
      offenders,
      isEmpty,
      reason:
          'الملفات دي بتستورد `core/mock` في الـlogic. المصدر مكانه الـrepo:\n'
          '  ${offenders.join('\n  ')}\n\n'
          'اعمل `<Name>MockService` بينفّذ نفس عقد الـservice، وخلي الـrepo '
          'يختار بينه وبين الـremote من `DataSource`.',
    );
  });

  test('قايمة الشغل الفاضل مافيهاش أسماء ميتة', () {
    // لو ملف اتنقل أو اتمسح والسطر فضل هنا، الحارس بيفضل مطفّي عليه
    // للأبد من غير ما حد ياخد باله.
    final present = logicFiles().toSet();
    final stale = notMigratedYet.where((p) => !present.contains(p)).toList();

    expect(
      stale,
      isEmpty,
      reason:
          'السطور دي في `notMigratedYet` بتشاور على ملفات مش موجودة — '
          'اتنقلت أو اتمسحت. شيلها:\n  ${stale.join('\n  ')}',
    );
  });

  test('اللي اتربط اتشال من القايمة', () {
    // الاتجاه التاني: ملف في القايمة بس مابقاش بيستورد موك = خلص ربط
    // ونسينا نشيله. سيبه في القايمة بيخلي الحارس ساكت عليه لو رجع تاني.
    final migrated = notMigratedYet
        .where((p) => File('lib/features/$p').existsSync())
        .where((p) => !importsMock(p))
        .toList();

    expect(
      migrated,
      isEmpty,
      reason:
          'الملفات دي مابقتش بتستورد `core/mock` — شيلها من `notMigratedYet` '
          'عشان الحارس يحميها:\n  ${migrated.join('\n  ')}',
    );
  });
}
