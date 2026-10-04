import 'package:flutter/material.dart';

class AccountMenuItemModel {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AccountMenuItemModel({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });
}
