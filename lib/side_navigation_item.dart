import 'package:flutter/material.dart';

class SideNavigationItem {
  bool isHeader;
  bool isBackButton;
  String? label;
  Widget Function(Color? color, double? size) icon;
  Widget? right;
  void Function()? onTap;
  List<SideNavigationItem>? children;

  SideNavigationItem({
    required this.icon,
    this.label,
    this.right,
    this.onTap,
    this.isHeader = false,
    this.isBackButton = false,
    this.children,
  });
}
