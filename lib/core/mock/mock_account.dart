import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/auth/me
class MockAccount {
  MockAccount._();

  /// ⚠ **`phoneVerifiedAt` بيتفرّع على السيناريو مش ثابت.**
  ///
  /// الحالة الفاضية في «حجوزاتي» نصها بيتغيّر حسب التأكيد: «أكّد رقمك
  /// عشان يظهروا» بدل «مفيش حجوزات». لو الحساب الوهمي كان مأكّد
  /// دايمًا، الفرع ده **مايتشافش أبدًا** — وهو أكتر حالة متوقعة عند
  /// الإطلاق.
  static AccountUiModel get me => AccountUiModel(
    name: 'يوسف الفيل',
    email: 'yossef@example.com',
    phone: '+201012345678',
    imagePath: '',
    phoneVerifiedAt: _verifiedAt,
  );

  static DateTime? get _verifiedAt => switch (MockConfig.scenario) {
    MockScenario.phoneClaimConflict => null,
    _ => DateTime(2026, 8, 1, 10, 30),
  };
}
