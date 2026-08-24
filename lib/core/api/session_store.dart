import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';

/// توكن الجلسة — **في الذاكرة**، ومنه بيتقرا في كل طلب.
///
/// ## ليه في الذاكرة مش من `flutter_secure_storage` كل مرة
///
/// الـ[AppInterceptor] بيلزق هيدر `Authorization` على **كل** طلب.
/// `flutter_secure_storage` على أندرويد بيعدّي على Keystore، وده نداء
/// عبر الـplatform channel — تكلفته مش مهملة لو اتنادى مرة كل request،
/// خصوصًا في شاشة زي الويزارد اللي بتطلب تواريخ ومواعيد ورا بعض.
///
/// التخزين الدايم بيفضل `CacheHelper` زي ما هو — دي بس نسخة ساخنة.
/// [hydrate] بتتنادى مرة واحدة في `main()` قبل ما الشجرة تتبني.
///
/// ## انتهاء الجلسة
///
/// [expired] بينط لما أي رد يرجّع **401**. `my_app.dart` سامعها وبيرمي على
/// شاشة الدخول. بتتصفّر بـ[save] لما دخول جديد ينجح، عشان الرمية تحصل مرة
/// واحدة مش كل ما نداء متوازي يفشل.
class SessionStore {
  String? _token;

  /// بينط مرة واحدة لما التوكن يبقى مرفوض من السيرفر.
  final ValueNotifier<bool> expired = ValueNotifier<bool>(false);

  /// التوكن الحالي — `null` لو مفيش جلسة.
  ///
  /// بيرجّع `null` كمان لو المخزّن نص فاضي: الـ`CacheHelper` بيرجّع `''`
  /// لما المفتاح مش موجود، ولزق `Bearer ` على فراغ بيبعت هيدر مكسور
  /// للسيرفر بدل ما مايبعتش خالص.
  String? get token => (_token != null && _token!.isNotEmpty) ? _token : null;

  bool get hasToken => token != null;

  /// بتقرا المخزّن مرة واحدة وقت الإقلاع.
  Future<void> hydrate() async {
    _token = await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared);
  }

  /// بتحفظ التوكن في الذاكرة **وفي المخزن الآمن**، وبتصفّر علامة الانتهاء.
  Future<void> save(String token) async {
    _token = token;
    expired.value = false;
    await CacheHelper.setSecuredString(ConstantKeys.saveTokenToShared, token);
  }

  /// بتمسح الجلسة من الذاكرة **ومن المخزن**.
  ///
  /// ⚠ الخروج لازم يعدّي من هنا مش من `CacheHelper` لوحده — مسح المخزن
  /// من غير مسح النسخة الساخنة بيسيب التوكن شغال لحد ما الأبلكيشن يتقفل.
  Future<void> clear() async {
    _token = null;
    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
  }

  /// بتعلن إن السيرفر رفض التوكن. بتمسح الجلسة وبتنط مرة واحدة بس.
  Future<void> expire() async {
    if (expired.value) return;
    await clear();
    expired.value = true;
  }
}
