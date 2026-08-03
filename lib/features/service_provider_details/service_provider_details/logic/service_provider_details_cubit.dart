import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_state.dart';

class ServiceProviderDetailsCubit extends Cubit<ServiceProviderDetailsState> {
  ServiceProviderDetailsCubit({required this.providerUuid})
    : super(InitialState());

  /// الـ uuid كان مش بيتبعت للشاشة خالص — الراوت كان بيبني الشاشة من غير
  /// أي arguments، فكل الكروت كانت بتفتح نفس المكان.
  final String providerUuid;

  ProviderUiModel? provider;
  List<BranchUiModel> branches = <BranchUiModel>[];
  BranchUiModel? selectedBranch;
  List<ServiceUiModel> services = <ServiceUiModel>[];
  List<EmployeeUiModel> employees = <EmployeeUiModel>[];

  bool isWorkingHoursExpanded = false;

  Future<void> loadDetails() async {
    emit(DetailsLoadingState());

    // TODO(api): GET /api/public/providers/{uuid}
    final result = await MockSource.fetch(MockProviders.byUuid(providerUuid));

    final failure = result.fold<String?>((l) => l, (_) => null);
    if (failure != null) {
      emit(DetailsErrorState(message: failure));
      return;
    }

    provider = result.getOrElse(() => MockProviders.all.first);

    // TODO(api): GET /api/public/provider-branches?provider_uuid=
    branches = MockProviders.branchesOf(providerUuid);
    selectedBranch = branches.isEmpty ? null : branches.first;

    // TODO(api): GET /api/public/services?provider_uuid=
    services = MockServices.ofProvider(providerUuid);

    // TODO(api): GET /api/public/employees?provider_uuid=
    employees = MockEmployees.forService(
      '',
    ).where((e) => !e.isAnyAvailable).toList();

    emit(DetailsSuccessState());
  }

  /// المواعيد والأسعار والأخصائيين بيختلفوا من فرع للتاني، فتغيير الفرع
  /// بيحمّل الخدمات من الأول.
  void changeBranch(BranchUiModel branch) {
    selectedBranch = branch;
    emit(OnBranchChangedState());
  }

  void toggleWorkingHours() {
    isWorkingHoursExpanded = !isWorkingHoursExpanded;
    emit(OnWorkingHoursToggledState());
  }

  static ServiceProviderDetailsCubit get(context) => BlocProvider.of(context);
}
