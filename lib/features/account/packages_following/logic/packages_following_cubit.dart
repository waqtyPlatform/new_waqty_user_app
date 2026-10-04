import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_state.dart';

class PackagesFollowingCubit extends Cubit<PackagesFollowingState> {
  PackagesFollowingCubit() : super(const PackagesFollowingInitialState());

  PackagesFollowingTab selectedTab = PackagesFollowingTab.packages;

  final ReservedPackageModel reservedPackage = const ReservedPackageModel(
    titleKey: 'packagesFollowing.reservedTitle',
    providerKey: 'packagesFollowing.reservedProvider',
    statusKey: 'packagesFollowing.reservedStatus',
    price: '1350',
    priceLabelKey: 'packagesFollowing.payAtBranch',
    remainingKey: 'packagesFollowing.remainingFiveDays',
    progress: 0.28,
    noteKey: 'packagesFollowing.reservedNote',
  );

  final List<PackageCardModel> packages = const [
    PackageCardModel(
      titleKey: 'packagesFollowing.hairPackageTitle',
      providerKey: 'packagesFollowing.captainSalonBranch',
      statusKey: 'packagesFollowing.validStatus',
      status: PackageFollowStatus.valid,
      availableValue: '3',
      availableLabelKey: 'packagesFollowing.fromEightSessions',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 3,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.reservedLegend',
          color: AppColors.warningColor100,
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedFourLegend',
          color: AppColors.greyColor900,
          flex: 4,
        ),
      ],
      legend: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.reservedLegend',
          color: AppColors.warningColor100,
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedFourLegend',
          color: AppColors.greyColor900,
          flex: 1,
        ),
      ],
      metaKey: 'packagesFollowing.hairPackageMeta',
    ),
    PackageCardModel(
      titleKey: 'packagesFollowing.massagePackageTitle',
      providerKey: 'packagesFollowing.relaxCenterBranch',
      statusKey: 'packagesFollowing.validStatus',
      status: PackageFollowStatus.valid,
      availableValue: '120',
      availableLabelKey: 'packagesFollowing.fromThreeHundredMinutes',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 120,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.expiredFifteenLegend',
          color: Color(0xffE4E2DB),
          flex: 15,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedOneSixtyFiveLegend',
          color: AppColors.greyColor900,
          flex: 165,
        ),
      ],
      legend: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.expiredFifteenLegend',
          color: Color(0xffE4E2DB),
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedOneSixtyFiveLegend',
          color: AppColors.greyColor900,
          flex: 1,
        ),
      ],
      metaKey: 'packagesFollowing.massagePackageMeta',
      noteKey: 'packagesFollowing.massagePackageNote',
    ),
    PackageCardModel(
      titleKey: 'packagesFollowing.facialPackageTitle',
      providerKey: 'packagesFollowing.captainSalonBranch',
      statusKey: 'packagesFollowing.expiredStatus',
      status: PackageFollowStatus.expired,
      availableValue: '2',
      availableLabelKey: 'packagesFollowing.fromSixUnusedSessions',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.unusedLegend',
          color: Color(0xffC4415C),
          flex: 2,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedFourLegend',
          color: AppColors.greyColor900,
          flex: 4,
        ),
      ],
      legend: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.unusedLegend',
          color: Color(0xffC4415C),
          flex: 1,
        ),
        PackageSegmentModel(
          labelKey: 'packagesFollowing.usedFourLegend',
          color: AppColors.greyColor900,
          flex: 1,
        ),
      ],
      metaKey: 'packagesFollowing.facialPackageMeta',
      noteKey: 'packagesFollowing.facialPackageNote',
    ),
  ];

  final List<PackageCardModel> following = const [
    PackageCardModel(
      titleKey: 'packagesFollowing.skinFollowTitle',
      providerKey: 'packagesFollowing.captainSalonBranch',
      statusKey: 'packagesFollowing.validStatus',
      status: PackageFollowStatus.valid,
      availableValue: '1',
      availableLabelKey: 'packagesFollowing.fromOneVisit',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 1,
        ),
      ],
      legend: [],
      metaKey: 'packagesFollowing.skinFollowMeta',
    ),
    PackageCardModel(
      titleKey: 'packagesFollowing.laserFollowTitle',
      providerKey: 'packagesFollowing.captainSalonBranch',
      statusKey: 'packagesFollowing.validStatus',
      status: PackageFollowStatus.valid,
      availableValue: '1',
      availableLabelKey: 'packagesFollowing.fromOneVisit',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 1,
        ),
      ],
      legend: [],
      metaKey: 'packagesFollowing.laserFollowMeta',
    ),
    PackageCardModel(
      titleKey: 'packagesFollowing.teethFollowTitle',
      providerKey: 'packagesFollowing.captainSalonBranch',
      statusKey: 'packagesFollowing.pausedStatus',
      status: PackageFollowStatus.paused,
      availableValue: '1',
      availableLabelKey: 'packagesFollowing.fromOneVisit',
      segments: [
        PackageSegmentModel(
          labelKey: 'packagesFollowing.availableLegend',
          color: AppColors.greenColor500,
          flex: 1,
        ),
      ],
      legend: [],
      metaKey: 'packagesFollowing.teethFollowMeta',
      noteKey: 'packagesFollowing.teethFollowNote',
    ),
  ];

  void changeTab(PackagesFollowingTab tab) {
    if (selectedTab == tab) return;
    selectedTab = tab;
    emit(PackagesFollowingTabChangedState(tab: tab));
  }

  static PackagesFollowingCubit get(context) => BlocProvider.of(context);
}
