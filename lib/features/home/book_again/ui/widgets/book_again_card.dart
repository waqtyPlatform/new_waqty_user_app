import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/home/data/models/book_again_model.dart';

class BookAgainCard extends StatelessWidget {
  final BookAgainModel item;
  final double? width;

  const BookAgainCard({super.key, required this.item, this.width});

  @override
  Widget build(BuildContext context) => Container(
    width: width ?? 318.w,
    height: 172.h,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(color: AppColors.greyColor100),
      boxShadow: [
        BoxShadow(
          color: AppColors.greyColor900.withValues(alpha: .08),
          blurRadius: 16.r,
          offset: Offset(0, 6.h),
        ),
      ],
    ),
    child: Stack(
      children: [
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          height: 68.h,
          child: Row(
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [Color(0xFFF0EDF0), Color(0xFF4D454E)],
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font16greyColor900Weight600.copyWith(
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      _providerLine(context, item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font12greyColor500W400,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          context.tr(
                            'home.bookAgainPrice',
                            args: [
                              _price(item.price),
                              _currency(context, item.currency),
                            ],
                          ),
                          style: TextStyles.font12greyColor500W600.copyWith(
                            color: AppColors.greyColor700,
                          ),
                        ),
                        if (item.lastBookedOn != null) ...[
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              context.tr(
                                'home.bookAgainLastTime',
                                args: [
                                  DateFormat(
                                    'd MMMM',
                                    context.locale.toString(),
                                  ).format(item.lastBookedOn!),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.font12greyColor500W400.copyWith(
                                color: AppColors.greyColor400,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: SizedBox(
            width: 148.w,
            height: 34.h,
            child: FilledButton(
              onPressed: () => _openBooking(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.greyColor900,
                foregroundColor: AppColors.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              child: Text(
                context.tr('home.bookAgainButton'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.font12whiteColorWeight600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _openBooking(BuildContext context) {
    Navigator.of(context).pushNamed(
      Routes.providerBookingScreen,
      arguments: {
        'provider_uuid': item.providerUuid,
        'provider_name': item.providerName,
        'branch_uuid': item.branchUuid,
        'service_uuid': item.serviceUuid,
      },
    );
  }
}

class BookAgainShimmerCard extends StatelessWidget {
  final double? width;

  const BookAgainShimmerCard({super.key, this.width});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.greyColor100,
    highlightColor: AppColors.greyColor0,
    child: Container(
      width: width ?? 318.w,
      height: 172.h,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
    ),
  );
}

String _providerLine(BuildContext context, BookAgainModel item) {
  if (item.employeeName.isEmpty) return item.providerName;
  return context.tr(
    'home.bookAgainProviderEmployee',
    args: [item.providerName, item.employeeName],
  );
}

String _price(double value) => NumberFormat('#,##0.##').format(value);

String _currency(BuildContext context, String currency) {
  if (currency.toUpperCase() == 'EGP') {
    return context.locale.languageCode == 'ar' ? 'ج.م' : 'EGP';
  }
  return currency;
}
