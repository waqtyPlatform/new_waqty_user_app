class EndPoints {
  /// عنوان الـAPI. بيتبدّل من سطر الأوامر من غير ما تلمس الكود:
  ///
  /// ```bash
  /// # الباك-إند المحلي على محاكي أندرويد (الافتراضي)
  /// flutter run
  ///
  /// # الباك-إند المحلي على iOS أو ويب أو ديسكتوب
  /// flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
  ///
  /// # السيرفر البعيد
  /// flutter run --dart-define=API_BASE_URL=https://waqty.alemtayaz.shop/public
  /// ```
  ///
  /// الافتراضي `10.0.2.2` — ده المنفذ اللي محاكي الأندرويد بيوصل بيه
  /// لـloopback المضيف. `127.0.0.1` جوه المحاكي معناه المحاكي نفسه.
  ///
  /// من غير `/public` في الآخر: `php artisan serve` جذره أصلاً هو
  /// فولدر `public/`، عكس السيرفر البعيد اللي متسطّب تحت مسار فرعي.
  ///
  /// ⚠ الـHTTP العادي شغال في بيلد الديبج بس — شوف
  /// `android/app/src/debug/res/xml/network_security_config.xml`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // static const String _imageBaseUrl = "public/";

  // static String getImageFromApi(String imageUrl) {
  //   return baseUrl + _imageBaseUrl + imageUrl;
  // }
}
