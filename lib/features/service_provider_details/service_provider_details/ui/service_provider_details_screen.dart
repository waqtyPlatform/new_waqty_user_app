import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_section_header_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/core/widgets/loading_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_state.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_actions_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_booking_bar_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';
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
    return BlocBuilder<ServiceProviderDetailsCubit, ServiceProviderDetailsState>(
      builder: (context, state) {
        final cubit = ServiceProviderDetailsCubit.get(context);

        if (state is DetailsErrorState) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: ErrorStateWidget(
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
              child: LoadingWidget(color: AppSemanticColors.accent),
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
          bottomNavigationBar: cubit.services.isEmpty && !cubit.isReloadingBranch
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
                      ServiceProviderDetailsHoursWidget(
                        branch: branch,
                        isExpanded: cubit.isWorkingHoursExpanded,
                        onToggle: cubit.toggleWorkingHours,
                      ),
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
                  child: SkeletonGroupWidget(
                    child: Column(
                      children: List<Widget>.generate(
                        3,
                        (_) => Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.pageGutter.w,
                            vertical: AppSpacing.s12.h,
                          ),
                          child: const SkeletonBoxWidget(
                            width: double.infinity,
                            height: 40,
                            animate: false,
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

    final picked = await showModalBottomSheet<ServiceUiModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name, style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s4),
            Text(
              'الأسعار والمدد بيختلفوا حسب النوع',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final child in children)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(child.name, style: AppTextStyles.cardTitle),
                      subtitle: Text(
                        AppFormat.duration(child.durationMinutes),
                        style: AppTextStyles.caption,
                      ),
                      trailing: Text(
                        AppFormat.money(child.price),
                        style: AppTextStyles.bodyMdStrong,
                      ),
                      onTap: () => Navigator.of(sheetContext).pop(child),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  void _showBranchSheet(
    BuildContext context,
    ServiceProviderDetailsCubit cubit,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s16.w,
          end: AppSpacing.s16.w,
          top: AppSpacing.s8.h,
          bottom: AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختار الفرع', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s12),
            ...cubit.branches.map(
              (branch) => ListTile(
                title: Text(branch.name),
                subtitle: Text(
                  '${branch.address} · ${AppFormat.distance(branch.distanceKm)}',
                ),
                trailing: branch.uuid == cubit.selectedBranch?.uuid
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: AppSemanticColors.accent,
                      )
                    : null,
                onTap: () {
                  cubit.changeBranch(branch);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
