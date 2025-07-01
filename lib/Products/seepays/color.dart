import 'package:flutter/material.dart';

ThemeData colors = ThemeData.light().copyWith(
  primaryColor: const Color(0xFFA259FF),               
  secondaryHeaderColor: const Color(0xFFf39c12),
  hintColor: const Color(0xFFA259FF),                
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ThemeData.light().colorScheme.copyWith(
    secondary: const Color(0xFFA259FF),              
    primary: const Color(0xFFA259FF),               
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
);
