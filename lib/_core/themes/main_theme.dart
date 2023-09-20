import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_second/_core/my_colors.dart';

ThemeData getMainTheme() {
  return ThemeData(
    primarySwatch: MyColors.brown,
    scaffoldBackgroundColor: MyColors.green,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MyColors.red,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: MyColors.blue,
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 72,
      centerTitle: true,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
    ),
  );
}
