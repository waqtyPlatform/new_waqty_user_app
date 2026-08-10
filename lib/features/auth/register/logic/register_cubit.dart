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

  // `selectedFieldNumber` و`changeSelectedField` اتشالوا: كانوا بيلوّنوا
  // خلفية الحقل المركّز أخضر فاتح، والتركيز بقى بيتقال بحد باللمسة من
  // `inputDecorationTheme`. في شاشة بـ ٦ حقول، الحالة دي كانت بتعيد بناء
  // الستة مع كل ضغطة.

  // **حالة إظهار كلمة السر اتشالت من هنا.**
  //
  // كانت `bool` + دالة + `State` في تلات cubits — تسع أعضاء كل
  // شغلهم يقلبوا أيقونة عين. `AppPasswordFieldWidget` بتاع الكيت
  // شايلها جواه، فضغطة العين بقت تبني الحقل بس بدل ما تبني الشاشة
  // كلها (٦ حقول في التسجيل).

  Future<void> register() async {
    emit(OnRegisterLoadingState());
    final result = await _registerRepo
        .register(
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
        )
        .catchError((error) {
          emit(OnRegisterCatchErrorState());
        });

    result.fold(
      (failure) {
        emit(OnRegisterErrorState(failure.message));
      },
      (registerResponse) {
        emit(OnRegisterSuccessState(registerResponse));
      },
    );
  }

  static RegisterCubit get(context) => BlocProvider.of(context);
}
