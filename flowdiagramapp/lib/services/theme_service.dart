import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'app_theme_mode';
  AppThemeMode _currentTheme = AppThemeMode.system;
  late SharedPreferences _prefs;

  AppThemeMode get currentTheme => _currentTheme;

  /// Inicializa el servicio de temas
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (theme) => theme.toString() == savedTheme,
        orElse: () => AppThemeMode.system,
      );
    }
    notifyListeners();
  }

  /// Cambia el tema de la aplicación
  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    await _prefs.setString(_themeKey, theme.toString());
    notifyListeners();
  }

  /// Obtiene el ThemeMode de Flutter correspondiente
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Verifica si el tema actual es oscuro
  bool isDarkMode(BuildContext context) {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// Obtiene el nombre del tema actual para mostrar en UI
  String getThemeName() {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return 'Modo Claro';
      case AppThemeMode.dark:
        return 'Modo Oscuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }

  /// Alterna entre modo claro y oscuro
  Future<void> toggleTheme() async {
    switch (_currentTheme) {
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        await setTheme(AppThemeMode.light);
        break;
    }
  }
}
