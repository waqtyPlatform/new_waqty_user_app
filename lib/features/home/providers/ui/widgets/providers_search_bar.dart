import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/providers/logic/providers_cubit.dart';

class ProvidersSearchBar extends StatefulWidget {
  const ProvidersSearchBar({super.key});

  @override
  State<ProvidersSearchBar> createState() => _ProvidersSearchBarState();
}

class _ProvidersSearchBarState extends State<ProvidersSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(BuildContext context, String value) {
    context.read<ProvidersCubit>().search(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
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
          onChanged: (value) => context.read<ProvidersCubit>().search(value),
          onSubmitted: (value) => _submitSearch(context, value),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.tr('home.searchPlaceholder'),
            hintStyle: TextStyles.font16greyColor500Weight400,
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.greenColor600),
            suffixIcon: Icon(Icons.tune_rounded, color: AppColors.greyColor900, size: 20.sp),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}
