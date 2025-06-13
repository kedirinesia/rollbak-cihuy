

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF17BBB0),
  secondaryHeaderColor: Color(0XFFf39c12),
  
  hintColor: Color(0XFF17BBB0),
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