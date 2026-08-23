import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/widgets/policy_accordion_widget.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/features/account/account/data/repo/account_repo.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/entitlements_screen.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/ui/entitlement_booking_sheet.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/provider_packages_notice_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/package_offer_sheet.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_packages_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_state.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_actions_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_booking_bar_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_branch_row_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_header_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_meta_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_hours_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_service_row_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_specialists_widget.dart';

/// ترتيب الصفحة اتغيّر عشان القرار مش التصفح.
///
/// القديم: صورة → أخصائيين → كلام → مواعيد → خريطة → **الخدمات**.
/// يعني تقريبًا ٣ سحبات كاملة قبل ما توصل للحاجة اللي الزرار الأخضر
/// المثبّت تحت بيطلب منك تشتريها.
///
/// الجديد: هوية → الفرع → المواعيد → **الخدمات** → أخصائيين.
/// وفقرة الباقات وفقرة التقييمات اتشالوا خالص — الباقات كانت ٤ كروت
/// بنفس السعر بزراير ميتة (وكانت الأسعار الوحيدة في الصفحة)، والتقييمات
/// مراجعتين مكررين من نفس الشخص عن تشريعات المناخ.
class ServiceProviderDetailsScreen extends StatelessWidget {
  const ServiceProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ServiceProviderDetailsCubit,
      ServiceProviderDetailsState
    >(
      builder: (context, state) {
        final cubit = ServiceProviderDetailsCubit.get(context);

        if (state is DetailsErrorState) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: AppErrorStateWidget(
                  message: state.message,
                  onRetry: cubit.loadDetails,
                ),
              ),
            ),
          );
        }

        final provider = cubit.provider;
        if (provider == null) {
          return Scaffold(
            body: Center(
              child: AppLoadingWidget(color: AppSemanticColors.accent),
            ),
          );
        }

        final branch = cubit.selectedBranch;

        return Scaffold(
          // الشريط المثبّت جاي من `bottomNavigationBar` مش `Stack`.
          // الـ Scaffold بيقصّ ارتفاع الـ body بمقداره لوحده، فآخر صف في
          // الليستة مابيتغطّاش — والحل بالـ Stack كان بيحتاج حشوة سفلية
          // مكتوبة بالإيد لازم تتظبط كل ما الشريط يتغيّر.
          // `isReloadingBranch` في الشرط عشان الشريط مايختفيش ويرجع في
          // اللحظة اللي الخدمات فيها بتتحمّل — الوميض بيقرا عطل.
          bottomNavigationBar:
              cubit.services.isEmpty && !cubit.isReloadingBranch
              ? null
              : ServiceProviderDetailsBookingBarWidget(
                  services: cubit.services,
                  // من غير خدمة محددة — الـ sheet بيفتح على قايمة
                  // الخدمات بالاختيار المتعدد.
                  onBook: () => _openBooking(context, cubit, null),
                ),
          body: CustomScrollView(
            slivers: [
              ServiceProviderDetailsHeaderWidget(
                name: provider.name,
                imageUrl: provider.imagePath,
                categoryName: provider.categoryName,
                areaName: provider.areaName,
              ),

              // الجزء ده كله «كلام» — بياخد هامش الصفحة من فوق.
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  start: AppSpacing.pageGutter.w,
                  end: AppSpacing.pageGutter.w,
                  top: AppSpacing.pageGutter.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // الاسم والتصنيف اتنقلوا **فوق الصورة** في الهيدر —
                    // كانوا هنا مكرّرين تحت لوح ملوّن بلا سياق.
                    ServiceProviderDetailsMetaWidget(
                      provider: provider,
                      services: cubit.services,
                    ),

                    if (branch != null) ...[
                      verticalSpace(AppSpacing.s16),
                      ServiceProviderDetailsBranchRowWidget(
                        branch: branch,
                        hasMultipleBranches: cubit.branches.length > 1,
                        onChangeBranch: () => _showBranchSheet(context, cubit),
                      ),
                      verticalSpace(AppSpacing.listRowGap),
                      ServiceProviderDetailsHoursWidget(branch: branch),
                      verticalSpace(AppSpacing.listRowGap),
                      ServiceProviderDetailsActionsWidget(
                        onCall: branch.phone.isEmpty
                            ? null
                            : () => AppConstant.openUrl('tel:${branch.phone}'),
                        onDirections: () => AppConstant.openMap(
                          branch.latitude,
                          branch.longitude,
                        ),
                        // المشاركة محتاجة deep link — مش موجود لسه،
                        // فبتتعرض باهتة مش شغالة وميتة.
                        onShare: null,
                      ),

                      // **باقاتك هنا — بعد الاتصال وقبل السياسات.**
                      //
                      // مكانها في منطقة «علاقتك بالفرع ده» مش فوق
                      // الخدمات: العميلة داخلة تبص على الأسعار، وقسم
                      // فوقها بيزاحم سبب دخولها. وهي أصلاً تحت الفرع
                      // مباشرة، فالباقة بتتقري في سياق المكان اللي
                      // بتتصرف فيه.
                      if (cubit.providerPackages.isNotEmpty) ...[
                        verticalSpace(AppSpacing.listRowGap),
                        ProviderPackagesNoticeWidget(
                          packages: cubit.providerPackages,
                          selectedBranchUuid: branch.uuid,
                          onOpen: () => _openEntitlements(context),
                          onBook: (package) => _bookPackage(context, package),
                        ),
                      ],

                      // **اللي معروض للبيع — بعد اللي دفعت فيه.**
                      //
                      // الترتيب مقصود: باقاتها الأول، كتالوج المكان بعده.
                      // العكس بيحطّ إعلان فوق حاجة العميلة دافعة فيها.
                      // والقسم بيختفي بالكامل لو الفرع مابيبيعش باقات، وده
                      // حال أغلب الفروع.
                      if (cubit.branchPackages.isNotEmpty) ...[
                        verticalSpace(AppSpacing.listRowGap),
                        ServiceProviderDetailsPackagesWidget(
                          packages: cubit.branchPackages,
                          onOpen: (package) =>
                              PackageOfferSheet.show(context, package: package),
                        ),
                      ],

                      // **«قبل ما تحجز» — مقفول، وتحت الفرع مش فوقه.**
                      //
                      // السياسة بتتراجع لما تلزم، فمكانها بعد الحاجات
                      // اللي العميلة داخلة عشانها (الفرع · المواعيد ·
                      // الاتصال) وقبل الخدمات. والـwidget بيختفي بالكامل
                      // لو المزوّد ما كتبش ولا سياسة — وده حال **كل**
                      // الفروع النهاردة لحد ما BE-B1 تنزل.
                      if (branch.policies.hasPreBooking) ...[
                        verticalSpace(AppSpacing.listRowGap),
                        PolicyAccordionWidget(policies: branch.policies),
                      ],
                    ],

                    // العنوان شايل الفاصل ٤٠ بنفسه. قبل كده الفاصل قبل
                    // «الخدمات» كان ٢٤ وقبل «الأخصائيين» ١٦ — **نفس
                    // العلاقة البنيوية بقيمتين مختلفتين**.
                    if (cubit.services.isNotEmpty || cubit.isReloadingBranch)
                      const AppSectionHeaderWidget(title: 'الخدمات'),
                  ]),
                ),
              ),

              // **الأسعار بتتغيّر مع الفرع، فالصفوف بتتحمّل من الأول.**
              //
              // من غير الـ skeleton الصفوف بتفضل على أسعار الفرع القديم
              // لحد ما التحميل يخلص — وده أوحش من الفراغ: العميل بيبص على
              // أرقام مش بتاعة المكان اللي هو مختاره دلوقتي.
              if (cubit.isReloadingBranch)
                SliverToBoxAdapter(
                  child: AppSkeletonGroupWidget(
                    child: Column(
                      children: List<Widget>.generate(
                        3,
                        (_) => Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.pageGutter.w,
                            vertical: AppSpacing.s12.h,
                          ),
                          child: const AppSkeletonBoxWidget(
                            width: double.infinity,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // **الخدمات بره الهامش عن قصد.**
              //
              // كل صف بقى شايل الـ ١٦ بتاعه جواه، فلو قعد جوه الـ
              // `SliverPadding` فوق كان الهامش هيتحسب مرتين (٣٢) والخط
              // الشعري كان هيقف قبل حافة الشاشة بـ ١٦ — يعني بيرسم حد
              // لكارت مش موجود. سلايفر لوحده أنضف من هامش سالب.
              SliverList.builder(
                itemCount: cubit.isReloadingBranch ? 0 : cubit.services.length,
                itemBuilder: (context, index) {
                  final service = cubit.services[index];

                  return ServiceProviderDetailsServiceRowWidget(
                    service: service,
                    showHairline: index != cubit.services.length - 1,
                    // صف الخدمة هو الضغطة الأولى من الأربعة. الـ sheet
                    // بيفتح وخطوة الخدمة متخطية، لأن العميل اختارها
                    // بالضغطة دي أصلاً.
                    // **التصنيف بيفتح ولاده، مش كل خدمات المحل.**
                    //
                    // كان بيبعت `null` — يعني الـ sheet بيفتح على القايمة
                    // الكاملة. صف بيقول «صبغة · 5 خدمات» وبيوصّلك لقص
                    // شعر وحلاقة ذقن بيكسر الوعد اللي هو نفسه كتبه.
                    onTap: () => service.isCategory
                        ? _openCategory(context, cubit, service)
                        : _openBooking(context, cubit, service.uuid),
                  );
                },
              ),

              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  start: AppSpacing.pageGutter.w,
                  end: AppSpacing.pageGutter.w,
                  bottom: AppSpacing.screenBottom.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (cubit.employees.isNotEmpty) ...[
                      const AppSectionHeaderWidget(title: 'الأخصائيين'),
                      ServiceProviderDetailsSpecialistsWidget(
                        employees: cubit.employees,
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// شيت ولاد التصنيف — اختار منه وبعدين يكمّل للحجز.
  ///
  /// خطوة زيادة بالقصد: التصنيف مش خدمة، والعميل لازم يحدد **أنهي**
  /// صبغة قبل ما نسأله عن الميعاد — الأسعار والمدد بتختلف بينهم بالتلت.
  Future<void> _openCategory(
    BuildContext context,
    ServiceProviderDetailsCubit cubit,
    ServiceUiModel category,
  ) async {
    // **بسعر الفرع المختار.** لو الصف بيقول ٢٩٠ والـ sheet اللي بيفتح
    // منه بيقول ٤٠٠، الـ prototype بيناقض نفسه في ضغطة واحدة.
    final children = MockServices.childrenOfBranch(
      category.uuid,
      providerUuid: cubit.providerUuid,
      branchUuid: cubit.selectedBranch?.uuid,
    );
    if (children.isEmpty) return;

    // الصفوف بقت [AppMenuRowWidget]: الاسم، تحته المدة، والسعر على الطرف
    // التاني. نفس اللي `ListTile` كان بيعمله بس بحشوة من سلّم المسافات.
    final picked = await AppSheetWidget.show<ServiceUiModel>(
      context,
      title: category.name,
      message: 'الأسعار والمدد بيختلفوا حسب النوع',
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final child in children)
              AppMenuRowWidget(
                title: child.name,
                subtitle: AppFormat.duration(child.durationMinutes),
                showChevron: false,
                trailing: Text(
                  AppFormat.money(child.price),
                  style: AppTextStyles.bodyMdStrong,
                ),
                onTap: () => Navigator.of(sheetContext).pop(child),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    );

    if (picked != null && context.mounted) {
      await _openBooking(context, cubit, picked.uuid);
    }
  }

  Future<void> _openBooking(
    BuildContext context,
    ServiceProviderDetailsCubit cubit,
    String? serviceUuid,
  ) async {
    final didBook = await CreateBookingSheet.show(
      context,
      providerUuid: cubit.providerUuid,
      providerName: cubit.provider?.name ?? '',
      serviceUuid: serviceUuid,
      // الفرع اللي العميل اختاره من `_showBranchSheet` — كان بيتضاع هنا
      // والحجز بيروح لأول فرع مهما اختار.
      branch: cubit.selectedBranch,
    );

    if (didBook == true && context.mounted) {
      Navigator.of(context).pushNamed(Routes.bookingSuccessScreen);
    }
  }

  /// بيحجز جلسة من باقة **من غير ما يسيب صفحة المزوّد**.
  ///
  /// الشيت محتاج `EntitlementsCubit`، واللي مش في نطاق الشاشة دي (بتتفتح
  /// بـ`pushNamed` فوق الـshell). فبنعمل نسخة مقصورة عليه — نفس معالجة
  /// `ReassignmentCubit` في `app_routes.dart` — وبعد الحجز بنعيد تحميل
  /// باقات الصفحة عشان الأرقام تتحدّث تحت إيد العميلة.
  Future<void> _bookPackage(
    BuildContext context,
    PackageEntitlementUiModel package,
  ) async {
    final cubit = ServiceProviderDetailsCubit.get(context);
    final entitlements = EntitlementsCubit(getIt<EntitlementsRepo>());

    final booked = await EntitlementBookingSheet.showForPackage(
      context,
      cubit: entitlements,
      package: package,
    );

    if (!context.mounted) {
      await entitlements.close();
      return;
    }
    if (booked) {
      await EntitlementBookingSheet.showConfirmation(
        context,
        kind: EntitlementBookingKind.package,
      );
      await cubit.reloadPackages();
    }
    await entitlements.close();
  }

  /// بيفتح «باقاتي» بنسخة **مقصورة على الشاشة المدفوعة**.
  ///
  /// صفحة المزوّد بتتفتح بـ`pushNamed` على الـnavigator بتاع
  /// `MaterialApp`، فوق الـproviders بتوع الـshell — يعني لا
  /// `EntitlementsCubit` ولا `AccountCubit` في نطاقها. نفس معالجة
  /// `ReassignmentCubit` الموجودة أصلاً في `app_routes.dart`.
  ///
  /// ⚠ **الاتنين لازم يتبعتوا مع بعض.** `EntitlementsBodyWidget` بينده
  /// `AccountCubit` في الحالة الفاضية، ونسيانه كان بيكسر الشاشة
  /// بـ`ProviderNotFoundException` — الباج ده حصل قبل كده.
  void _openEntitlements(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<EntitlementsCubit>(
              create: (_) =>
                  EntitlementsCubit(getIt<EntitlementsRepo>())..load(),
            ),
            BlocProvider<AccountCubit>(
              create: (_) =>
                  AccountCubit(getIt<AccountRepo>(), getIt<SessionStore>())
                    ..getProfile(),
            ),
          ],
          child: const EntitlementsScreen(),
        ),
      ),
    );
  }

  void _showBranchSheet(
    BuildContext context,
    ServiceProviderDetailsCubit cubit,
  ) {
    // **اختيار واحد من عدة، فـ[AppChoiceRowWidget] بنمط الراديو.**
    //
    // كان `ListTile` بأيقونة صح على المختار — والصح بيقول «ده اتعمل»، مش
    // «ده المختار من بين دول». الراديو بيقول الاتنين: فيه اختيارات تانية،
    // وده الشغّال دلوقتي.
    //
    // والورقة بترجّع الفرع، والشاشة هي اللي بتبدّله — نفس مبدأ الكيت.
    AppSheetWidget.show<BranchUiModel>(
      context,
      title: 'اختار الفرع',
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final branch in cubit.branches)
              AppChoiceRowWidget(
                title: branch.name,
                subtitle:
                    '${branch.address} · '
                    '${AppFormat.distance(branch.distanceKm)}',
                selected: branch.uuid == cubit.selectedBranch?.uuid,
                style: AppChoiceStyle.radio,
                onTap: () => Navigator.of(sheetContext).pop(branch),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    ).then((branch) {
      if (branch != null) cubit.changeBranch(branch);
    });
  }
}
