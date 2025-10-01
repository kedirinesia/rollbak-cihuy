import 'package:flutter/material.dart';
import 'package:mobile/Products/paymobileku/color.dart';

abstract class InviteMainStyle {
  static BoxDecoration bgGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        colors.primaryColor,
        colors.primaryColor.withOpacity(0.3),
      ],
      stops: [0.0, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.repeated,
    ),
  );
}
