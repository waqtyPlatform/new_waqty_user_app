import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_app_bar_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_categories_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_nearby_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_providers_rail_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/create_booking_sheet.dart';
import 'package:waqty_user_application/features/booking/in_branch/ui/widgets/in_branch_hero_section_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_rebook_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_search_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_waitlist_offer_widget.dart';

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
              child: AppErrorStateWidget(
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
              // **أول الصفحة مش فراغ.**
              //
              // التحية والمدينة والبحث كانوا قاعدين على لون الصفحة الصافي،
              // فأول ٢٠٠ بكسل في الأبلكيشن مالهمش أي عمق. الهالة بتدّي
              // للصفحة نقطة بداية من غير ما تحط عنصر جديد يتقري — بتنتهي
              // عند شفافية صفر فمفيش حافة ولا مربع.
              //
              // مش ملفوفة في `_gutter`: الهالة لازم تاخد العرض كله، والهامش
              // بيتحط لولادها.
              AppRevealWidget(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.pageGlow),
                  child: Column(
                    children: [
                      _gutter(HomeAppBarWidget(cityName: cubit.selectedCity)),
                      verticalSpace(AppSpacing.s16),
                      _gutter(
                        HomeSearchWidget(
                          onTap: () =>
                              context.pushNamed(Routes.providersListScreen),
                        ),
                      ),
                      verticalSpace(AppSpacing.s24),
                    ],
                  ),
                ),
              ),

              AppRevealWidget(
                index: 1,
                child: HomeCategoriesWidget(
                  categories: cubit.categories,
                  isLoading: isLoading,
                  onCategoryTap: (category) => context.pushNamed(
                    Routes.providersListScreen,
                    arguments: {'categoryUuid': category.uuid},
                  ),
                ),
              ),

              // مفيش `verticalSpace` قبل أي لابل قسم من هنا ورايح —
              // `AppSectionHeaderWidget` شايل الفاصل ٤٠ والمسافة ٨ بنفسه.
              // كانوا ٢٠ مكتوبين بالإيد قبل كل عنوان، وأول ما حد يضيف قسم
              // جديد وينسى السطر ده التناسق بيقع.

              // **العرض بعدّاده فوق البؤرة.**
              //
              // البؤرة بتقول «موعدك الجاي» — حاجة مضمونة ومالهاش وقت
              // بيجري. العرض ده عكسها بالظبط: ٥ دقايق وبعدين يروح لحد
              // تاني. اللي بيموت بيتقدّم.
              //
              // القسم بيطوّي نفسه لصفر لما مفيش عرض شغّال، فالترتيب ده
              // مالوش تكلفة في الحالة الغالبة.
              const AppRevealWidget(index: 2, child: HomeWaitlistOfferWidget()),

              // **البؤرة.** مايتبنيش خالص لو مفيش حجز — مش كارت فاضي.
              //
              // ومش ملفوف في `_gutter` عن قصد: ده `AppBandWidget` بياخد
              // العرض كله. وبيبدأ من هنا مش من فوق عشان **مايلمسش شريط
              // الحالة** — لوح حبر واصل للنوتش بيقرا كروم مش محتوى.
              //
              // **مفيش `BlocProvider` هنا.** الـ `InBranchCubit` بيتعمل
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
                const AppRevealWidget(
                  index: 2,
                  child: InBranchHeroSectionWidget(),
                ),
              ],

              // **«زي المرة اللي فاتت» فوق الطية.**
              //
              // بيقعد بعد البؤرة وقبل «الأكثر طلبًا»: اللي بيحصل دلوقتي
              // الأول، بعده اللي غالبًا عايزه، وبعدين الاستكشاف. الترتيب
              // ده بيتبع نية العميل مش تصنيف المحتوى.
              if (cubit.lastCompleted != null) ...[
                verticalSpace(AppSpacing.sectionBreak),
                AppRevealWidget(
                  index: 3,
                  child: _gutter(
                    HomeRebookWidget(
                      booking: cubit.lastCompleted!,
                      onTap: () => _rebook(context, cubit.lastCompleted!),
                    ),
                  ),
                ),
              ],

              AppRevealWidget(
                index: 4,
                child: _gutter(
                  AppSectionHeaderWidget(
                    title: 'الأكثر طلبًا',
                    actionLabel: 'عرض الكل',
                    onAction: () =>
                        context.pushNamed(Routes.providersListScreen),
                  ),
                ),
              ),
              AppRevealWidget(
                index: 4,
                child: HomeProvidersRailWidget(
                  providers: cubit.popularProviders,
                  isLoading: isLoading,
                  onProviderTap: (provider) => context.pushNamed(
                    Routes.serviceProviderDetailsScreen,
                    arguments: {'providerUuid': provider.uuid},
                  ),
                ),
              ),

              _gutter(
                AppSectionHeaderWidget(
                  title: 'قريب منك',
                  actionLabel: 'عرض الكل',
                  onAction: () => context.pushNamed(Routes.providersListScreen),
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

  /// «زي المرة اللي فاتت» → **نفس المحل ونفس الفرع ونفس الخدمة**.
  ///
  /// التلاتة بيتنقلوا من الحجز القديم، فالـ sheet بيفتح على خطوة الميعاد
  /// على طول. اللي فاضل من «زي ما هي» هو الأخصائي — الـ wizard بياخد
  /// خدمة واحدة مبدئية بس، وحجز بكذا خدمة بياخد أولها.
  Future<void> _rebook(BuildContext context, BookingUiModel booking) async {
    final didBook = await CreateBookingSheet.show(
      context,
      providerUuid: booking.providerUuid,
      providerName: booking.providerName,
      branchUuid: booking.branchUuid,
      serviceUuid: booking.items.first.serviceUuid,
    );

    if (didBook == true && context.mounted) {
      Navigator.of(context).pushNamed(Routes.bookingSuccessScreen);
    }
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
