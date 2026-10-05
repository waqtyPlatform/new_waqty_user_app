import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;

  HomeCubit(this._homeRepo) : super(InitialState());

  static HomeCubit get(context) => BlocProvider.of(context);
}
