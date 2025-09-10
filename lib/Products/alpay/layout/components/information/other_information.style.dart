import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/debug_helper.dart';

abstract class OtherInformationStyle {
  static TxtStyle text = TxtStyle()
    ..maxLines(1)
    ..textOverflow(TextOverflow.ellipsis);
}
