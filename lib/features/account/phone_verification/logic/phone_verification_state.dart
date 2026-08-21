import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';

/// خطوة الشاشة — **حقل في الكيوبت مش state**.
///
/// ## ليه مش state
///
/// عداد إعادة الإرسال بينبض كل ثانية. لو الخطوة كانت state، كل نبضة كانت
/// هتدوس عليها ولازم كل tick يعيد يقول «وإحنا لسه على خطوة الكود» — يعني
/// معلومة بتتكرر ٦٠ مرة وأول ما تُنسى الشاشة بترجع لخطوة الرقم في نص
/// الإدخال. الخطوة بتتغيّر مرتين في عمر الشاشة كلها، فهي **حالة مقيمة**
/// مش حدث.
enum PhoneVerificationStep { phone, code }

/// حالات تأكيد الرقم — **أحداث بتحصل، مش المكان اللي إحنا فيه**.
sealed class PhoneVerificationState {
  const PhoneVerificationState();
}

class PhoneVerificationInitial extends PhoneVerificationState {
  const PhoneVerificationInitial();
}

/// بنبعت الكود.
class PhoneVerificationSending extends PhoneVerificationState {
  const PhoneVerificationSending();
}

/// الكود اتبعت — الخطوة بقت [PhoneVerificationStep.code].
class PhoneVerificationCodeSent extends PhoneVerificationState {
  const PhoneVerificationCodeSent(this.phone);

  final String phone;
}

/// نبضة عداد إعادة الإرسال.
class PhoneVerificationTick extends PhoneVerificationState {
  const PhoneVerificationTick(this.remainingSeconds);

  final int remainingSeconds;
}

/// بنأكّد الكود.
class PhoneVerificationSubmitting extends PhoneVerificationState {
  const PhoneVerificationSubmitting();
}

/// اتأكّد — و[result] بيقول **إيه اللي اترّبط**، مش مجرد نجاح.
class PhoneVerificationSucceeded extends PhoneVerificationState {
  const PhoneVerificationSucceeded(this.result);

  final PhoneClaimResultUiModel result;
}

/// فشل — [field] بيقول الرسالة تتحط عند أنهي حقل.
///
/// `'otp'` = الكود غلط، الشاشة تفضل على خطوة الكود بقيمتها.
/// `'phone'` = الرقم على حساب تاني — **مش غلطة إدخال**، ودي بترجّع لخطوة
/// الرقم وبتوجّه للدعم.
/// `null` = خطأ عام (شبكة/سيرفر).
class PhoneVerificationFailed extends PhoneVerificationState {
  const PhoneVerificationFailed({required this.message, this.field});

  final String message;
  final String? field;

  bool get isConflict => field == 'phone';
  bool get isOtpError => field == 'otp';
}
