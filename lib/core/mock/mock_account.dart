import 'package:waqty_user_application/core/models/account_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/auth/me
class MockAccount {
  MockAccount._();

  static const AccountUiModel me = AccountUiModel(
    name: 'يوسف الفيل',
    email: 'yossef@example.com',
    phone: '+201012345678',
    imagePath: '',
  );
}
