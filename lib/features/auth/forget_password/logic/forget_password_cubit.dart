import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepo _forgetPasswordRepo;

  ForgetPasswordCubit(this._forgetPasswordRepo) : super(InitialState());

  GlobalKey<FormState> forgetPasswordKey = GlobalKey();
  TextEditingController forgetPasswordEmailController = TextEditingController();

  int selectedFieldNumber=0;
  changeSelectedField(int value){
    selectedFieldNumber=value;
    emit(OnChangeSelectedFieldState());
  }





  static ForgetPasswordCubit get(context) => BlocProvider.of(context);
}
