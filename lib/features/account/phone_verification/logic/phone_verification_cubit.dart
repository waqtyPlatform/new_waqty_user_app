import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/utils/app_phone.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/repo/phone_verification_repo.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_state.dart';

/// تأكيد رقم التليفون — وربط سجلات الفرع بالحساب في نفس الفعل.
///
/// ## ليه الشاشة دي مهمة أكتر مما شكلها
///
/// `PackageEntitlementService::listForUser()` بيطابق على
/// `provider_customers.platform_user_id`. لو الريسبشن عمل العميلة من رقم
/// تليفون وما اتربطش بحساب المنصة، **كل** endpoint بتاع الـentitlements
/// بيرجّع array فاضية لعميلة ماسكة باقة مدفوعة. الشاشة دي هي اللي بتقفل
/// الفجوة دي.
///
/// ⚠ **مافيش «تأكيد» من غير «ربط».** السيرفر بيعمل الاتنين في ترانزاكشن
/// واحدة (`UserPhoneVerificationService::verify:71` → `linkCustomers->execute`)،
/// فالكيوبت مابيقسّمهاش لخطوتين — لو قسّمها هيبقى فيه حالة وسط مالهاش وجود
/// في الباك إند وهنبني عليها UI بتكدب.
class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  PhoneVerificationCubit(this._repo) : super(const PhoneVerificationInitial());

  final PhoneVerificationRepo _repo;

  /// كود الدولة الوحيد المدعوم — السوق مصر (CLAUDE.md).
  static const String countryIso2 = 'EG';

  /// نفس مدة شاشات الـOTP التانية — ماينفعش شاشة تستنى دقيقتين وشاشة ٣٠ ثانية.
  static const int resendCooldownSeconds = 120;

  /// الخطوة الحالية. حالة مقيمة، فهي حقل مش state — شوف
  /// [PhoneVerificationStep].
  PhoneVerificationStep step = PhoneVerificationStep.phone;

  /// الرقم اللي اتبعتله كود.
  ///
  /// بيتخزّن عشان خطوة التأكيد تستخدم **نفسه** مش اللي في الحقل — العميلة
  /// ممكن تكون عدّلت الحقل وهي مستنية الكود، وساعتها التأكيد كان هيتبعت
  /// لرقم غير اللي الكود راح له.
  String pendingPhone = '';

  int resendSeconds = 0;
  Timer? _timer;

  bool get canResend => resendSeconds == 0;

  String get timerText {
    final minutes = (resendSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (resendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> sendCode(String rawPhone) async {
    final phone = AppPhone.toApiFormat(rawPhone);
    emit(const PhoneVerificationSending());

    final result = await _repo.sendCode(phone: phone, countryIso2: countryIso2);
    if (isClosed) return;

    result.fold((failure) => emit(_failureState(failure)), (_) {
      pendingPhone = phone;
      step = PhoneVerificationStep.code;
      _startTimer();
      emit(PhoneVerificationCodeSent(phone));
    });
  }

  /// إعادة إرسال — بتستخدم [pendingPhone] مش الحقل.
  Future<void> resend() async {
    if (!canResend || pendingPhone.isEmpty) return;
    await sendCode(pendingPhone);
  }

  Future<void> verify(String otp) async {
    emit(const PhoneVerificationSubmitting());

    final result = await _repo.verify(
      phone: pendingPhone,
      countryIso2: countryIso2,
      otp: otp,
    );
    if (isClosed) return;

    result.fold((failure) {
      final failed = _failureState(failure);
      // التعارض بيرجّع لخطوة الرقم — الكود مافيهوش غلط، الرقم نفسه هو
      // المشكلة، وإبقاء الشاشة على خانات الكود بيخلّي العميلة تعيد كتابة
      // كود صح لحد ما تيأس.
      if (failed.isConflict) {
        _stopTimer();
        step = PhoneVerificationStep.phone;
      }
      emit(failed);
    }, (claim) {
      _stopTimer();
      emit(PhoneVerificationSucceeded(claim));
    });
  }

  /// بيرجّع لخطوة الرقم — «غيّر الرقم».
  void restart() {
    _stopTimer();
    pendingPhone = '';
    step = PhoneVerificationStep.phone;
    emit(const PhoneVerificationInitial());
  }

  void _startTimer() {
    resendSeconds = resendCooldownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      resendSeconds--;
      emit(PhoneVerificationTick(resendSeconds));
      if (resendSeconds <= 0) _stopTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// **بيترجم الفشل لحقل** — عشان الرسالة تقعد جنب اللي غلط.
  ///
  /// التمييز ده هو الفرق بين «الكود غلط، اكتبه تاني» و«الرقم مش بتاعك،
  /// كلّم الدعم». الاتنين 422 على السيرفر، ولو اتعرضوا بنفس النص العميلة
  /// هتفضل تعيد كتابة كود صح مش هيعدّي أبدًا.
  PhoneVerificationFailed _failureState(Failure failure) {
    if (failure is ValidationFailure) {
      final field = failure.fields.keys.firstWhere(
        (key) => key == 'otp' || key == 'phone',
        orElse: () => '',
      );
      return PhoneVerificationFailed(
        message: failure.firstFieldMessage ?? failure.message,
        field: field.isEmpty ? null : field,
      );
    }

    return PhoneVerificationFailed(message: failure.message);
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }

  static PhoneVerificationCubit get(context) => BlocProvider.of(context);
}
