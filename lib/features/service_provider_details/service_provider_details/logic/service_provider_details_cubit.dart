import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_state.dart';

class ServiceProviderDetailsCubit extends Cubit<ServiceProviderDetailsState> {
  ServiceProviderDetailsCubit(this._repo, {required this.providerUuid})
    : super(InitialState());

  final ServiceProviderDetailsRepo _repo;

  /// الـ uuid كان مش بيتبعت للشاشة خالص — الراوت كان بيبني الشاشة من غير
  /// أي arguments، فكل الكروت كانت بتفتح نفس المكان.
  final String providerUuid;

  ProviderUiModel? provider;
  List<BranchUiModel> branches = <BranchUiModel>[];
  BranchUiModel? selectedBranch;
  List<ServiceUiModel> services = <ServiceUiModel>[];
  List<EmployeeUiModel> employees = <EmployeeUiModel>[];

  // حالة فتح مواعيد العمل اتشالت من هنا — `AppAccordionWidget` شايلها
  // جواه، فالضغطة بقت تبني اللوح بس مش الصفحة كلها.

  /// الخدمات والأخصائيين بيتحمّلوا دلوقتي بعد تغيير فرع.
  ///
  /// `bool` في الـ cubit مش state class جديدة: الـ builder في الشاشة
  /// catch-all وبيقرا `cubit.services` مباشرة، فحالة جديدة مش هتضيف حاجة —
  /// والـ `bool` بيخلي قسم الخدمات يوري skeleton من غير أي احتمال إن
  /// الهيدر يتفضّى.
  bool isReloadingBranch = false;

  Future<void> loadDetails() async {
    emit(DetailsLoadingState());

    // `fold` واحدة بترجّع `null` عند الفشل — مفيش قيمة احتياطية
    // معقولة لمقدّم مش موجود، فماينفعش `getOrElse`.
    final loaded = (await _repo.provider(providerUuid)).fold<ProviderUiModel?>(
      (failure) {
        emit(DetailsErrorState(message: failure.message));
        return null;
      },
      (value) => value,
    );

    if (loaded == null || isClosed) return;
    provider = loaded;

    // فشل الفروع مابيوقّفش الصفحة — الهيدر والخدمات لسه ليهم قيمة
    // من غير مبدّل الفروع.
    branches = (await _repo.branches(providerUuid)).getOrElse(
      () => const <BranchUiModel>[],
    );
    selectedBranch = branches.isEmpty ? null : branches.first;

    await _loadBranchScoped();
    if (isClosed) return;

    emit(DetailsSuccessState());
  }

  /// الخدمات والأخصائيين **بتوع الفرع المختار**.
  ///
  /// كان `MockEmployees.forService('')` — نص فاضي بيقع في الـ `null` بتاع
  /// خريطة الخدمات فبيرجّع الفريق كله بالصدفة. النتيجة كانت صح والكلام
  /// كان غلط، وده أسوأ من الاتنين: مفيش حاجة تكسر لما الفلتر الحقيقي
  /// يتضاف، فمحدش بياخد باله.
  Future<void> _loadBranchScoped() async {
    final branchUuid = selectedBranch?.uuid;

    // الاتنين بيبدأوا مع بعض — مافيش اعتماد بينهم.
    final servicesCall = _repo.services(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
    );
    final employeesCall = _repo.employees(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
    );

    services = (await servicesCall).getOrElse(() => const <ServiceUiModel>[]);
    employees = (await employeesCall).getOrElse(
      () => const <EmployeeUiModel>[],
    );
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

    // ⚠ **الحراسة في المنادي مش جوّه `_loadBranchScoped`** — الدالة دي
    // مابتعملش `emit`، بتملّي حقول وبس. الـ`emit` هنا وفي `loadDetails`.
    await _loadBranchScoped();
    if (isClosed) return;

    isReloadingBranch = false;
    emit(OnBranchChangedState());
  }

  static ServiceProviderDetailsCubit get(context) => BlocProvider.of(context);
}
