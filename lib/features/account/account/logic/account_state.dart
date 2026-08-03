abstract class AccountState {}

class InitialState extends AccountState {}

class AccountLoadingState extends AccountState {}

class AccountSuccessState extends AccountState {}

class AccountErrorState extends AccountState {
  final String message;
  AccountErrorState({required this.message});
}

class LogoutLoadingState extends AccountState {}

class LogoutSuccessState extends AccountState {}
