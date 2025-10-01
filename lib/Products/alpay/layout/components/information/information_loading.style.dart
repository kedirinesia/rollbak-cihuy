import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class InformationLoadingStyle {
  static ParentStyle cardImage = ParentStyle()
    ..height(160)
    ..background.color(Colors.grey.shade400)
    ..borderRadius(topLeft: 12.5, topRight: 12.5);

  static ParentStyle cardTextLine = ParentStyle()
    ..width(250)
    ..height(20)
    ..margin(horizontal: 5.0)
    ..background.color(Colors.grey.shade400)
    ..borderRadius(all: 6);
}
