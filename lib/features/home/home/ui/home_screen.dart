import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/services/location_service.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_design_widgets.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  final bool isLoading;
  final bool isLocationDisabled;
  final bool isCityUnavailable;
  final bool isOffline;

  const HomeScreen({
    super.key,
    this.isLoading = false,
    this.isLocationDisabled = false,
    this.isCityUnavailable = false,
    this.isOffline = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription<Map<String, bool>>? _connectivitySubscription;
  bool _isOffline = false;
  bool _isLocationDisabled = false;
  bool _isCheckingAccess = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isOffline = widget.isOffline || !MyConnectivity.isOnline();
    _isLocationDisabled = widget.isLocationDisabled;
    unawaited(context.read<HomeCubit>().loadProfile());
    unawaited(context.read<HomeCubit>().loadUpcomingBooking());
    unawaited(context.read<HomeCubit>().loadPendingRatings());
    unawaited(context.read<HomeCubit>().loadWaitlistOffer());
    _connectivitySubscription = MyConnectivity.myStream.listen((status) {
      final isOffline = widget.isOffline || status['result'] != true;
      if (_isOffline != isOffline) {
        setState(() => _isOffline = isOffline);
      }
      if (!isOffline) _refreshLocationAccess();
    });
    _refreshLocationAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().resumeWaitlistOffer();
    }
  }

  Future<void> _refreshLocationAccess() async {
    if (_isOffline || widget.isLocationDisabled || widget.isCityUnavailable) {
      if (mounted) setState(() => _isCheckingAccess = false);
      return;
    }

    if (mounted) setState(() => _isCheckingAccess = true);
    final homeCubit = context.read<HomeCubit>();
    final isAvailable = await YourLocation.isLocationAvailable();
    if (!mounted) return;
    if (_isOffline) {
      setState(() => _isCheckingAccess = false);
      return;
    }
    setState(() {
      _isLocationDisabled = !isAvailable;
      _isCheckingAccess = false;
    });
    if (isAvailable) {
      final position = await YourLocation.getCurrentLocation();
      if (position != null) {
        final updated = await homeCubit.syncCurrentLocation(position);
        if (!updated) await homeCubit.loadLocation(force: true);
      } else {
        await homeCubit.loadLocation(force: true);
      }
      await homeCubit.loadCategories();
    }
  }

  Future<void> _onRefresh() async {
    final homeCubit = context.read<HomeCubit>();
    await MyConnectivity.checkNow();
    final isOnline = MyConnectivity.isOnline();
    if (!isOnline) {
      if (mounted) setState(() => _isOffline = true);
      return;
    }
    if (mounted) setState(() => _isOffline = false);
    unawaited(homeCubit.loadUpcomingBooking());
    unawaited(homeCubit.loadPendingRatings());
    unawaited(homeCubit.loadWaitlistOffer());

    final isLocationAvailable = await YourLocation.isLocationAvailable();
    if (!isLocationAvailable) {
      if (mounted) setState(() => _isLocationDisabled = true);
      return;
    }
    if (mounted) setState(() => _isLocationDisabled = false);
    final position = await YourLocation.getCurrentLocation();
    if (position != null) {
      final updated = await homeCubit.syncCurrentLocation(position);
      if (!updated) await homeCubit.loadLocation(force: true);
    } else {
      await homeCubit.loadLocation(force: true);
    }
    await homeCubit.loadCategories(force: true);
  }

  Future<void> _useCurrentLocation(Position position) async {
    final homeCubit = context.read<HomeCubit>();
    final updated = await homeCubit.syncCurrentLocation(position);
    if (!updated) await homeCubit.loadLocation(force: true);
    if (!mounted) return;
    setState(() {
      _isLocationDisabled = false;
      _isCheckingAccess = false;
    });
    await homeCubit.loadCategories();
  }

  Widget _content() {
    final locationNeedsPrompt = context.select<HomeCubit, bool>(
      (cubit) => cubit.location?.needsPrompt == true,
    );
    if (widget.isLoading) return const HomeLoadingContent();
    if (_isOffline) return const HomeOfflineContent();
    if (_isCheckingAccess) return const HomeContent();
    if (_isLocationDisabled ||
        widget.isCityUnavailable ||
        locationNeedsPrompt) {
      return HomeLocationDisabledContent(
        requestLocation: _isLocationDisabled || locationNeedsPrompt,
        onLocationRequested: _refreshLocationAccess,
        onCurrentLocationSelected: _useCurrentLocation,
      );
    }
    return const HomeContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.greyColor900,
          onRefresh: _onRefresh,
          child: _content(),
        ),
      ),
    );
  }
}
