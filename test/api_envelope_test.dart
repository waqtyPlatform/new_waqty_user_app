import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:waqty_user_application/core/api/api_envelope.dart';

/// **فك ظرف الرد مابيرميش أبدًا.**
///
/// `ApiResponse` (`app/Http/Helpers/ApiResponse.php`) بيبني:
///
/// ```json
/// {"success": true,  "message": "…", "data": …, "meta": {"pagination": {…}}}
/// {"success": false, "message": "…", "errors": {"phone": ["…"]}, "code": "…"}
/// ```
///
/// و`message`/`data`/`meta`/`errors`/`code` **كلهم اختياريين** — الهيلبر بيحطهم
/// بس لما مايبقوش `null`.
///
/// ⚠ **بس مش كل رد بيعدّي على الهيلبر.** الـ٤٢٩ بيتولّد من ميدلوير `throttle`
/// بتاع لارافيل، و٥٠٠ وراه `php artisan serve` بيرجّع **HTML**. النسخة القديمة
/// من `ServerFailure.fromJson` كانت `json["message"]` على نوع `String` مش
/// `String?` — يعني كانت بترمي `TypeError` **جوّه معالج الخطأ**، فالمستخدم
/// يشوف كراش بدل رسالة.
void main() {
  /// ⚠ **بنبني من بايتات UTF-8 مش من نص.**
  ///
  /// `http.Response(String, code)` بيرمّز بـlatin-1 وبيرمي على أي حرف عربي.
  /// ودي **مش تفصيلة اختبار** — هي نفس المشكلة اللي خلت `ApiEnvelope` تقرا
  /// `bodyBytes` بـUTF-8 بدل `.body`.
  http.Response res(int code, Object? body) => http.Response.bytes(
    body == null ? const [] : utf8.encode(jsonEncode(body)),
    code,
  );

  group('نجاح', () {
    test('الظرف الكامل بيتفك صح', () {
      final e = ApiEnvelope.of(
        res(200, {
          'success': true,
          'message': 'تم',
          'data': [
            {'uuid': 'a'},
          ],
          'meta': {
            'pagination': {'current_page': 1, 'last_page': 24},
          },
        }),
      );

      expect(e.isOk, isTrue);
      expect(e.success, isTrue);
      expect(e.message, 'تم');
      expect(e.data, isA<List>());
      expect(e.meta['pagination'], isNotNull);
      expect(e.errors, isEmpty);
    });

    test('من غير message ولا meta — الاتنين اختياريين', () {
      final e = ApiEnvelope.of(
        res(200, {
          'success': true,
          'data': {'uuid': 'a'},
        }),
      );

      expect(e.isOk, isTrue);
      expect(e.message, isNull);
      expect(e.meta, isEmpty);
    });

    test('جسم فاضي (204 مثلاً)', () {
      final e = ApiEnvelope.of(res(204, null));

      expect(e.isOk, isTrue);
      expect(e.success, isTrue);
      expect(e.data, isNull);
    });

    test('مصفوفة في الجذر — كونترولر رجّع get() من غير الهيلبر', () {
      final e = ApiEnvelope.of(
        res(200, [
          {'uuid': 'a'},
        ]),
      );

      expect(e.isOk, isTrue);
      expect(e.data, isA<List>());
    });
  });

  group('فشل', () {
    test('٤٢٢ — الحقول بتتقرا لستة', () {
      final e = ApiEnvelope.of(
        res(422, {
          'success': false,
          'message': 'The given data was invalid.',
          'errors': {
            'preferred_date': ['التاريخ مطلوب'],
            'preferred_time': ['الوقت مطلوب'],
          },
        }),
      );

      expect(e.success, isFalse);
      expect(e.errors['preferred_date'], ['التاريخ مطلوب']);
      expect(e.errors.length, 2);
      expect(e.firstFieldError, isNotNull);
    });

    test('٤٢٢ — قيمة نص مفرد بتتلف لستة', () {
      // `ApiResponse::error` بيعمل `is_array` check، فالاتنين ممكنين.
      final e = ApiEnvelope.of(
        res(422, {
          'success': false,
          'errors': {'phone': 'الرقم مستخدم'},
        }),
      );

      expect(e.errors['phone'], ['الرقم مستخدم']);
    });

    test('٤٢٩ — من ميدلوير throttle، من غير success', () {
      final e = ApiEnvelope.of(res(429, {'message': 'Too Many Attempts.'}));

      expect(e.isOk, isFalse);
      // مفيش مفتاح `success` — الحالة هي الحكم.
      expect(e.success, isFalse);
      expect(e.message, 'Too Many Attempts.');
    });

    test('⚠ ٥٠٠ بجسم HTML — مابيرميش', () {
      final e = ApiEnvelope.of(
        http.Response('<!DOCTYPE html><h1>Server Error</h1>', 500),
      );

      expect(e.isOk, isFalse);
      expect(e.success, isFalse);
      expect(e.message, isNull);
      expect(e.rawBody, contains('Server Error'));
    });

    test('⚠ جسم مقطوع (JSON ناقص) — مابيرميش', () {
      final e = ApiEnvelope.of(http.Response('{"success": tru', 200));

      expect(e.success, isFalse);
      expect(e.rawBody, isNotNull);
    });

    test('⚠ عربي خام من غير charset في الهيدر — بيوصل سليم', () {
      // لارافيل بيبعت `application/json` أصلع (متحقّق منه بـ`curl -D -`)،
      // و`http` بيفك `.body` بـlatin-1 لما مافيش charset. شغال النهاردة لأن
      // `json_encode` بيهرب العربي، بس أول ما حد يضيف `JSON_UNESCAPED_UNICODE`
      // كل رسالة تبقى طلاسم في صمت. الاختبار ده بيقفل الباب ده.
      final e = ApiEnvelope.of(
        http.Response.bytes(
          utf8.encode(jsonEncode({'success': true, 'message': 'تم الحجز'})),
          200,
          headers: const {'content-type': 'application/json'},
        ),
      );

      expect(e.message, 'تم الحجز');
    });

    test('success: false جوّه ٢٠٠ — لازم تتمسك', () {
      // بعض الكونترولرز بتبعت خطأ داخل ٢٠٠؛ الاعتماد على الحالة لوحدها
      // كان هيسيب الخطأ يعدّي كنجاح.
      final e = ApiEnvelope.of(
        res(200, {'success': false, 'message': 'بيانات الدخول غير صحيحة'}),
      );

      expect(e.isOk, isTrue, reason: 'الحالة نفسها ٢٠٠');
      expect(e.success, isFalse, reason: 'بس الظرف بيقول فشل');
    });
  });
}
