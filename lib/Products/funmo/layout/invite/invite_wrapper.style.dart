import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class InviteWrapperStyle {
  static ParentStyle wrapper = ParentStyle()
    ..margin(horizontal: 10, vertical: 20)
    ..padding(all: 10)
    ..background.color(Colors.white.withOpacity(.7))
    ..borderRadius(all: 25);
}
