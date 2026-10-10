import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/nearby_offers/logic/nearby_offers_cubit.dart';
import 'package:waqty_user_application/features/home/nearby_offers/logic/nearby_offers_state.dart';
import 'package:waqty_user_application/features/home/nearby_offers/ui/widgets/nearby_offer_card.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_app_bar.dart';

class NearbyOffersScreen extends StatelessWidget {
  const NearbyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageColor,
    appBar: SubcategoriesAppBar(title: context.tr('home.nearOffersTitle')),
    body: SafeArea(
      child: BlocBuilder<NearbyOffersCubit, NearbyOffersState>(
        builder: (context, state) {
          final cubit = context.read<NearbyOffersCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _NearbyOffersPageShimmer();
          }
          if (state is NearbyOffersErrorState && cubit.items.isEmpty) {
            return _NearbyOffersMessage(
              message: state.message.trim().isEmpty
                  ? context.tr('home.nearbyOffersLoadError')
                  : state.message,
              actionLabel: context.tr('home.availableNowRetry'),
              onAction: cubit.load,
            );
          }
          if (cubit.items.isEmpty) {
            return _NearbyOffersMessage(
              message: context.tr('home.nearbyOffersEmpty'),
            );
          }
          return RefreshIndicator(
            color: AppColors.greyColor900,
            onRefresh: cubit.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 320) cubit.loadMore();
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                itemCount: cubit.items.length + (cubit.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  if (index == cubit.items.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.greyColor900,
                        ),
                      ),
                    );
                  }
                  return NearbyOfferCard(
                    offer: cubit.items[index],
                    width: double.infinity,
                  );
                },
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _NearbyOffersMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NearbyOffersMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 120.h),
    children: [
      Icon(
        Icons.local_offer_outlined,
        size: 44.sp,
        color: AppColors.greyColor300,
      ),
      SizedBox(height: 14.h),
      Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyles.font16greyColor900Weight600,
      ),
      if (actionLabel != null && onAction != null) ...[
        SizedBox(height: 18.h),
        Center(
          child: FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greyColor900,
              foregroundColor: AppColors.whiteColor,
            ),
            child: Text(actionLabel!),
          ),
        ),
      ],
    ],
  );
}

class _NearbyOffersPageShimmer extends StatelessWidget {
  const _NearbyOffersPageShimmer();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
    itemCount: 5,
    separatorBuilder: (_, __) => SizedBox(height: 14.h),
    itemBuilder: (_, __) =>
        const NearbyOfferShimmerCard(width: double.infinity),
  );
}
