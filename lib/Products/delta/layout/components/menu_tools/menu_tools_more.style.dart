// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class MenuToolsMoreStyle {
  static ParentStyle swapper = ParentStyle()
    ..height(4)
    ..width(50)
    ..background.color(Colors.grey[400])
    ..borderRadius(all: 20);

  static ParentStyle iconWrapper = ParentStyle()
    ..height(40)
    ..width(40)
    ..padding(all: 8);

  static TxtStyle text = TxtStyle()
    ..fontSize(10)
    ..textColor(Colors.grey.shade800)
    ..textAlign.center(true);
}
