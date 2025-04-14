import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');
    if (theme == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode.value = ThemeMode.light;
    } else {
      _themeMode.value = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode.value == ThemeMode.dark) {
      _themeMode.value = ThemeMode.light;
      await prefs.setString('theme', 'light');
    } else {
      _themeMode.value = ThemeMode.dark;
      await prefs.setString('theme', 'dark');
    }
  }
}