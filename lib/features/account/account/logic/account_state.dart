abstract class AccountState {}

class AccountInitialState extends AccountState {}

class AccountLoadingState extends AccountState {}

class AccountLoadedState extends AccountState {
  final bool isGuest;

  AccountLoadedState({required this.isGuest});
}

class AccountLogoutLoadingState extends AccountState {}

class AccountLogoutSuccessState extends AccountState {}
