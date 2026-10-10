import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/book_again/logic/book_again_cubit.dart';
import 'package:waqty_user_application/features/home/book_again/logic/book_again_state.dart';
import 'package:waqty_user_application/features/home/book_again/ui/widgets/book_again_card.dart';

class HomeBookAgainSection extends StatelessWidget {
  const HomeBookAgainSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => BookAgainCubit(getIt())..load(),
    child: const _HomeBookAgainContent(),
  );
}

class _HomeBookAgainContent extends StatelessWidget {
  const _HomeBookAgainContent();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BookAgainCubit, BookAgainState>(
        builder: (context, state) {
          final cubit = context.read<BookAgainCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _BookAgainSectionShimmer();
          }
          if (cubit.items.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const _BookAgainHeader(),
              SizedBox(
                height: 194.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: cubit.items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) =>
                      BookAgainCard(item: cubit.items[index]),
                ),
              ),
            ],
          );
        },
      );
}

class _BookAgainHeader extends StatelessWidget {
  const _BookAgainHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
    child: SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('home.repeatBookingTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
                Text(
                  context.tr('home.repeatBookingSubtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.bookAgainScreen),
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

class _BookAgainSectionShimmer extends StatelessWidget {
  const _BookAgainSectionShimmer();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _BookAgainHeader(),
      SizedBox(
        height: 194.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, __) => const BookAgainShimmerCard(),
        ),
      ),
    ],
  );
}
