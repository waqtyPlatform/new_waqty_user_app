import 'package:http/http.dart' as http;

/// عقد نقل الـHTTP. الطبقة اللي فوقه ([ApiClient]) هي اللي بتفهم الردود.
abstract class ApiConsumer {
  /// ⚠ [query] لازمة مش رفاهية: كل `public/*` بيتفلتر بـquery params،
  /// والبحث عربي — لو حد بنى الـURL بإيده هينسى الترميز والطلب يرجع فاضي.
  /// القيم `null` بتتشال، والباقي بيتحوّل نص.
  Future<http.Response> get(
    String path,
    Map<String, String>? headers, {
    Map<String, dynamic>? query,
  });

  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );

  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );

  /// ⚠ إلغاء الحجز `PATCH /api/user/bookings/{uuid}/cancel` — من غير الفعل
  /// ده مفيش طريقة ينتدى بيها خالص.
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );

  Future<http.Response> delete(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );

  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  );
}
