// @dart=2.9

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF2192FF),
  secondaryHeaderColor: Color(0XFFF9B32F),
  
  hintColor: Color(0XFF2192FF),
  canvasColor: Colors.white,
  scaffoldBackgroundColor : Colors.white,
  appBarTheme: AppBarTheme(
    // color: Colors.white,
    elevation: 0.0,
    
    iconTheme: IconThemeData().copyWith(
      color: Colors.white
    )
  )
);
