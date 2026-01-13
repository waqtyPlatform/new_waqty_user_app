import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _registerRepo;

  RegisterCubit(this._registerRepo) : super(InitialState());

  GlobalKey<FormState> registerKey = GlobalKey();
  TextEditingController registerNameController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerCountryCodeController = TextEditingController();
  TextEditingController registerPhoneController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();



  int selectedFieldNumber=0;
  changeSelectedField(int value){
    selectedFieldNumber=value;
    emit(OnChangeSelectedFieldState());
  }


  bool isPasswordVisibleLogin = true;

  changePasswordLoginState() {
    isPasswordVisibleLogin = !isPasswordVisibleLogin;
    emit(IsPasswordVisibleState());
  }

  static RegisterCubit get(context) => BlocProvider.of(context);
}
