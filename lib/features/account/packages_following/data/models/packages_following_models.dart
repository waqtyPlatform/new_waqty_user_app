import 'package:flutter/material.dart';

enum PackagesFollowingTab { packages, following }

enum PackageFollowStatus { valid, expired, paused, reserved }

class PackageSegmentModel {
  final String labelKey;
  final Color color;
  final double flex;

  const PackageSegmentModel({
    required this.labelKey,
    required this.color,
    required this.flex,
  });
}

class PackageCardModel {
  final String titleKey;
  final String providerKey;
  final String statusKey;
  final PackageFollowStatus status;
  final String availableValue;
  final String availableLabelKey;
  final List<PackageSegmentModel> segments;
  final List<PackageSegmentModel> legend;
  final String metaKey;
  final String? noteKey;

  const PackageCardModel({
    required this.titleKey,
    required this.providerKey,
    required this.statusKey,
    required this.status,
    required this.availableValue,
    required this.availableLabelKey,
    required this.segments,
    required this.legend,
    required this.metaKey,
    this.noteKey,
  });
}

class ReservedPackageModel {
  final String titleKey;
  final String providerKey;
  final String statusKey;
  final String price;
  final String priceLabelKey;
  final String remainingKey;
  final double progress;
  final String noteKey;

  const ReservedPackageModel({
    required this.titleKey,
    required this.providerKey,
    required this.statusKey,
    required this.price,
    required this.priceLabelKey,
    required this.remainingKey,
    required this.progress,
    required this.noteKey,
  });
}
