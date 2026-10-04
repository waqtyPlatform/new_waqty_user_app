import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';

abstract class PackagesFollowingState {
  const PackagesFollowingState();
}

class PackagesFollowingInitialState extends PackagesFollowingState {
  const PackagesFollowingInitialState();
}

class PackagesFollowingTabChangedState extends PackagesFollowingState {
  final PackagesFollowingTab tab;

  const PackagesFollowingTabChangedState({required this.tab});
}
