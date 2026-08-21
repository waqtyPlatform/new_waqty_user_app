import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';

abstract class AccountService {
  Future<Either<Failure, AccountUiModel>> profile();

  /// ⚠ **بيبطّل التوكن على السيرفر.**
  ///
  /// مسح التوكن محليًا بس بيسيبه صالح — أي حد معاه نسخة منه يقدر يستخدمه
  /// لحد ما ينتهي لوحده. الفعل ده بيقفله من الناحيتين.
  Future<Either<Failure, Unit>> logout();
}
