import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/change_phone/logic/change_phone_state.dart';

class ChangePhoneCubit extends Cubit<ChangePhoneState> {
  ChangePhoneCubit() : super(ChangePhoneInitialState());

  final TextEditingController currentPhoneController = TextEditingController(
    text: '101 234 5678',
  );
  final TextEditingController newPhoneController = TextEditingController(
    text: '198 555 106',
  );
  String newCountryCode = '+20';

  void changeNewCountryCode(CountryCode code) {
    newCountryCode = code.toString();
    emit(ChangePhoneCountryChangedState());
  }

  @override
  Future<void> close() {
    currentPhoneController.dispose();
    newPhoneController.dispose();
    return super.close();
  }

  static ChangePhoneCubit get(context) => BlocProvider.of(context);
}
