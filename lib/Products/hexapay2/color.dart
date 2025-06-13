import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF2E5AAC),
  secondaryHeaderColor: Color(0XFFF9B32F),
  hintColor: Color(0XFF2E5AAC),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(foregroundColor: Colors.white),
  appBarTheme: AppBarTheme(
    // color: Colors.white,
    elevation: 0.0,
    iconTheme: IconThemeData().copyWith(color: Colors.white),
  ),
);
