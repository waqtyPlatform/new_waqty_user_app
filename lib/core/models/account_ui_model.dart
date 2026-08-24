import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض لبيانات الحساب.
class AccountUiModel {
  final String name;
  final String email;
  final String phone;
  final String imagePath;

  /// إمتى العميلة أكّدت رقم تليفونها — **مصدر الحقيقة الوحيد لحالة التأكيد**.
  ///
  /// بيجي من `users.phone_verified_at` جوه `/me`. الشيب في شاشة الحساب
  /// والحالات الفاضية في «باقاتي» و«حجوزاتي» كلهم بيتفرّعوا عليه، و**مافيش
  /// نسخة محلية** من الحالة دي: لو التأكيد اتعمل من جهاز تاني أو اتلغى من
  /// الأدمن، التطبيق لازم يعرف من السيرفر مش من ذاكرته.
  ///
  /// `null` = مش مأكّد.
  final DateTime? phoneVerifiedAt;

  const AccountUiModel({
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath = '',
    this.phoneVerifiedAt,
  });

  /// الرقم مأكّد؟ — الاختصار اللي الـwidgets بتسأله.
  bool get isPhoneVerified => phoneVerifiedAt != null;

  /// `GET /api/user/auth/me` — **بيرجّع موديل `User` خام مش مورد**:
  ///
  /// ```json
  /// {"id":1,"name":"Layla Hassan","email":"…","uuid":"01K…",
  ///  "phone":"01113000000","normalized_phone":"+201113000000",
  ///  "date_birth":"1994-03-11T21:00:00.000000Z","gender":"female",
  ///  "image_path":null,"active":true,"blocked":false,"banned":false,
  ///  "phone_verified_at":"…","email_verified_at":"…"}
  /// ```
  ///
  /// ⚠ **بناخد `phone` مش `normalized_phone`.** الشاشة بتعرض الرقم زي ما
  /// العميل كتبه (`01113000000`)، والمطبّع (`+201113000000`) شكل داخلي
  /// للباك-إند. شوف `AppPhone` — الطرفين مختلفين على الشكل ده أصلاً.
  factory AccountUiModel.fromJson(Map<String, dynamic> json) => AccountUiModel(
    name: JsonParse.stringValue(json['name']),
    email: JsonParse.stringValue(json['email']),
    phone: JsonParse.stringValue(json['phone']),
    imagePath: JsonParse.stringValue(json['image_path']),
    phoneVerifiedAt: JsonParse.dateOrNull(json['phone_verified_at']),
  );

  /// أول حرف من الاسم — بيتعرض في الدايرة لو مفيش صورة.
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '؟' : trimmed.substring(0, 1);
  }
}
