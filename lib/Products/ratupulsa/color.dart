

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Colors.blue,
  secondaryHeaderColor: Color(0XFFf39c12),
  
  hintColor: Colors.blue,
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