import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_section_header_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_app_bar_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_categories_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_nearby_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_providers_rail_widget.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_cubit.dart';
import 'package:waqty_user_application/features/booking/branch_queue/ui/widgets/branch_queue_hero_section_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_search_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // مفيش Scaffold هنا — الشاشة جوه الـ Scaffold بتاع التبويبات.
    // القديمة كانت Scaffold جوه Scaffold، وده بيلخبط الـ SnackBars
    // والـ bottom sheets.
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        final isLoading = state is HomeLoadingState || state is InitialState;

        if (state is HomeErrorState) {
          return Center(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: ErrorStateWidget(
                message: state.message,
                onRetry: cubit.loadHome,
              ),
            ),
          );
        }

        // لون الـ RefreshIndicator جاي من `colorScheme.primary` في الثيم.
        return RefreshIndicator(
          onRefresh: cubit.loadHome,
          child: ListView(
            // نفس السبب بتاع قايمة الحجوزات — لو المحتوى قصر عن الشاشة
            // (مثلاً مفيش حجز جاي فالبؤرة مابتتبنيش) السحب بيتترفض.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.only(
              top: AppSpacing.s8.h,
              bottom: AppSpacing.screenBottom.h,
            ),
            children: [
              _gutter(
                HomeAppBarWidget(
                  cityName: cubit.selectedCity,
                  onNotificationsTap: () {},
                ),
              ),
              verticalSpace(AppSpacing.s16),
              _gutter(
                HomeSearchWidget(
                  onTap: () => context.pushNamed(Routes.providersListScreen),
                ),
              ),
              verticalSpace(AppSpacing.s24),

              HomeCategoriesWidget(
                categories: cubit.categories,
                isLoading: isLoading,
                onCategoryTap: (category) => context.pushNamed(
                  Routes.providersListScreen,
                  arguments: {'categoryUuid': category.uuid},
                ),
              ),

              // مفيش `verticalSpace` قبل أي لابل قسم من هنا ورايح —
              // `AppSectionHeaderWidget` شايل الفاصل ٤٠ والمسافة ٨ بنفسه.
              // كانوا ٢٠ مكتوبين بالإيد قبل كل عنوان، وأول ما حد يضيف قسم
              // جديد وينسى السطر ده التناسق بيقع.

              // **البؤرة.** مايتبنيش خالص لو مفيش حجز — مش كارت فاضي.
              //
              // ومش ملفوف في `_gutter` عن قصد: ده `AppBandWidget` بياخد
              // العرض كله. وبيبدأ من هنا مش من فوق عشان **مايلمسش شريط
              // الحالة** — لوح حبر واصل للنوتش بيقرا كروم مش محتوى.
              //
              // **مفيش `BlocProvider` هنا.** الـ `BranchQueueCubit` بيتعمل
              // مرة واحدة في `ButtonNavigationBarScreen` فوق الأربع تبويبات،
              // والبؤرة دي والشريط اللي فوق التبويبات بيقروا **من نفس
              // النسخة**.
              //
              // لو كل واحد عمل نسخته، بيبقى فيه **مؤقتين ومصدرين حقيقة**
              // يقدروا يختلفوا على الشاشة في نفس اللحظة — الشريط يقول
              // «دورك دلوقتي» والبؤرة لسه بتقول «٢ قدامك». ده أوحش من
              // إن الشريط مايبقاش موجود أصلاً.
              if (cubit.upcomingBooking != null) ...[
                verticalSpace(AppSpacing.sectionBreak),
                const BranchQueueHeroSectionWidget(),
              ],

              _gutter(
                AppSectionHeaderWidget(
                  title: 'الأكثر طلبًا',
                  actionLabel: 'عرض الكل',
                  onAction: () =>
                      context.pushNamed(Routes.providersListScreen),
                ),
              ),
              HomeProvidersRailWidget(
                providers: cubit.popularProviders,
                isLoading: isLoading,
                onProviderTap: (provider) => context.pushNamed(
                  Routes.serviceProviderDetailsScreen,
                  arguments: {'providerUuid': provider.uuid},
                ),
              ),

              _gutter(
                AppSectionHeaderWidget(
                  title: 'قريب منك',
                  actionLabel: 'عرض الكل',
                  onAction: () =>
                      context.pushNamed(Routes.providersListScreen),
                ),
              ),
              // مش ملفوف في `_gutter`: بقت صفوف full-bleed، والهامش ١٦
              // جوه الصف نفسه. لو لفّيناها هنا كمان الهامش هيبقى ٣٢
              // والخط الشعري هيبدأ من ١٠٠ بدل ٨٤ — يعني مش هيتلاقى مع
              // إزاحة أي قايمة تانية في الأبلكيشن.
              HomeNearbyWidget(
                providers: cubit.nearbyProviders,
                isLoading: isLoading,
                onProviderTap: (provider) => context.pushNamed(
                  Routes.serviceProviderDetailsScreen,
                  arguments: {'providerUuid': provider.uuid},
                ),
                onWidenSearch: cubit.loadHome,
              ),
            ],
          ),
        );
      },
    );
  }

  /// هامش الصفحة — **للي مش شايل هامشه بنفسه بس**.
  ///
  /// اللي بره الهامش عن قصد: الصفوف الأفقية (بتاخد العرض كله عشان الكارت
  /// الأخير يبان مقصوص من الحافة، وده اللي بيقول للعميل «فيه كمان»)،
  /// لوح الحبر (`AppBandWidget` بياخد العرض كله)، وقايمة «قريب منك»
  /// (صفوف full-bleed هامشها جواها).
  Widget _gutter(Widget child) => Padding(
    padding: EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.pageGutter.w,
    ),
    child: child,
  );
}
