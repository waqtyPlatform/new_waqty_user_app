import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

/// إعداد Firebase — **مش متملّي لسه**.
///
/// ## اللي لازم يحصل عشان الإشعارات تشتغل
///
/// القيم اللي تحت **مش أسرار ولا مخترعة** — هي علامات فاضية. الأرقام
/// الحقيقية بتتولّد من مشروع Firebase بتاع Waqty، وهي مربوطة بحساب Google
/// بتاع الفريق فمحدش يقدر يخترعها.
///
/// ```bash
/// # الطريقة الرسمية — بتكتب الملف ده كله لوحدها
/// dart pub global activate flutterfire_cli
/// flutterfire configure --project=<waqty-firebase-project>
/// ```
///
/// ده بيعمل حاجتين: بيملّي الملف ده، وبينزّل `google-services.json` في
/// `android/app/`.
///
/// ## ليه الملف موجود وهو فاضي
///
/// [isConfigured] بيخلي الأبلكيشن **يقلع عادي من غير إعداد**:
/// `FirebaseNotificationService.init()` بيقرا الفلاج ويرجع من غير ما يعمل
/// حاجة. من غير الحارس ده `Firebase.initializeApp()` كان هيرمي وقت الإقلاع
/// ويوقّع الأبلكيشن على كل الأجهزة.
///
/// يعني: كل السباكة شغّالة ومختبَرة، والحتة الوحيدة الناقصة هي الأرقام دي.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  /// العلامة اللي بتقول «القيمة دي لسه فاضية».
  static const String _placeholder = 'REPLACE_ME';

  /// **هل Firebase متظبط؟**
  ///
  /// بيتقرا في `FirebaseNotificationService.init()` قبل أي حاجة.
  static bool get isConfigured =>
      !_android.apiKey.contains(_placeholder) &&
      _android.apiKey.isNotEmpty;

  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _ios,
    _ => _android,
  };

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: _placeholder,
    appId: _placeholder,
    messagingSenderId: _placeholder,
    projectId: _placeholder,
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: _placeholder,
    appId: _placeholder,
    messagingSenderId: _placeholder,
    projectId: _placeholder,
    iosBundleId: 'com.example.waqtyUserApplication',
  );
}
