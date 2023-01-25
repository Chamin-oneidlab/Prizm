//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class Theme_Provider extends ChangeNotifier {
//   ThemeMode themeMode = ThemeMode.light;
//
//   setThemeMode(ThemeMode newThemeMode) {
//     themeMode = newThemeMode;
//     saveThemeModePrefs(themeMode.toString().replaceAll("ThemeMode.", ""));
//     notifyListeners();
//   }
//
//   saveThemeModePrefs(String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("themeMode", value);
//   }
//
//   ThemeProvider({ThemeMode initThemeMode = ThemeMode.light}) {
//     themeMode = initThemeMode;
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class MyThemeModel extends ChangeNotifier {
//   late ThemeData _themedata;
//
//   MyThemeModel(bool isActivate) {
//   }
// }