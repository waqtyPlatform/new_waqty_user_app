import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/explore/logic/explore_categories_cubit.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/explore/ui/widgets/explore_design_widgets.dart';

enum ExploreViewState { content, loading, empty, offline }

class ExploreScreen extends StatelessWidget {
  final bool isLoading;
  final ExploreViewState? state;

  const ExploreScreen({super.key, this.isLoading = false, this.state});

  @override
  Widget build(BuildContext context) {
    final currentState =
        state ??
        (isLoading ? ExploreViewState.loading : ExploreViewState.content);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExploreCategoriesCubit(getIt())..loadCategories(),
        ),
        BlocProvider(create: (_) => HomeCubit(getIt())),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.pageColor,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.greyColor900,
              onRefresh: () => context
                  .read<ExploreCategoriesCubit>()
                  .loadCategories(force: true),
              child: _body(currentState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(ExploreViewState currentState) {
    return switch (currentState) {
      ExploreViewState.loading => const ExploreLoadingContent(),
      ExploreViewState.empty => const ExploreEmptyContent(),
      ExploreViewState.offline => const ExploreOfflineContent(),
      ExploreViewState.content => const ExploreContent(),
    };
  }
}
