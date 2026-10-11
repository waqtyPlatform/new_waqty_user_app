import '../data/models/provider_details_model.dart';

sealed class ProviderEmployeeProfileState {
  const ProviderEmployeeProfileState();
}

class ProviderEmployeeProfileInitial extends ProviderEmployeeProfileState {
  const ProviderEmployeeProfileInitial();
}

class ProviderEmployeeProfileLoading extends ProviderEmployeeProfileState {
  const ProviderEmployeeProfileLoading();
}

class ProviderEmployeeProfileLoaded extends ProviderEmployeeProfileState {
  final ProviderEmployeeProfileModel employee;
  const ProviderEmployeeProfileLoaded(this.employee);
}

class ProviderEmployeeProfileNotFound extends ProviderEmployeeProfileState {
  const ProviderEmployeeProfileNotFound();
}

class ProviderEmployeeProfileError extends ProviderEmployeeProfileState {
  final String message;
  const ProviderEmployeeProfileError(this.message);
}
