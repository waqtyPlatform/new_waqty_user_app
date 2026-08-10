import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/provider_row_skeleton_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_widget.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_cubit.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_state.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/widgets/providers_list_filters_widget.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/widgets/providers_list_search_bar_widget.dart';

class ProvidersListScreen extends StatelessWidget {
  /// لما نيجي من زرار البحث في الهوم، الكيبورد يفتح على طول.
  final bool autofocusSearch;

  const ProvidersListScreen({super.key, this.autofocusSearch = false});

  @override
  Widget build(BuildContext context) {
    // **مفيش Scaffold هنا.** الشاشة دي بتشتغل في حالتين: تبويب جوه
    // `ButtonNavigationBarScreen` (اللي عنده Scaffold بالفعل)، وroute مدفوع
    // من البحث ومن «عرض الكل».
    //
    // لما كان فيه Scaffold هنا، حالة التبويب كانت Scaffold جوه Scaffold —
    // نفس الباج اللي `HomeScreen` موثّق إنه اتفادى (الـ SnackBars والـ
    // sheets بتتحل على الـ Scaffold الغلط)، وكمان إدخال شريط الحالة كان
    // بيتحسب مرتين.
    //
    // الـ Scaffold بتاع حالة الـ route بقى في `app_routes.dart` — مكان واحد،
    // من غير فلاج.
    return BlocBuilder<ProvidersListCubit, ProvidersListState>(
      builder: (context, state) {
        final cubit = ProvidersListCubit.get(context);

        return Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
              ),
              child: ProvidersListSearchBarWidget(
                controller: cubit.searchController,
                autofocus: autofocusSearch,
                onChanged: cubit.search,
                onClear: cubit.clearFilters,
              ),
            ),
            verticalSpace(AppSpacing.s12),
            ProvidersListFiltersWidget(
              categories: cubit.categories,
              selectedCategoryUuid: cubit.selectedCategoryUuid,
              onCategoryTap: cubit.changeCategory,
            ),
            verticalSpace(AppSpacing.s12),
            Expanded(child: _body(context, cubit, state)),
          ],
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ProvidersListCubit cubit,
    ProvidersListState state,
  ) {
    // الانتقال من الـ skeleton للمحتوى بيتلاشى بدل ما ينطّ.
    return AnimatedSwitcher(
      duration: AppMotion.slow,
      switchInCurve: AppMotion.standard,
      child: _content(context, cubit, state),
    );
  }

  Widget _content(
    BuildContext context,
    ProvidersListCubit cubit,
    ProvidersListState state,
  ) {
    // **الهامش الأفقي اتشال خالص.** `ProviderRowWidget` صف full-bleed شايل
    // الـ ١٦ بتاعه **جواه**، فلو الـ `ListView` كمان حطّ ١٦ يبقى الصف على
    // ٣٢ والخط الشعري عمره ما هيوصل لحافة الشاشة.
    //
    // **الهامش السفلي واحد لكل الحالات.** قبل كده التحميل مكانش ليه هامش
    // والمحمّل عنده ٢٤ — فاللستة كانت **بتنطّ ٢٤ بكسل** لما الداتا توصل.
    final padding = EdgeInsetsDirectional.only(
      bottom: AppSpacing.screenBottom.h,
    );

    // مفيش `separatorBuilder` في اللستتين: الصف بيرسم خطه الشعري بنفسه، فأي
    // فاصل هنا معناه **فاصلين** — خط ومسافة ورا بعض.
    if (state is ProvidersListLoadingState || state is InitialState) {
      const skeletonCount = 5;
      return ListView.builder(
        key: const ValueKey('loading'),
        padding: padding,
        itemCount: skeletonCount,
        itemBuilder: (_, index) =>
            ProviderRowSkeletonWidget(showHairline: index != skeletonCount - 1),
      );
    }

    if (state is ProvidersListErrorState) {
      return Padding(
        key: const ValueKey('error'),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.pageGutter.w,
        ),
        child: AppErrorStateWidget(
          message: state.message,
          onRetry: cubit.search,
        ),
      );
    }

    // الفاضي **مش** محتاج الـ `pageGutter` هنا — `AppEmptyStateWidget` بيوسّط
    // نفسه وشايل ٣٢ أفقي جواه، فأي هامش زيادة هيبقى ٤٨ ويكسر السطر بدري.
    if (state is ProvidersListEmptyState) {
      return AppEmptyStateWidget(
        key: const ValueKey('empty'),
        icon: Icons.search_off_rounded,
        title: 'مفيش نتايج',
        message: cubit.searchController.text.isEmpty
            ? 'مفيش أماكن في التصنيف ده'
            : 'مفيش نتايج لـ «${cubit.searchController.text}»',
        actionLabel: 'امسح الفلاتر',
        onAction: cubit.clearFilters,
      );
    }

    return ListView.builder(
      key: const ValueKey('data'),
      padding: padding,
      itemCount: cubit.providers.length,
      itemBuilder: (context, index) {
        final provider = cubit.providers[index];
        // آخر صف من غير خط — الخط تحت الأخير بيرسم حد لقايمة مالهاش حد.
        return ProviderRowWidget(
          provider: provider,
          showHairline: index != cubit.providers.length - 1,
          onTap: () => context.pushNamed(
            Routes.serviceProviderDetailsScreen,
            arguments: {'providerUuid': provider.uuid},
          ),
        );
      },
    );
  }
}
