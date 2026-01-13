import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/repo/forget_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ForgetVerifyCodeCubit extends Cubit<ForgetVerifyCodeState> {
  final ForgetVerifyCodeRepo _forgetVerifyCodeRepo;

  ForgetVerifyCodeCubit(this._forgetVerifyCodeRepo) : super(InitialState());

  GlobalKey<FormState> forgetVerifyCodeKey = GlobalKey();
  TextEditingController verifyCodeController = TextEditingController();





  static ForgetVerifyCodeCubit get(context) => BlocProvider.of(context);
}
