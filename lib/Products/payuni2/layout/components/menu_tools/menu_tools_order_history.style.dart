import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/payuni2/color.dart';

abstract class MenuToolsOrderHistoryStyle {
  static ParentStyle iconWrapper = ParentStyle()
    ..padding(vertical: 7)
    ..borderRadius(all: 20)
    ..background.color(colors.primaryColor.withOpacity(.1))
    ..margin(left: 15.0, right: 12.0)
    ..padding(all: 8.0);

  static TxtStyle text = TxtStyle()
    ..fontSize(12)
    ..textColor(Colors.black);
}
