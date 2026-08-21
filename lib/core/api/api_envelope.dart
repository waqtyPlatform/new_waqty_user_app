import 'dart:convert';

import 'package:http/http.dart' as http;

/// ظرف رد الباك-إند، مفكوك **مرة واحدة** في مكان واحد.
///
/// الشكل اللي `ApiResponse` بيبنيه (`app/Http/Helpers/ApiResponse.php`):
///
/// ```json
/// // نجاح
/// {"success": true, "message": "…", "data": …, "meta": {"pagination": {…}}}
/// // فشل
/// {"success": false, "message": "…", "errors": {"phone": ["…"]}, "code": "…"}
/// ```
///
/// `message` و`data` و`meta` و`errors` و`code` **كلهم اختياريين** — الهيلبر
/// بيحطهم بس لما يبقوا مش `null`.
///
/// ⚠ **مش كل رد بيعدّي على `ApiResponse`.** الـ429 بيتولّد من ميدلوير
/// `throttle` بتاع لارافيل نفسه، و500 وراه `php artisan serve` بيرجّع
/// **HTML** مش JSON. عشان كده [of] مابترميش أبدًا — بترجّع ظرف بجسم خام
/// بدل ما تفرقع في وش المستخدم.
class ApiEnvelope {
  final int statusCode;
  final bool success;
  final String? message;
  final dynamic data;
  final Map<String, dynamic> meta;
  final Map<String, List<String>> errors;
  final String? code;

  /// الجسم زي ما جه — بيتملى بس لما الفك يفشل، عشان اللوج.
  final String? rawBody;

  const ApiEnvelope({
    required this.statusCode,
    required this.success,
    this.message,
    this.data,
    this.meta = const {},
    this.errors = const {},
    this.code,
    this.rawBody,
  });

  bool get isOk => statusCode >= 200 && statusCode < 300;

  /// أول رسالة خطأ على مستوى الحقل — بتنفع كرسالة عرض لما `message` عامة.
  String? get firstFieldError {
    for (final messages in errors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return null;
  }

  /// ⚠ **بنقرا `bodyBytes` بـUTF-8، مش `response.body`.**
  ///
  /// `http` بيفك `.body` بالترميز اللي في `Content-Type`، **وبيقع على
  /// latin-1 لما مافيش charset**. ولارافيل بيبعت `application/json` أصلع
  /// (متحقّق منه: `curl -D -` على `/api/user/auth/login`).
  ///
  /// شغال النهاردة **بالصدفة** لأن `json_encode` بيهرب العربي لـ`\uXXXX`
  /// فالبايتات ASCII صافية، وlatin-1 على ASCII بيرجّع نفسه. بس أول ما حد
  /// يضيف `JSON_UNESCAPED_UNICODE` في الباك-إند، كل رسالة عربية تبقى طلاسم
  /// **من غير أي خطأ**. UTF-8 على ASCII كمان بيرجّع نفسه، فالقراية دي صح في
  /// الحالتين.
  static String _decode(http.Response response) {
    try {
      return utf8.decode(response.bodyBytes);
    } catch (_) {
      // بايتات مش UTF-8 صالحة — نرجع لتصرّف الحزمة الافتراضي.
      return response.body;
    }
  }

  factory ApiEnvelope.of(http.Response response) {
    final body = _decode(response);

    if (body.isEmpty) {
      return ApiEnvelope(
        statusCode: response.statusCode,
        success: response.statusCode >= 200 && response.statusCode < 300,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      // HTML من صفحة خطأ لارافيل، أو نص عادي من بروكسي.
      return ApiEnvelope(
        statusCode: response.statusCode,
        success: false,
        rawBody: body,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      // مصفوفة في الجذر — بيحصل لما كونترولر يرجّع `->get()` من غير الهيلبر.
      return ApiEnvelope(
        statusCode: response.statusCode,
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: decoded,
      );
    }

    return ApiEnvelope(
      statusCode: response.statusCode,
      // `success` مش مضمونة الوجود (ردود لارافيل الجاهزة زي 429 مافيهاش)،
      // فالحالة هي الحكم لما تكون ناقصة.
      success:
          decoded['success'] as bool? ??
          (response.statusCode >= 200 && response.statusCode < 300),
      message: decoded['message'] as String?,
      data: decoded['data'],
      meta: decoded['meta'] is Map
          ? Map<String, dynamic>.from(decoded['meta'] as Map)
          : const {},
      errors: _parseErrors(decoded['errors']),
      code: decoded['code'] as String?,
    );
  }

  /// `{"phone": ["مطلوب"], "email": "مستخدم"}` → القيمة دايمًا لستة.
  ///
  /// لارافيل بيبعت لستة، بس `ApiResponse::error` بيسمح بنص مفرد كمان
  /// (بيعمل `is_array` check) — فالاتنين لازم يتقروا.
  static Map<String, List<String>> _parseErrors(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        out['$key'] = value.map((e) => '$e').toList();
      } else if (value != null) {
        out['$key'] = ['$value'];
      }
    });
    return out;
  }
}
