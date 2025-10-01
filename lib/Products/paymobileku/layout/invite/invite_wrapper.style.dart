import 'package:flutter/material.dart';

abstract class InviteWrapperStyle {
  static BoxDecoration wrapperDecoration = BoxDecoration(
    color: Colors.white.withOpacity(.7),
    borderRadius: BorderRadius.circular(25),
  );

  static EdgeInsets wrapperPadding = const EdgeInsets.all(10);
  static EdgeInsets wrapperMargin = const EdgeInsets.symmetric(horizontal: 10, vertical: 20);
}
