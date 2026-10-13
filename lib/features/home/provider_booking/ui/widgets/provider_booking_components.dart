import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

import '../../data/models/provider_booking_items_model.dart';

class ProviderBookingTypeSelector extends StatelessWidget {
  final ProviderBookingItemType selected;
  final ValueChanged<ProviderBookingItemType> onChanged;

  const ProviderBookingTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const types = ProviderBookingItemType.values;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final type = types[index];
          final isSelected = type == selected;
          return ChoiceChip(
            showCheckmark: false,
            selected: isSelected,
            onSelected: (_) => onChanged(type),
            label: Text(context.tr(_typeKey(type))),
            labelStyle: isSelected
                ? TextStyles.font14whiteColorWeight500
                : TextStyles.font14greyColor900Weight500,
            selectedColor: AppColors.greenColor500,
            backgroundColor: AppColors.greyColor25,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  String _typeKey(ProviderBookingItemType type) => switch (type) {
    ProviderBookingItemType.services => 'providerBooking.services',
    ProviderBookingItemType.packages => 'providerBooking.offers',
    ProviderBookingItemType.ownedPackages => 'providerBooking.ownedPackages',
    ProviderBookingItemType.followUps => 'providerBooking.followUps',
  };
}

class ProviderBookingChoiceCard extends StatelessWidget {
  final String title, meta;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const ProviderBookingChoiceCard({
    super.key,
    required this.title,
    required this.meta,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.whiteColor,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.greenColor500
                : AppColors.greyColor900.withValues(alpha: .08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyles.font16greyColor900Weight600),
                  if (subtitle?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                  if (meta.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(meta, style: TextStyles.font14greenColor500W500),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.greenColor500
                  : AppColors.greyColor500,
            ),
          ],
        ),
      ),
    ),
  );
}

class ProviderBookingMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const ProviderBookingMessageState({
    super.key,
    required this.icon,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: AppColors.greyColor500),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyles.font14greyColor900Weight400,
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}

class ProviderBookingContinueBar extends StatelessWidget {
  final bool enabled, loading;
  final VoidCallback onPressed;

  const ProviderBookingContinueBar({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: FilledButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.greyColor900,
          disabledBackgroundColor: AppColors.greyColor900.withValues(
            alpha: .18,
          ),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.whiteColor,
                ),
              )
            : Text(
                context.tr('providerBooking.continue'),
                style: TextStyles.font16whiteColorWeight600,
              ),
      ),
    ),
  );
}

class ProviderBookingItemsShimmer extends StatelessWidget {
  const ProviderBookingItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.greyColor100,
    highlightColor: AppColors.greyColor25,
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => Container(
        height: index == 5 ? 92 : 74,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: index.isEven ? .42 : .58,
                    child: const _ShimmerLine(height: 15),
                  ),
                  if (index == 5) ...[
                    const SizedBox(height: 8),
                    const FractionallySizedBox(
                      widthFactor: .76,
                      child: _ShimmerLine(height: 10),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            const _ShimmerCircle(size: 22),
          ],
        ),
      ),
    ),
  );
}

class _ShimmerLine extends StatelessWidget {
  final double height;
  const _ShimmerLine({required this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(999),
    ),
  );
}

class _ShimmerCircle extends StatelessWidget {
  final double size;
  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: AppColors.whiteColor,
      shape: BoxShape.circle,
    ),
  );
}
