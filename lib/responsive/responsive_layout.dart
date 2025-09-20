
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.web,
  });

  static const int mobileMaxWidth = 600;
  static const int tabletMaxWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileMaxWidth) {
          return mobile;
        } else if (constraints.maxWidth < tabletMaxWidth) {
          return tablet;
        } else {
          return web;
        }
      },
    );
  }
}
