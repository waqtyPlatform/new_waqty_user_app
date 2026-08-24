import 'package:equatable/equatable.dart';

/// كل الأخطاء بتوصل للـcubit في الشكل ده.
///
/// ⚠ **كل نوع جديد لازم يفضل فيه `.message` عربي جاهز للعرض.** الـcubits
/// بتعمل `.fold((failure) => emit(ErrorState(failure.message)))` — لو نوع
/// جديد كسر العقد ده، كل شاشة هتحتاج تعديل.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// خطأ عام من السيرفر — الرسالة جاية منه.
class ServerFailure extends Failure {
  const ServerFailure({required super.message});

  /// ⚠ **مابترميش على جسم ناقص.**
  ///
  /// النسخة القديمة كانت `ServerFailure(message: json["message"])` و`message`
  /// نوعها `String` مش `String?` — يعني أي رد من غير المفتاح ده كان بيرمي
  /// `TypeError` **جوّه معالج الخطأ نفسه**، فالمستخدم يشوف كراش بدل رسالة.
  /// بيحصل فعلاً مع ٤٢٩، لأنها بتتولّد من ميدلوير `throttle` بتاع لارافيل
  /// مش من `ApiResponse`.
  factory ServerFailure.fromJson(Map<String, dynamic> json) =>
      ServerFailure(message: json['message'] as String? ?? fallbackMessage);

  /// الرسالة اللي بتتعرض لما السيرفر مايبعتش واحدة.
  static const String fallbackMessage = 'حصل خطأ، جرّب تاني';
}

/// **٤٢٢** — الحقول اللي السيرفر رفضها.
///
/// [fields] بمفاتيح الـAPI (`phone` · `email` · `booking_date`) عشان الشاشة
/// تقدر تحط الرسالة تحت الحقل الصح بدل سناك بار عام.
class ValidationFailure extends Failure {
  final Map<String, List<String>> fields;

  const ValidationFailure({required super.message, this.fields = const {}});

  /// أول رسالة على مستوى حقل — بتنفع لما الشاشة مالهاش حقول مربوطة.
  String? get firstFieldMessage {
    for (final messages in fields.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return null;
  }

  @override
  List<Object> get props => [message, fields];
}

/// **٤٠١** — التوكن مرفوض. `SessionStore.expire()` بتتنادى وبنترمي على الدخول.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'الجلسة انتهت، سجّل دخول تاني'});
}

/// **٤٢٩** — عدّينا حد الطلبات.
///
/// مهمة في ويزارد الحجز: `public/bookings/*` عليها `throttle:60,1`، وشريط
/// التواريخ ممكن يحرقها في ثواني. الحالة دي **قابلة لإعادة المحاولة** —
/// الشاشة تعرض «جرّب تاني» مش طريق مسدود.
class ThrottleFailure extends Failure {
  const ThrottleFailure({
    super.message = 'طلبات كتير في وقت قصير، استنى شوية وجرّب تاني',
  });
}

/// مفيش اتصال بالسيرفر أصلاً — الطلب ما خرجش أو ما رجعش.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'مفيش اتصال بالإنترنت'});
}
