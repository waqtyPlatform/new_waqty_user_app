import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/data/repo/explore_near_people_repo.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/logic/explore_near_people_state.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';

class ExploreNearPeopleCubit extends Cubit<ExploreNearPeopleState> {
  final ExploreNearPeopleRepo _exploreNearPeopleRepo;

  ExploreNearPeopleCubit(this._exploreNearPeopleRepo) : super(InitialState());

  static ExploreNearPeopleCubit get(context) => BlocProvider.of(context);
}
