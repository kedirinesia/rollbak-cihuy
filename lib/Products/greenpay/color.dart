

import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: Color(0XFF0EAC51),
  secondaryHeaderColor: Color(0XFFf39c12),
  
  hintColor: Color(0XFF0EAC51),
  canvasColor: Colors.white,
  scaffoldBackgroundColor : Colors.white,
  floatingActionButtonTheme:
        FloatingActionButtonThemeData(foregroundColor: Colors.white),
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    
    iconTheme: IconThemeData().copyWith(
      color: Colors.white
    )
  )
);