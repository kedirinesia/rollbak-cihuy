// ignore_for_file: deprecated_member_use
// ignore_for_file: undefined_named_parameter

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFFF9BF3B),
  secondaryHeaderColor: Color(0XFFf39c12),
  hintColor: Color(0XFFF9BF3B),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    // color: Colors.white,
    elevation: 0.0,
    textTheme: TextTheme().copyWith(
        body1: TextStyle(fontSize: 20.0, color: Colors.white),
        body2: TextStyle(fontSize: 15.0, color: Colors.white)),
    iconTheme: IconThemeData().copyWith(color: Colors.white),
  ),
);
