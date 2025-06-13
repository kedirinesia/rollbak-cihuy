import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ualreload/color.dart';

abstract class MenuToolsBalanceInfoStyle {
  static ParentStyle iconWrapper = ParentStyle()
    ..borderRadius(all: 20)
    ..background.color(colors.primaryColor.withOpacity(.1))
    ..margin(left: 15.0, right: 12.0)
    ..padding(all: 8.0);

  static TxtStyle text = TxtStyle()
    ..fontWeight(FontWeight.bold)
    ..fontSize(12)
    ..textColor(Colors.black);
}
