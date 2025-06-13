// @dart=2.9

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFFD50222), // Warna sebelumnya 0XFF29C5FF
  secondaryHeaderColor: Color(0XFFF9B32F),
  // warna selingan

  hintColor: Color(0XFFD50222),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    // color: Colors.white,
    elevation: 0.0,
    iconTheme: IconThemeData().copyWith(color: Colors.white),
  ),
);
