import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waqty_user_application/core/services/location_service.dart';
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

    return BlocProvider(
      create: (_) => ExploreCategoriesCubit(getIt()),
      child: BlocProvider(
        create: (_) => HomeCubit(getIt()),
        child: _ExploreLocationGate(currentState: currentState, body: _body),
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

class _ExploreLocationGate extends StatefulWidget {
  final ExploreViewState currentState;
  final Widget Function(ExploreViewState state) body;

  const _ExploreLocationGate({required this.currentState, required this.body});

  @override
  State<_ExploreLocationGate> createState() => _ExploreLocationGateState();
}

class _ExploreLocationGateState extends State<_ExploreLocationGate> {
  bool _isCheckingLocation = true;
  bool _isLocationDisabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    final isAvailable = await YourLocation.isLocationAvailable();
    if (!mounted) return;
    setState(() {
      _isCheckingLocation = false;
      _isLocationDisabled = !isAvailable;
    });
    if (isAvailable) {
      final homeCubit = context.read<HomeCubit>();
      final categoriesCubit = context.read<ExploreCategoriesCubit>();
      await homeCubit.loadLocation(force: true);
      await categoriesCubit.loadCategories();
    }
  }

  Future<void> _onCurrentLocationSelected(Position position) async {
    await context.read<HomeCubit>().syncCurrentLocation(position);
    if (!mounted) return;
    setState(() => _isLocationDisabled = false);
    await context.read<ExploreCategoriesCubit>().loadCategories(force: true);
  }

  Future<void> _onRefresh() async {
    final isAvailable = await YourLocation.isLocationAvailable();
    if (!mounted) return;
    if (!isAvailable) {
      setState(() => _isLocationDisabled = true);
      return;
    }
    setState(() => _isLocationDisabled = false);
    await context.read<ExploreCategoriesCubit>().loadCategories(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final content = _isCheckingLocation
        ? const ExploreLoadingContent()
        : _isLocationDisabled &&
                widget.currentState == ExploreViewState.content
            ? ExploreContent(
                locationDisabled: true,
                onLocationRequested: _checkLocation,
                onCurrentLocationSelected: _onCurrentLocationSelected,
              )
            : widget.body(widget.currentState);

    return Scaffold(
      backgroundColor: AppColors.pageColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.greyColor900,
          onRefresh: _onRefresh,
          child: content,
        ),
      ),
    );
  }
}
