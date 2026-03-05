import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(context) => MediaQuery.of(context).size.width < 650;

  static bool isTablet(context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(context) => MediaQuery.of(context).size.width >= 1100;
}
