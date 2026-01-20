import 'package:flutter/material.dart';

class AppThemes {
  /// Tema claro de la aplicación
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Esquema de colores principal
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB), // Azul principal
      onPrimary: Colors.white,
      secondary: Color(0xFF059669), // Verde secundario
      onSecondary: Colors.white,
      tertiary: Color(0xFF7C3AED), // Púrpura para admin
      onTertiary: Colors.white,
      error: Color(0xFFDC2626), // Rojo para errores
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1F2937),
      surfaceContainerHighest: Color(0xFFF9FAFB),
      outline: Color(0xFFE5E7EB),
      outlineVariant: Color(0xFFF3F4F6),
    ),

    // AppBar personalizada
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards y contenedores
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: const Color(0xFF2563EB).withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),

    // Drawer y navegación
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Switch y Checkbox
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2563EB);
        }
        return const Color(0xFF9CA3AF);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2563EB).withOpacity(0.5);
        }
        return const Color(0xFFE5E7EB);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(Colors.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2563EB);
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
    ),

    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  );

  /// Tema oscuro de la aplicación
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Esquema de colores principal para modo oscuro
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6), // Azul más claro para modo oscuro
      onPrimary: Color(0xFF1E293B),
      secondary: Color(0xFF10B981), // Verde más claro
      onSecondary: Color(0xFF1E293B),
      tertiary: Color(0xFF8B5CF6), // Púrpura más claro para admin
      onTertiary: Color(0xFF1E293B),
      error: Color(0xFFEF4444), // Rojo más claro
      onError: Color(0xFF1E293B),
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFF334155),
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF64748B),
    ),

    // AppBar para modo oscuro
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF1F5F9),
      ),
      iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
    ),

    // Cards para modo oscuro
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E293B),
      surfaceTintColor: const Color(0xFF3B82F6).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Botones elevados para modo oscuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Botones de texto para modo oscuro
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Campos de texto para modo oscuro
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF475569)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
    ),

    // Drawer para modo oscuro
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E293B),
      elevation: 8,
    ),

    // Floating Action Button para modo oscuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3B82F6),
      foregroundColor: Color(0xFF1E293B),
      elevation: 8,
    ),

    // Switch y Checkbox para modo oscuro
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3B82F6);
        }
        return const Color(0xFF64748B);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3B82F6).withOpacity(0.5);
        }
        return const Color(0xFF475569);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3B82F6);
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: Color(0xFF475569), width: 2),
    ),

    // Dividers para modo oscuro
    dividerTheme: const DividerThemeData(
      color: Color(0xFF475569),
      thickness: 1,
    ),

    // Scaffold para modo oscuro
    scaffoldBackgroundColor: const Color(0xFF0F172A),
  );

  /// Colores personalizados para nodos del diagrama en modo claro
  /// Includes ISO 5807 symbols
  static const Map<String, Color> lightNodeColors = {
    // Basic symbols (with code generation)
    'terminal': Color(0xFF10B981), // Verde para terminal (inicio/fin)
    'process': Color(0xFF3B82F6), // Azul para proceso
    'decision': Color(0xFFF59E0B), // Amarillo para decisión
    'data': Color(0xFF7C3AED), // Púrpura para datos (entrada/salida)
    'preparation': Color(0xFFEF4444), // Rojo/naranja para preparación
    'predefinedProcess': Color(0xFF8B5CF6), // Morado para subproceso/función
    // Aliases for backwards compatibility
    'loop': Color(0xFFEF4444),
    'subprocess': Color(0xFF8B5CF6),
    // ISO 5807 Data symbols
    'storedData': Color(0xFF06B6D4), // Cian
    'internalStorage': Color(0xFF0891B2), // Cian oscuro
    'sequentialStorage': Color(0xFF0EA5E9), // Azul cielo
    'directStorage': Color(0xFF2563EB), // Azul profundo (database)
    'document': Color(0xFF4F46E5), // Índigo
    'manualInput': Color(0xFF7C3AED), // Púrpura
    'card': Color(0xFF6366F1), // Índigo claro
    'punchedTape': Color(0xFF8B5CF6), // Violeta
    'display': Color(0xFFA855F7), // Púrpura claro
    // ISO 5807 Process symbols
    'manualOperation': Color(0xFF22C55E), // Verde
    'parallelMode': Color(0xFF84CC16), // Lima
    'loopLimit': Color(0xFFF97316), // Naranja
    'collate': Color(0xFF14B8A6), // Teal
    'summingJunction': Color(0xFF0D9488), // Teal oscuro
    // ISO 5807 Special symbols
    'connector': Color(0xFFFBBF24), // Ámbar
    'offPageConnector': Color(0xFFF59E0B), // Ámbar oscuro
    'annotation': Color(0xFF9CA3AF), // Gris
    'comment': Color(0xFF6B7280), // Gris oscuro
  };

  /// Colores personalizados para nodos del diagrama en modo oscuro
  /// Includes ISO 5807 symbols
  static const Map<String, Color> darkNodeColors = {
    // Basic symbols (with code generation)
    'terminal': Color(0xFF34D399), // Verde más claro para terminal
    'process': Color(0xFF60A5FA), // Azul más claro
    'decision': Color(0xFFFBBF24), // Amarillo más claro
    'data': Color(0xFF8B5CF6), // Púrpura más claro para datos (entrada/salida)
    'preparation': Color(0xFFF97316), // Naranja más claro para preparación
    'predefinedProcess':
        Color(0xFFA78BFA), // Morado claro para subproceso/función
    // Aliases for backwards compatibility
    'loop': Color(0xFFF97316),
    'subprocess': Color(0xFFA78BFA),
    // ISO 5807 Data symbols
    'storedData': Color(0xFF22D3EE), // Cian claro
    'internalStorage': Color(0xFF06B6D4), // Cian
    'sequentialStorage': Color(0xFF38BDF8), // Azul cielo claro
    'directStorage': Color(0xFF3B82F6), // Azul
    'document': Color(0xFF6366F1), // Índigo
    'manualInput': Color(0xFF8B5CF6), // Púrpura
    'card': Color(0xFF818CF8), // Índigo claro
    'punchedTape': Color(0xFFA78BFA), // Violeta claro
    'display': Color(0xFFC084FC), // Púrpura claro
    // ISO 5807 Process symbols
    'manualOperation': Color(0xFF4ADE80), // Verde claro
    'parallelMode': Color(0xFFA3E635), // Lima claro
    'loopLimit': Color(0xFFFB923C), // Naranja claro
    'collate': Color(0xFF2DD4BF), // Teal claro
    'summingJunction': Color(0xFF14B8A6), // Teal
    // ISO 5807 Special symbols
    'connector': Color(0xFFFCD34D), // Ámbar claro
    'offPageConnector': Color(0xFFFBBF24), // Ámbar
    'annotation': Color(0xFFD1D5DB), // Gris claro
    'comment': Color(0xFF9CA3AF), // Gris
  };

  /// Obtiene los colores de nodos según el tema actual
  static Map<String, Color> getNodeColors(bool isDark) {
    return isDark ? darkNodeColors : lightNodeColors;
  }

  /// Colores para métricas y gráficos
  static const List<Color> lightChartColors = [
    Color(0xFF3B82F6), // Azul
    Color(0xFF10B981), // Verde
    Color(0xFFF59E0B), // Amarillo
    Color(0xFF7C3AED), // Púrpura
    Color(0xFFEF4444), // Rojo
    Color(0xFF059669), // Verde oscuro
    Color(0xFF0891B2), // Cian
  ];

  static const List<Color> darkChartColors = [
    Color(0xFF60A5FA), // Azul claro
    Color(0xFF34D399), // Verde claro
    Color(0xFFFBBF24), // Amarillo claro
    Color(0xFF8B5CF6), // Púrpura claro
    Color(0xFFEF4444), // Rojo
    Color(0xFF10B981), // Verde
    Color(0xFF06B6D4), // Cian claro
  ];

  /// Obtiene los colores para gráficos según el tema
  static List<Color> getChartColors(bool isDark) {
    return isDark ? darkChartColors : lightChartColors;
  }
}
