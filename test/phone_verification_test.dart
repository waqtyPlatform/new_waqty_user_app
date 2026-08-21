import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_account.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/repo/phone_verification_repo.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_mock_service.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_cubit.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_state.dart';
import 'package:waqty_user_application/features/account/phone_verification/ui/widgets/phone_claim_result_band_widget.dart';

/// **تأكيد الرقم — الشاشة اللي بتحوّل شاشة فاضية غلط لشاشة فيها فلوس العميلة.**
///
/// الاختبار الأهم هنا هو **التفريق بين نوعين من الـ422**: الكود الغلط
/// والرقم اللي على حساب تاني. الاتنين بيرجعوا 422 من لارافيل، ولو التطبيق
/// عاملهم واحد، العميلة اللي رقمها على حساب تاني هتفضل تكتب كود صح مش
/// هيعدّي أبدًا ومش هتعرف ليه.
void main() {
  PhoneVerificationCubit build() => PhoneVerificationCubit(
    const PhoneVerificationRepo(
      PhoneVerificationMockService(),
      PhoneVerificationMockService(),
    ),
  );

  setUp(() {
    MockConfig.scenario = MockScenario.happyPath;
    MockConfig.delay = Duration.zero;
  });
  tearDown(() {
    MockConfig.scenario = MockScenario.happyPath;
  });

  group('الكيوبت', () {
    test('إرسال الكود بينقل لخطوة الكود وبيحفظ الرقم مطبّع', () async {
      final cubit = build();
      await cubit.sendCode('+201113000000');

      expect(cubit.step, PhoneVerificationStep.code);
      // اتطبّع للصيغة المحلية اللي الـAPI بيقبلها.
      expect(cubit.pendingPhone, '01113000000');
      expect(cubit.state, isA<PhoneVerificationCodeSent>());
      await cubit.close();
    });

    test('كود صح بيرجّع اللي اترّبط مش مجرد نجاح', () async {
      final cubit = build();
      await cubit.sendCode('01113000000');
      await cubit.verify(PhoneVerificationMockService.validOtp);

      final state = cubit.state;
      expect(state, isA<PhoneVerificationSucceeded>());
      expect((state as PhoneVerificationSucceeded).result.relinkedBookings, 3);
      await cubit.close();
    });

    test('كود غلط = خطأ على حقل otp والشاشة فاضلة على خطوة الكود', () async {
      final cubit = build();
      await cubit.sendCode('01113000000');
      await cubit.verify('0000');

      final state = cubit.state as PhoneVerificationFailed;
      expect(state.isOtpError, isTrue);
      expect(state.isConflict, isFalse);
      // مابترجعش لخطوة الرقم — الرقم مافيهوش غلط.
      expect(cubit.step, PhoneVerificationStep.code);
      await cubit.close();
    });

    test('تعارض = خطأ على حقل phone وبيرجّع لخطوة الرقم', () async {
      MockConfig.scenario = MockScenario.phoneClaimConflict;
      final cubit = build();
      await cubit.sendCode('01113000000');
      await cubit.verify(PhoneVerificationMockService.validOtp);

      final state = cubit.state as PhoneVerificationFailed;
      expect(state.isConflict, isTrue);
      expect(state.isOtpError, isFalse);
      // ⚠ ده الفرق اللي الشاشة كلها موجودة عشانه: إبقاء العميلة على خانات
      // الكود هنا معناه إنها تعيد كتابة كود صح للأبد.
      expect(cubit.step, PhoneVerificationStep.phone);
      await cubit.close();
    });

    test('«غيّر الرقم» بيرجّع لأول الفلو', () async {
      final cubit = build();
      await cubit.sendCode('01113000000');
      cubit.restart();

      expect(cubit.step, PhoneVerificationStep.phone);
      expect(cubit.pendingPhone, isEmpty);
      expect(cubit.state, isA<PhoneVerificationInitial>());
      await cubit.close();
    });

    test('العدّاد بيشتغل بعد الإرسال فمافيش إعادة إرسال فورية', () async {
      final cubit = build();
      await cubit.sendCode('01113000000');

      expect(cubit.canResend, isFalse);
      expect(cubit.resendSeconds, PhoneVerificationCubit.resendCooldownSeconds);
      await cubit.close();
    });
  });

  group('نص الباند', () {
    test('بيجمع الباقات والحجوزات', () {
      const band = PhoneClaimResultBandWidget(
        result: PhoneClaimResultUiModel(linked: 2, relinkedBookings: 3),
        packagesFound: 2,
      );

      expect(band.message, contains('باقتين'));
      expect(band.message, contains('3 حجوزات'));
    });

    test('مفرد ومثنى عربي صح', () {
      expect(
        const PhoneClaimResultBandWidget(
          result: PhoneClaimResultUiModel(relinkedBookings: 1),
        ).message,
        contains('حجز'),
      );
      expect(
        const PhoneClaimResultBandWidget(
          result: PhoneClaimResultUiModel(relinkedBookings: 2),
        ).message,
        contains('حجزين'),
      );
    });

    test('مالقاش حاجة = نص محايد، مش «ظهرلك ٠»', () {
      const band = PhoneClaimResultBandWidget(
        result: PhoneClaimResultUiModel(),
        packagesFound: 0,
      );

      // **مافيش «ظهرلك ٠»** — ده بيأكّد للعميلة إن مفيش حاجة بطريقة
      // بتحسّسها إنها غلطتها.
      expect(band.message, isNot(contains('ظهرلك')));
      expect(band.message, isNot(contains('0')));
      // النص بيقول اللي ممكن يحصل بعدين بدل ما يعدّ أصفار.
      expect(band.message, contains('هتلاقيها هنا'));
      // ⚠ **مابيكرّرش «رقمك اتأكّد»** — دي عنوان الورقة اللي بتلفّه
      // (`PhoneClaimResultSheet`)، والتكرار كان بيخلّيها تتقال مرتين
      // فوق بعض.
      expect(band.message, isNot(contains('رقمك اتأكّد')));
    });
  });

  group('الحساب', () {
    test('phone_verified_at بيتقري من /me', () {
      final verified = AccountUiModel.fromJson(<String, dynamic>{
        'name': 'ليلى',
        'phone': '01113000000',
        'phone_verified_at': '2026-08-01T10:30:00.000000Z',
      });
      expect(verified.isPhoneVerified, isTrue);

      final not = AccountUiModel.fromJson(<String, dynamic>{
        'name': 'ليلى',
        'phone': '01113000000',
      });
      expect(not.isPhoneVerified, isFalse);
    });

    test('السيناريو بيتحكّم في حالة التأكيد الوهمية', () {
      MockConfig.scenario = MockScenario.phoneClaimConflict;
      expect(MockAccount.me.isPhoneVerified, isFalse);

      MockConfig.scenario = MockScenario.happyPath;
      expect(MockAccount.me.isPhoneVerified, isTrue);
    });
  });

  group('نتيجة الربط', () {
    test('بتتقري من رد السيرفر', () {
      final result = PhoneClaimResultUiModel.fromJson(<String, dynamic>{
        'linked': 2,
        'relinked_bookings': 3,
        'superseded': 1,
        'conflicts': 0,
      });

      expect(result.linked, 2);
      expect(result.relinkedBookings, 3);
      expect(result.foundAnything, isTrue);
    });

    test('كله أصفار = مالقاش حاجة', () {
      expect(
        const PhoneClaimResultUiModel().foundAnything,
        isFalse,
      );
    });
  });
}
