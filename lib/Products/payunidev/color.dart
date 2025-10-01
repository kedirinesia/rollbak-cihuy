import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
    primaryColor: Color(0XFF4F5BEB),
    secondaryHeaderColor: Color(0XFFF9B32F),
    // warna selingan

    hintColor: Color(0XFFEA4C88),
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(foregroundColor: Colors.white),
    appBarTheme: AppBarTheme(
        // color: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData().copyWith(color: Colors.white)));
