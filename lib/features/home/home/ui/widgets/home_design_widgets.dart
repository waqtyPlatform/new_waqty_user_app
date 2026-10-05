import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HomeHeader extends StatelessWidget {
  final bool isArabic;

  const HomeHeader({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: SizedBox(
        height: 62.h,
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xffD8C6A1),
                      Color(0xff5C4932),
                      Color(0xff1F1918),
                    ],
                  ),
                  boxShadow: _cardShadow(),
                ),
              ),
            ),
            Positioned.fill(
              left: isArabic ? 96.w : 58.w,
              right: isArabic ? 58.w : 96.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _homeText(
                      context,
                      'home.headerGreeting',
                      isArabic ? 'أهلًا يا يوسف' : 'Hi Yousef',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyles.font14greyColor500W400.copyWith(
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: isArabic
                          ? [
                              Text(
                                _homeText(
                                  context,
                                  'home.headerLocation',
                                  isArabic ? 'كوم حمادة' : 'Kom Hamada',
                                ),
                                style: TextStyles.font20greyColor900W600
                                    .copyWith(height: 1.1),
                              ),
                              SizedBox(width: 6.w),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.greyColor900,
                                size: 20,
                              ),
                            ]
                          : [
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.greyColor900,
                                size: 20,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _homeText(
                                  context,
                                  'home.headerLocation',
                                  isArabic ? 'كوم حمادة' : 'Kom Hamada',
                                ),
                                style: TextStyles.font20greyColor900W600
                                    .copyWith(height: 1.1),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: SizedBox(
                width: 88.w,
                child: Stack(
                  children: [
                    Align(
                      alignment: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: _HeaderCircleButton(
                        icon: Icons.notifications_none_rounded,
                        showBadge: true,
                      ),
                    ),
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: const _HeaderCircleButton(
                        icon: Icons.favorite_border_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final bool showBadge;

  const _HeaderCircleButton({required this.icon, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: _cardShadow(),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, color: AppColors.greyColor900, size: 22.sp),
          ),
          if (showBadge)
            Positioned(
              top: 9.h,
              right: 12.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.errorColor100,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  final bool isArabic;

  const HomeSearchBar({super.key, required this.isArabic});

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
          boxShadow: _deepShadow(),
        ),
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: _RoundIcon(
                color: AppColors.greenColor505,
                icon: Icons.search_rounded,
                iconColor: AppColors.greenColor600,
              ),
            ),
            Positioned.fill(
              left: isArabic ? 46.w : 46.w,
              right: isArabic ? 46.w : 46.w,
              child: Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  context.tr('home.searchPlaceholder'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyles.font16greyColor500Weight400,
                ),
              ),
            ),
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: _RoundIcon(
                color: AppColors.sunkenColor,
                icon: Icons.tune_rounded,
                iconColor: AppColors.greyColor900,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCategoriesRow extends StatelessWidget {
  final bool isArabic;

  const HomeCategoriesRow({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final items = [
      _CategoryItem('home.categoryAll', Icons.map_outlined, true),
      _CategoryItem('home.categoryBarber', Icons.content_cut_rounded, false),
      _CategoryItem('home.categoryHair', Icons.brush_outlined, false),
      _CategoryItem('home.categorySkin', Icons.face_retouching_natural, false),
      _CategoryItem('home.categoryDermatology', Icons.spa_outlined, false),
      _CategoryItem(
        'home.categoryDental',
        Icons.medical_services_outlined,
        false,
      ),
      _CategoryItem('home.categoryMassage', Icons.self_improvement, false),
      _CategoryItem('home.categoryNails', Icons.back_hand_outlined, false),
    ];
    return _HorizontalList(
      height: 118.h,
      isArabic: isArabic,
      children: items
          .map(
            (item) => _CategoryTile(
              label: context.tr(item.labelKey),
              icon: item.icon,
              selected: item.selected,
            ),
          )
          .toList(),
    );
  }
}

class HomeAppointmentCard extends StatelessWidget {
  final bool isArabic;

  const HomeAppointmentCard({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 16,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.greyColor900,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: _inkShadow(),
        ),
        child: Column(
          children: [
            _StatusRow(
              isArabic: isArabic,
              rightText: context.tr('home.nextAppointmentStatus'),
              leftText: context.tr('home.payAtPlace'),
              rightColor: AppColors.greenColor50,
              leftColor: AppColors.warningColor50,
              dark: true,
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 82.h,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _TimeTile(isArabic: isArabic),
                  ),
                  Positioned.fill(
                    left: isArabic ? 0 : 96.w,
                    right: isArabic ? 96.w : 0,
                    child: _TextBlock(
                      isArabic: isArabic,
                      titleKey: 'home.nextService',
                      subtitleKey: 'home.nextProvider',
                      thirdKey: 'home.nextSpecialist',
                      light: true,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 44.h,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: _CircleButton(
                      icon: Icons.location_on_outlined,
                      dark: true,
                    ),
                  ),
                  Positioned.fill(
                    left: isArabic ? 52.w : 0,
                    right: isArabic ? 0 : 52.w,
                    child: _PillButton(
                      label: context.tr('home.appointmentDetails'),
                      color: AppColors.whiteColor,
                      textColor: AppColors.greyColor900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeRatingCard extends StatelessWidget {
  final bool isArabic;

  const HomeRatingCard({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 8,
      child: _WhiteCard(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (_) => Icon(
                    Icons.star_border_rounded,
                    color: AppColors.warningColor100,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              left: isArabic ? 166.w : 0,
              right: isArabic ? 0 : 166.w,
              child: _TextBlock(
                isArabic: isArabic,
                titleKey: 'home.rateLastVisit',
                subtitleKey: 'home.lastVisitMeta',
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWaitlistCard extends StatelessWidget {
  final bool isArabic;

  const HomeWaitlistCard({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 12,
      child: _WhiteCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _StatusRow(
              isArabic: isArabic,
              rightText: context.tr('home.waitlistOffer'),
              leftText: context.tr('home.waitlistTimer'),
              rightColor: AppColors.warningColor200,
              leftColor: AppColors.warningColor200,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 68.h,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: const _PhotoBox(size: 52),
                  ),
                  Positioned.fill(
                    left: isArabic ? 0 : 64.w,
                    right: isArabic ? 64.w : 0,
                    child: _TextBlock(
                      isArabic: isArabic,
                      titleKey: 'home.waitlistTitle',
                      subtitleKey: 'home.waitlistMeta',
                      thirdKey: 'home.waitlistNote',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 44.h,
              child: Stack(
                children: [
                  Align(
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: SizedBox(
                      width: 104.w,
                      child: _PillButton(
                        label: context.tr('home.notSuitable'),
                        color: AppColors.sunkenColor,
                        textColor: AppColors.greyColor900,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: isArabic ? 112.w : 0,
                    right: isArabic ? 0 : 112.w,
                    child: _PillButton(
                      label: context.tr('home.bookSlot'),
                      color: AppColors.greyColor900,
                      textColor: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  final bool isArabic;
  final String titleKey;
  final String subtitleKey;

  const HomeSectionHeader({
    super.key,
    required this.isArabic,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionTitleRow(
      isArabic: isArabic,
      title: context.tr(titleKey),
      subtitle: context.tr(subtitleKey),
      top: 20,
    );
  }
}

class HomeCategorySection extends StatelessWidget {
  final bool isArabic;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  const HomeCategorySection({
    super.key,
    required this.isArabic,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionTitleRow(
      isArabic: isArabic,
      title: context.tr(titleKey),
      subtitle: context.tr(subtitleKey),
      icon: icon,
      top: 20,
    );
  }
}

class HomeProviderScroller extends StatelessWidget {
  final bool isArabic;
  final bool wide;

  const HomeProviderScroller({
    super.key,
    required this.isArabic,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    if (wide) {
      final providers = [
        _AvailableProvider(
          titleKey: 'home.providerCaptain',
          metaKey: 'home.providerCaptainMeta',
          slotKey: 'home.availableSlotCaptain',
          rating: '4.9',
          fast: true,
        ),
        _AvailableProvider(
          titleKey: 'home.providerHoda',
          metaKey: 'home.providerHodaMeta',
          slotKey: 'home.availableSlotHoda',
          rating: '4.8',
          fast: false,
        ),
        _AvailableProvider(
          titleKey: 'home.providerFriends',
          metaKey: 'home.providerFriendsMeta',
          slotKey: 'home.availableSlotFriends',
          rating: '4.7',
          fast: false,
        ),
      ];
      return _HorizontalList(
        height: 263.h,
        isArabic: isArabic,
        children: providers
            .map(
              (provider) => _AvailableProviderCard(
                isArabic: isArabic,
                provider: provider,
              ),
            )
            .toList(),
      );
    }

    final providers = [
      ('home.providerCaptain', 'home.providerCaptainMeta'),
      ('home.providerFriends', 'home.providerFriendsMeta'),
      ('home.providerRose', 'home.providerRoseMeta'),
      ('home.providerDerma', 'home.providerDermaMeta'),
    ];
    return _HorizontalList(
      height: wide ? 245.h : 215.h,
      isArabic: isArabic,
      children: providers
          .map(
            (provider) => _ProviderCard(
              isArabic: isArabic,
              titleKey: provider.$1,
              metaKey: provider.$2,
              width: wide ? 190.w : 150.w,
              height: wide ? 233.h : 203.h,
            ),
          )
          .toList(),
    );
  }
}

class _AvailableProviderCard extends StatelessWidget {
  final bool isArabic;
  final _AvailableProvider provider;

  const _AvailableProviderCard({
    required this.isArabic,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 190.w,
      height: 249.h,
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          SizedBox(
            height: 116.h,
            child: Stack(
              children: [
                const _PhotoBox(width: double.infinity, height: 140),
                Positioned(
                  top: 8.h,
                  left: isArabic ? 12.w : null,
                  right: isArabic ? null : 12.w,
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: AppColors.warningColor100,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          provider.rating,
                          style: TextStyles.font14greyColor900Weight500,
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.fast)
                  Positioned(
                    bottom: 12.h,
                    left: isArabic ? null : 12.w,
                    right: isArabic ? 12.w : null,
                    child: Container(
                      height: 34.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor0,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('home.fastBooking'),
                            style: TextStyles.font14greyColor900Weight600
                                .copyWith(color: AppColors.errorColor200),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.trending_up_rounded,
                            size: 16.sp,
                            color: AppColors.errorColor200,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(provider.titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font24greyColor900Weight600.copyWith(
                fontSize: 20.sp,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(provider.metaKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font14greyColor500W400,
            ),
          ),
          const Spacer(),
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: isArabic
                    ? [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.greenColor500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          context.tr(provider.slotKey),
                          style: TextStyles.font16greyColor900Weight600
                              .copyWith(color: AppColors.greenColor600),
                        ),
                      ]
                    : [
                        Text(
                          context.tr(provider.slotKey),
                          style: TextStyles.font16greyColor900Weight600
                              .copyWith(color: AppColors.greenColor600),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.greenColor500,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeOfferScroller extends StatelessWidget {
  final bool isArabic;

  const HomeOfferScroller({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final offers = [
      (
        'home.offerBadge1',
        'home.offerTitle1',
        'home.offerBody1',
        'home.offerMeta1',
      ),
      (
        'home.offerBadge2',
        'home.offerTitle2',
        'home.offerBody2',
        'home.offerMeta2',
      ),
      (
        'home.offerBadge3',
        'home.offerTitle3',
        'home.offerBody3',
        'home.offerMeta3',
      ),
    ];
    return _HorizontalList(
      height: 150.h,
      isArabic: isArabic,
      children: offers
          .map(
            (offer) => _OfferCard(
              isArabic: isArabic,
              badgeKey: offer.$1,
              titleKey: offer.$2,
              bodyKey: offer.$3,
              metaKey: offer.$4,
            ),
          )
          .toList(),
    );
  }
}

class HomeRepeatScroller extends StatelessWidget {
  final bool isArabic;

  const HomeRepeatScroller({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('home.repeatService1', 'home.repeatProvider1', 'home.repeatPrice1'),
      ('home.repeatService2', 'home.repeatProvider2', 'home.repeatPrice2'),
      ('home.repeatService3', 'home.repeatProvider3', 'home.repeatPrice3'),
    ];
    return _HorizontalList(
      height: 153.h,
      isArabic: isArabic,
      children: items
          .map(
            (item) => _RepeatCard(
              isArabic: isArabic,
              titleKey: item.$1,
              metaKey: item.$2,
              priceKey: item.$3,
            ),
          )
          .toList(),
    );
  }
}

class HomeSuggestPlaceCard extends StatelessWidget {
  final bool isArabic;

  const HomeSuggestPlaceCard({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 20,
      child: _WhiteCard(
        height: 91.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: SizedBox(
                width: 88.w,
                height: 38.h,
                child: _PillButton(
                  label: context.tr('home.suggestButton'),
                  color: AppColors.greenColor505,
                  textColor: AppColors.greenColor600,
                ),
              ),
            ),
            Positioned.fill(
              left: isArabic ? 100.w : 0,
              right: isArabic ? 0 : 100.w,
              child: _TextBlock(
                isArabic: isArabic,
                titleKey: 'home.suggestTitle',
                subtitleKey: 'home.suggestSubtitle',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final bool isArabic;
  final String title;
  final String subtitle;
  final IconData? icon;
  final double top;

  const _SectionTitleRow({
    required this.isArabic,
    required this.title,
    required this.subtitle,
    this.icon,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
      child: SizedBox(
        height: 50.h,
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Text(
                context.tr('home.seeAll'),
                style: TextStyles.font12greenColor500W600,
              ),
            ),
            Positioned.fill(
              left: isArabic ? 56.w : 0,
              right: isArabic ? (icon == null ? 0 : 46.w) : 56.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyles.font20greyColor900W600.copyWith(
                      height: 1.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyles.font12greyColor500W400,
                  ),
                ],
              ),
            ),
            if (icon != null)
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.greenColor505,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.greenColor600, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final bool isArabic;
  final double height;
  final List<Widget> children;

  const _HorizontalList({
    required this.isArabic,
    required this.height,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: children.length,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.w,
      height: 96.h,
      padding: EdgeInsets.fromLTRB(6.w, 22.h, 6.w, 12.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.greyColor900 : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: selected ? _tileDarkShadow() : _tileShadow(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: selected ? AppColors.whiteColor : AppColors.greyColor900,
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyles.font12greyColor900Weight400.copyWith(
              color: selected ? AppColors.whiteColor : AppColors.greyColor900,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final bool isArabic;
  final String titleKey;
  final String metaKey;
  final double width;
  final double height;

  const _ProviderCard({
    required this.isArabic,
    required this.titleKey,
    required this.metaKey,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: width,
      height: height,
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          const _PhotoBox(width: double.infinity, height: 100),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font14greyColor900Weight600,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(metaKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 16.sp,
                color: AppColors.warningColor100,
              ),
              SizedBox(width: 2.w),
              Text('4.8', style: TextStyles.font12greyColor900Weight400),
              SizedBox(width: 8.w),
              Icon(
                Icons.schedule_rounded,
                size: 14.sp,
                color: AppColors.greenColor500,
              ),
              SizedBox(width: 2.w),
              Text(
                context.tr('home.todaySlot'),
                style: TextStyles.font12greyColor500W400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final bool isArabic;
  final String badgeKey;
  final String titleKey;
  final String bodyKey;
  final String metaKey;

  const _OfferCard({
    required this.isArabic,
    required this.badgeKey,
    required this.titleKey,
    required this.bodyKey,
    required this.metaKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288.w,
      height: 136.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: _inkShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: _Badge(
              label: context.tr(badgeKey),
              background: AppColors.whiteColor.withValues(alpha: 0.10),
              color: AppColors.greenColor50,
            ),
          ),
          const Spacer(),
          Text(
            context.tr(titleKey),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font20greyColor900W600.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
          Text(
            context.tr(bodyKey),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font14whiteColorWeight400,
          ),
          Text(
            context.tr(metaKey),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font12whiteColorWeight600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.65),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatCard extends StatelessWidget {
  final bool isArabic;
  final String titleKey;
  final String metaKey;
  final String priceKey;

  const _RepeatCard({
    required this.isArabic,
    required this.titleKey,
    required this.metaKey,
    required this.priceKey,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 300.w,
      height: 141.h,
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          SizedBox(
            height: 67.h,
            child: Stack(
              children: [
                Align(
                  alignment: isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: const _PhotoBox(size: 52),
                ),
                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Text(
                    context.tr(priceKey),
                    style: TextStyles.font12greyColor500W600,
                  ),
                ),
                Positioned.fill(
                  left: isArabic ? 54.w : 54.w,
                  right: isArabic ? 54.w : 54.w,
                  child: _TextBlock(
                    isArabic: isArabic,
                    titleKey: titleKey,
                    subtitleKey: metaKey,
                    thirdKey: 'home.repeatLastTime',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 34.h,
            child: Stack(
              children: [
                Align(
                  alignment: isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    context.tr('home.repeatAvailable'),
                    style: TextStyles.font12greyColor500W400,
                  ),
                ),
                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: SizedBox(
                    width: 135.w,
                    child: _PillButton(
                      label: context.tr('home.repeatButton'),
                      color: AppColors.greenColor505,
                      textColor: AppColors.greenColor600,
                      height: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final bool isArabic;
  final String rightText;
  final String leftText;
  final Color rightColor;
  final Color leftColor;
  final bool dark;

  const _StatusRow({
    required this.isArabic,
    required this.rightText,
    required this.leftText,
    required this.rightColor,
    required this.leftColor,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10.w) / 2;
          return Stack(
            children: [
              Positioned(
                right: isArabic ? 0 : null,
                left: isArabic ? null : 0,
                top: 0,
                width: itemWidth,
                child: _DotLabel(
                  label: rightText,
                  color: rightColor,
                  isArabic: isArabic,
                ),
              ),
              Positioned(
                left: isArabic ? 0 : null,
                right: isArabic ? null : 0,
                top: 0,
                width: itemWidth,
                child: _Badge(
                  label: leftText,
                  background: dark
                      ? AppColors.warningColor100.withValues(alpha: 0.14)
                      : AppColors.warningColor0,
                  color: leftColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final bool isArabic;
  final String titleKey;
  final String subtitleKey;
  final String? thirdKey;
  final bool light;
  final bool compact;

  const _TextBlock({
    required this.isArabic,
    required this.titleKey,
    required this.subtitleKey,
    this.thirdKey,
    this.light = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? AppColors.whiteColor : AppColors.greyColor900;
    final bodyColor = light
        ? AppColors.whiteColor.withValues(alpha: 0.62)
        : AppColors.greyColor500;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr(titleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: TextStyles.font16greyColor900Weight600.copyWith(
            color: titleColor,
            height: 1.3,
          ),
        ),
        SizedBox(height: compact ? 1.h : 3.h),
        Text(
          context.tr(subtitleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: TextStyles.font12greyColor500W400.copyWith(color: bodyColor),
        ),
        if (thirdKey != null)
          Text(
            context.tr(thirdKey!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font12greyColor500W400.copyWith(color: bodyColor),
          ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final bool isArabic;

  const _TimeTile({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82.w,
      height: 82.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr('home.today'),
            style: TextStyles.font12whiteColorWeight600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '4:30',
            style: TextStyles.font32greyColor900Weight600.copyWith(
              color: AppColors.whiteColor,
              height: 1.1,
            ),
          ),
          Text(
            context.tr('home.pm'),
            style: TextStyles.font12whiteColorWeight600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.70),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final double height;

  const _PillButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font12greyColor900Weight400.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _Badge({
    required this.label,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor500W600.copyWith(color: color),
      ),
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool isArabic;

  const _DotLabel({
    required this.label,
    required this.color,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22.h,
      child: Stack(
        children: [
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned.fill(
            left: isArabic ? 0 : 12.w,
            right: isArabic ? 12.w : 0,
            child: Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyles.font12greyColor500W600.copyWith(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double size;

  const _RoundIcon({
    required this.color,
    required this.icon,
    required this.iconColor,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size.sp),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool dark;

  const _CircleButton({required this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: dark
            ? AppColors.whiteColor.withValues(alpha: 0.10)
            : AppColors.sunkenColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: dark ? AppColors.whiteColor : AppColors.greyColor900,
        size: 18.sp,
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const _WhiteCard({
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.greyColor50),
        boxShadow: _cardShadow(),
      ),
      child: child,
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;

  const _PhotoBox({this.width, this.height, this.size});

  @override
  Widget build(BuildContext context) {
    final boxWidth = size?.w ?? width;
    final boxHeight = size?.w ?? height;
    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffF5F5F5), Color(0xffD9D2D6), Color(0xff322935)],
        ),
      ),
    );
  }
}

class _SectionPadding extends StatelessWidget {
  final Widget child;
  final double top;

  const _SectionPadding({required this.child, this.top = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
      child: child,
    );
  }
}

class _CategoryItem {
  final String labelKey;
  final IconData icon;
  final bool selected;

  _CategoryItem(this.labelKey, this.icon, this.selected);
}

class _AvailableProvider {
  final String titleKey;
  final String metaKey;
  final String slotKey;
  final String rating;
  final bool fast;

  const _AvailableProvider({
    required this.titleKey,
    required this.metaKey,
    required this.slotKey,
    required this.rating,
    required this.fast,
  });
}

List<BoxShadow> _cardShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.03),
      blurRadius: 2.r,
      offset: Offset(0, 1.h),
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.16),
      blurRadius: 24.r,
      offset: Offset(0, 10.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _deepShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.20),
      blurRadius: 28.r,
      offset: Offset(0, 12.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _inkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.25),
      blurRadius: 45.r,
      offset: Offset(0, 16.h),
      spreadRadius: -16.r,
    ),
  ];
}

List<BoxShadow> _tileShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.10),
      blurRadius: 16.r,
      offset: Offset(0, 6.h),
      spreadRadius: -10.r,
    ),
  ];
}

List<BoxShadow> _tileDarkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.18),
      blurRadius: 23.r,
      offset: Offset(0, 8.h),
      spreadRadius: -10.r,
    ),
  ];
}

String _homeText(BuildContext context, String key, String fallback) {
  final translated = context.tr(key);
  return translated == key ? fallback : translated;
}
