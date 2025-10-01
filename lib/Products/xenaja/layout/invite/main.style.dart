import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/xenaja/color.dart';

abstract class InviteMainStyle {
  static ParentStyle bgGradient = ParentStyle()
    ..height(double.infinity)
    ..linearGradient(
      colors: [
        colors.primaryColor,
        colors.primaryColor.withOpacity(0.3),
      ],
      stops: [0.0, 1.0],
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
      tileMode: TileMode.repeated,
    );
}
