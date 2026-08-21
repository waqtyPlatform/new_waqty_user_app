import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/auth/me
class MockAccount {
  MockAccount._();

  /// ⚠ **`phoneVerifiedAt` بيتفرّع على السيناريو مش ثابت.**
  ///
  /// الحالتين الفاضيتين في «باقاتي» و«حجوزاتي** نصهم مختلف حسب التأكيد —
  /// [MockScenario.entitlementsEmptyUnlinked] بتقول «أكّد رقمك عشان
  /// يظهروا» و[MockScenario.entitlementsEmptyGenuine] بتقول «مفيش باقات».
  /// لو الحساب الوهمي كان مأكّد دايمًا، الفرع الأول **مايتشافش أبدًا** —
  /// وهو أكتر حالة متوقعة عند الإطلاق.
  static AccountUiModel get me => AccountUiModel(
    name: 'يوسف الفيل',
    email: 'yossef@example.com',
    phone: '+201012345678',
    imagePath: '',
    phoneVerifiedAt: _verifiedAt,
  );

  static DateTime? get _verifiedAt => switch (MockConfig.scenario) {
    MockScenario.entitlementsEmptyUnlinked => null,
    MockScenario.phoneClaimConflict => null,
    _ => DateTime(2026, 8, 1, 10, 30),
  };
}
