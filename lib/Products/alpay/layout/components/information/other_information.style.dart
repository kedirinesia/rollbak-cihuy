import 'package:division/division.dart';
import 'package:flutter/material.dart';

abstract class OtherInformationStyle {
  static TxtStyle text = TxtStyle()
    ..maxLines(1)
    ..textOverflow(TextOverflow.ellipsis);
}
