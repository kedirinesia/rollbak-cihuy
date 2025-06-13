import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class ProductOfChoiceNothingStyle {
  static ParentStyle wrapper = ParentStyle()
    ..margin(left: 10, right: 10, bottom: 10)
    ..padding(vertical: 50.0)
    ..background.color(Colors.grey.shade200)
    ..borderRadius(all: 6);

  static TxtStyle text = TxtStyle()
    ..fontSize(15.0)
    ..fontWeight(FontWeight.bold)
    ..textColor(Colors.grey);
}
