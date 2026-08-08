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

  /// الخدمات والأخصائيين بيتحمّلوا دلوقتي بعد تغيير فرع.
  ///
  /// `bool` في الـ cubit مش state class جديدة: الـ builder في الشاشة
  /// catch-all وبيقرا `cubit.services` مباشرة، فحالة جديدة مش هتضيف حاجة —
  /// والـ `bool` بيخلي قسم الخدمات يوري skeleton من غير أي احتمال إن
  /// الهيدر يتفضّى.
  bool isReloadingBranch = false;

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

    await _loadBranchScoped();

    emit(DetailsSuccessState());
  }

  /// الخدمات والأخصائيين **بتوع الفرع المختار**.
  ///
  /// كان `MockEmployees.forService('')` — نص فاضي بيقع في الـ `null` بتاع
  /// خريطة الخدمات فبيرجّع الفريق كله بالصدفة. النتيجة كانت صح والكلام
  /// كان غلط، وده أسوأ من الاتنين: مفيش حاجة تكسر لما الفلتر الحقيقي
  /// يتضاف، فمحدش بياخد باله.
  Future<void> _loadBranchScoped() async {
    final branchIndex = MockProviders.branchIndexOf(
      providerUuid: providerUuid,
      branchUuid: selectedBranch?.uuid,
    );

    // TODO(api): GET /api/public/services?provider_uuid=&branch_uuid=
    final servicesResult = await MockSource.fetch(
      MockServices.ofBranch(
        providerUuid: providerUuid,
        branchUuid: selectedBranch?.uuid,
      ),
    );

    // TODO(api): GET /api/public/employees?provider_uuid=&branch_uuid=
    final employeesResult = await MockSource.fetch(
      MockEmployees.rosterOf(branchIndex: branchIndex),
    );

    services = servicesResult.getOrElse(() => const <ServiceUiModel>[]);
    employees = employeesResult.getOrElse(() => const <EmployeeUiModel>[]);
  }

  /// **بيعيد التحميل فعلاً دلوقتي.**
  ///
  /// التعليق ده كان مكتوب هنا والجسم كان بيحطّ الفرع ويـ`emit` وبس —
  /// الأسعار والأخصائيين بتوع الفرع القديم بيفضلوا على الشاشة. والعميل
  /// بياخد قراره على أرقام مش بتاعة المكان اللي هيروحه.
  ///
  /// اسم الفرع بيتغيّر **قبل** الانتظار: ده معلومة محلية ومش مستنية أي
  /// نداء، والهيدر لازم يرد على الدوسة على طول.
  ///
  /// ⚠ **شبكة المواعيد لسه مش فرعية** — `MockSlots` مالهاش بُعد فرع.
  /// مكتوبة في `TODO(mock)` هناك.
  Future<void> changeBranch(BranchUiModel branch) async {
    selectedBranch = branch;
    isReloadingBranch = true;
    emit(OnBranchChangedState());

    await _loadBranchScoped();

    isReloadingBranch = false;
    emit(OnBranchChangedState());
  }

  void toggleWorkingHours() {
    isWorkingHoursExpanded = !isWorkingHoursExpanded;
    emit(OnWorkingHoursToggledState());
  }

  static ServiceProviderDetailsCubit get(context) => BlocProvider.of(context);
}
