import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/nearby_offers/logic/nearby_offers_cubit.dart';
import 'package:waqty_user_application/features/home/nearby_offers/logic/nearby_offers_state.dart';
import 'package:waqty_user_application/features/home/nearby_offers/ui/widgets/nearby_offer_card.dart';

class HomeNearbyOffersSection extends StatelessWidget {
  const HomeNearbyOffersSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => NearbyOffersCubit(getIt())..load(),
    child: const _HomeNearbyOffersContent(),
  );
}

class _HomeNearbyOffersContent extends StatelessWidget {
  const _HomeNearbyOffersContent();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NearbyOffersCubit, NearbyOffersState>(
        builder: (context, state) {
          final cubit = context.read<NearbyOffersCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _NearbyOffersSectionShimmer();
          }
          if (cubit.items.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const _NearbyOffersHeader(),
              SizedBox(
                height: 204.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: cubit.items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) =>
                      NearbyOfferCard(offer: cubit.items[index]),
                ),
              ),
            ],
          );
        },
      );
}

class _NearbyOffersHeader extends StatelessWidget {
  const _NearbyOffersHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
    child: SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('home.nearOffersTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
                Text(
                  context.tr('home.nearOffersSubtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.nearbyOffersScreen),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Text(
                context.tr('home.seeAll'),
                style: TextStyles.font12greenColor500W600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _NearbyOffersSectionShimmer extends StatelessWidget {
  const _NearbyOffersSectionShimmer();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _NearbyOffersHeader(),
      SizedBox(
        height: 204.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, __) => const NearbyOfferShimmerCard(),
        ),
      ),
    ],
  );
}
