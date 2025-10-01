import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class MenuToolsStyle {
  static ParentStyle wrapper = ParentStyle()
    ..padding(vertical: 7)
    ..background.color(Colors.white)
    ..borderRadius(all: 10)
    ..boxShadow(
      color: Colors.black.withOpacity(.1),
      spread: 2,
      blur: 5,
      offset: Offset(0, 3),
    );
}
