class StatusCode {
  static const int ok = 200;
  static const int created = 201;

  /// ⚠ **التلاتة دول مش أكواد HTTP** — دي اتفاقات داخلية قديمة، والـ٦ auth
  /// services بيقروهم وشغالين. ماتلمسهمش.
  static const int okWithOutValidation = 101;
  static const int badRequest = 100;

  /// الحساب موجود بس الإيميل/الموبايل لسه مش متحقق منه.
  static const int notVerified = 403;

  /// التوكن مرفوض → `SessionStore.expire()` → رمية على شاشة الدخول.
  static const int unauthorized = 401;

  /// فشل تحقق الحقول — الجسم فيه `errors` بمفاتيح الـAPI.
  static const int unprocessable = 422;

  /// عدّينا حد الطلبات. `public/bookings/*` عليها `throttle:60,1`.
  static const int tooManyRequests = 429;

  static const int serverError = 500;
}
