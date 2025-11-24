import 'package:flutter/material.dart';

class AppTheme {

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      color: Colors.blueGrey[900],
    ),
    // Добавьте другие настройки темы по необходимости
  );
}