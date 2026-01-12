import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/register/logic/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _myAddressRepo;

  RegisterCubit(this._myAddressRepo) : super(InitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);
}
