import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/cached_network_image.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/features/home/subcategories/data/models/subcategory_model.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_cubit.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_state.dart';

class SubcategoriesSearchBar extends StatefulWidget {
  final String categoryUuid;

  const SubcategoriesSearchBar({super.key, required this.categoryUuid});

  @override
  State<SubcategoriesSearchBar> createState() => _SubcategoriesSearchBarState();
}

class _SubcategoriesSearchBarState extends State<SubcategoriesSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: .06),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: (value) => context.read<SubcategoriesCubit>().search(
            categoryUuid: widget.categoryUuid,
            value: value,
          ),
          onSubmitted: (value) => context.read<SubcategoriesCubit>().search(
            categoryUuid: widget.categoryUuid,
            value: value,
          ),
          textAlign: TextAlign.right,
          textDirection: Directionality.of(context),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.tr('home.searchPlaceholder'),
            hintStyle: TextStyles.font16greyColor500Weight400,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.greenColor600,
            ),
            suffixIcon: Icon(
              Icons.tune_rounded,
              color: AppColors.greyColor900,
              size: 20.sp,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}

class SubcategoriesList extends StatelessWidget {
  const SubcategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
      builder: (context, state) {
        if (state is SubcategoriesInitialState ||
            state is SubcategoriesLoadingState) {
          return const _SubcategoriesShimmer();
        }
        if (state is SubcategoriesLoadedState) {
          if (state.subcategories.isEmpty) {
            final hasSearch = context.read<SubcategoriesCubit>().query.isNotEmpty;
            return SubcategoriesEmptyCard(hasSearch: hasSearch);
          }
          return _SubcategoriesList(items: state.subcategories);
        }
        if (state is SubcategoriesErrorState &&
            context.read<SubcategoriesCubit>().query.isNotEmpty) {
          return const SubcategoriesEmptyCard(hasSearch: true);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class SubcategoriesEmptyCard extends StatelessWidget {
  final bool hasSearch;

  const SubcategoriesEmptyCard({super.key, required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.greyColor100),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 62.w,
            height: 62.w,
            decoration: BoxDecoration(
              color: AppColors.sunkenColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearch ? Icons.search_off_rounded : Icons.auto_awesome_outlined,
              color: AppColors.greyColor500,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            context.tr(
              hasSearch
                  ? 'home.subcategoriesNoResultsTitle'
                  : 'home.subcategoriesEmptyTitle',
            ),
            textAlign: TextAlign.center,
            style: TextStyles.font18greyColor900Weight600,
          ),
          SizedBox(height: 6.h),
          Text(
            context.tr(
              hasSearch
                  ? 'home.subcategoriesNoResultsSubtitle'
                  : 'home.subcategoriesEmptySubtitle',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyles.font12greyColor500W400.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _SubcategoriesList extends StatelessWidget {
  final List<SubcategoryModel> items;

  const _SubcategoriesList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _SubcategoryRow(
            item: items[index],
            showDivider: index != items.length - 1,
          ),
      ],
    );
  }
}

class _SubcategoryRow extends StatelessWidget {
  final SubcategoryModel item;
  final bool showDivider;

  const _SubcategoryRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          Routes.providersScreen,
          arguments: {'subcategory_uuid': item.uuid, 'title': item.name},
        ),
        splashColor: AppColors.greyColor50,
        child: Container(
          constraints: BoxConstraints(minHeight: 76.h),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.greyColor100.withValues(alpha: .45),
                      width: .8,
                    ),
                  ),
                )
              : null,
          child: Row(
            // textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyColor25,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.greyColor100.withValues(alpha: .7),
                    ),
                  ),
                  child: item.iconUrl == null
                      ? Icon(
                          Icons.image_outlined,
                          color: AppColors.greyColor300,
                          size: 24.sp,
                        )
                      : CachedNetworkImageWidget(
                          imgUrl: item.iconUrl!,
                          radius: BorderRadius.circular(999.r),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyles.font14greyColor900Weight500,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyColor300,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoriesShimmer extends StatelessWidget {
  const _SubcategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyColor50,
      highlightColor: AppColors.whiteColor,
      child: Column(
        children: List.generate(
          6,
          (_) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              // textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor50,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 120.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
