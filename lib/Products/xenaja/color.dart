import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF9B59B6),
  secondaryHeaderColor: Color(0XFFDCC6E0),
  hintColor: Color(0XFF9B59B6),
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
