import 'package:flutter/material.dart';

final Color primaryBlue = Color.fromRGBO(54, 105, 201, 1);

final ThemeData appTheme = ThemeData(
  fontFamily: 'DM Sans',
  primarySwatch: Colors.blue,
  useMaterial3: true,
  
  // Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: primaryBlue,
      fontFamily: 'DM Sans',
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: primaryBlue,
      fontFamily: 'DM Sans',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
      fontFamily: 'DM Sans',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.grey[800],
      fontFamily: 'DM Sans',
    ),
  ),

  // Color Scheme
  colorScheme: ColorScheme.light(
    primary: primaryBlue,
    secondary: primaryBlue.withOpacity(0.8),
    surface: Colors.white,
  ),
  
  // Komponen lainnya
  appBarTheme: AppBarTheme(
    backgroundColor: primaryBlue,
    titleTextStyle: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);