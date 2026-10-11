import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/provider_details_repo.dart';
import 'provider_employee_profile_state.dart';

class ProviderEmployeeProfileCubit extends Cubit<ProviderEmployeeProfileState> {
  final ProviderDetailsRepo _repo;
  final String employeeUuid;

  ProviderEmployeeProfileCubit(this._repo, this.employeeUuid)
    : super(const ProviderEmployeeProfileInitial());

  Future<void> load() async {
    if (employeeUuid.isEmpty) {
      emit(const ProviderEmployeeProfileNotFound());
      return;
    }
    emit(const ProviderEmployeeProfileLoading());
    final result = await _repo.employee(employeeUuid);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        failure is ProviderEmployeeNotFoundFailure
            ? const ProviderEmployeeProfileNotFound()
            : ProviderEmployeeProfileError(failure.message),
      ),
      (employee) => emit(ProviderEmployeeProfileLoaded(employee)),
    );
  }
}
