import 'package:easy_localization/easy_localization.dart' as context;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_request_model.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _registerRepo;

  RegisterCubit(this._registerRepo) : super(InitialState());

  GlobalKey<FormState> registerKey = GlobalKey();
  TextEditingController registerNameController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerCountryCodeController = TextEditingController();
  TextEditingController registerPhoneController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerBirthDateController = TextEditingController();

  GenderItem selectedGender = GenderItem(
    value: 'male',
    name: context.tr('register.maleText'),
  );

  changeGender(GenderItem value) {
    selectedGender = value;
    emit(OnChangeGenderState());
  }

  changeBirthDate(String value) {
    registerBirthDateController.text = value;
    emit(OnChangeBirthDateState());
  }

  int selectedFieldNumber = 0;
  changeSelectedField(int value) {
    selectedFieldNumber = value;
    emit(OnChangeSelectedFieldState());
  }

  bool isPasswordVisibleLogin = true;

  changePasswordLoginState() {
    isPasswordVisibleLogin = !isPasswordVisibleLogin;
    emit(IsPasswordVisibleState());
  }

  Future<void> register() async {
    emit(OnRegisterLoadingState());
    try {
      final result = await _registerRepo.register(
        RegisterRequestModel(
          name: registerNameController.text.trim(),
          email: registerEmailController.text.trim(),
          phone:
              (registerCountryCodeController.text.isEmpty
                  ? '+20'
                  : registerCountryCodeController.text) +
              registerPhoneController.text.trim(),
          dateBirth: registerBirthDateController.text,
          gender: selectedGender.value,
          password: registerPasswordController.text,
        ),
      );

      result.fold(
        (failure) {
          emit(OnRegisterErrorState(failure.message));
        },
        (registerResponse) {
          emit(OnRegisterSuccessState(registerResponse));
        },
      );
    } catch (_) {
      emit(OnRegisterCatchErrorState());
    }
  }

  static RegisterCubit get(context) => BlocProvider.of(context);
}
