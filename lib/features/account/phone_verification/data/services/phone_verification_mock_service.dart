import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_service.dart';

/// MOCK — يتشال لما الشاشة تتجرّب على السيرفر الحقيقي.
///
/// ⚠ **الـmock ده بيقلّد سلوك موجود فعلاً، مش عقد متخيّل.** الشكل والحالات
/// كلها اتقروا من `LinkProviderCustomersToPlatformUserAction`:
///
///  • `otp` غلط → 422 على حقل `otp` (`otp_invalid_or_expired`)
///  • `conflicts > 0` → 422 على حقل `phone` قبل ما يربط أي حاجة
///  • نجاح → `{linked, relinked_bookings, superseded, conflicts}`
///
/// الكود الصح في الوهمي **`1234`** — مكتوب في الشاشة نفسها عشان المراجع
/// مايدوّرش عليه.
class PhoneVerificationMockService implements PhoneVerificationService {
  const PhoneVerificationMockService();

  /// الكود اللي بيعدّي في الوهمي.
  static const String validOtp = '1234';

  @override
  Future<Either<Failure, Unit>> sendCode({
    required String phone,
    required String countryIso2,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, PhoneClaimResultUiModel>> verify({
    required String phone,
    required String countryIso2,
    required String otp,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }

    if (otp != validOtp) {
      return const Left(
        ValidationFailure(
          message: 'الكود غلط أو انتهت صلاحيته',
          fields: <String, List<String>>{
            'otp': <String>['الكود غلط أو انتهت صلاحيته'],
          },
        ),
      );
    }

    // الرقم على حساب حقيقي تاني — السيرفر بيرمي قبل ما يربط.
    if (MockConfig.scenario == MockScenario.phoneClaimConflict) {
      return const Left(
        ValidationFailure(
          message: 'الرقم ده مسجّل على حساب تاني',
          fields: <String, List<String>>{
            'phone': <String>['الرقم ده مسجّل على حساب تاني'],
          },
        ),
      );
    }

    // فاضي **مقصود**: عميلة أكّدت رقمها ومالهاش أي سجل في أي فرع. الحالة
    // دي شرعية ولازم يبقى ليها نص محايد مش «ظهرلك ٠».
    //
    // بيتربط بمفتاح `forceEmpty` **المتعامد** مش بسيناريو بعينه — الفاضي
    // هنا مالوش علاقة بأي سيناريو باقات، والربط بواحد كان بيخلّي طبقة
    // الهوية تعتمد على حاجة مش بتاعتها.
    if (MockConfig.isEmptyForced) {
      return const Right(PhoneClaimResultUiModel());
    }

    return const Right(
      PhoneClaimResultUiModel(
        linked: 2,
        relinkedBookings: 3,
        superseded: 1,
      ),
    );
  }
}
