

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFFd72b8f),
  secondaryHeaderColor: Color(0XFFf39c12),
  
  hintColor: Color(0XFFd72b8f),
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