import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF1ABC9C),
  secondaryHeaderColor: Color(0XFF26FDD3),
  // warna selingan

  hintColor: Color(0XFF1ABC9C),
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
