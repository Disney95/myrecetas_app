import 'package:flutter/material.dart';

class AppColors {
  // Tema claro
  static const Color fondo = Color(0xFFFFFFFF);
  static const Color tarjeta = Color(0xFFF8F9FA);
  static const Color textoPrincipal = Color(0xFF1A1A1A);
  static const Color textoSecundario = Color(0xFF6B6B6B);
  static const Color divisor = Color(0xFFE9ECEF);

  // Tema oscuro
  static const Color fondoOscuro = Color(0xFF000000);
  static const Color tarjetaOscura = Color(0xFF1C1C1E);
  static const Color textoPrincipalOscuro = Color(0xFFF2F2F2);
  static const Color textoSecundarioOscuro = Color(0xFFA0A0A0);
  static const Color divisorOscuro = Color(0xFF2C2C2E);

  // Acentos (iguales en ambos temas)
  static const Color acentoMenta = Color(0xFF6FBF9B);
  static const Color acentoTerracota = Color(0xFFD98E73);
  static const Color acentoCrema = Color(0xFFEFE3D0);
  static const Color exito = Color(0xFF4CAF82);
}

class AppTheme {
  static ThemeData get theme => _construir(oscuro: false);
  static ThemeData get themeOscuro => _construir(oscuro: true);

  static ThemeData _construir({required bool oscuro}) {
    final fondo = oscuro ? AppColors.fondoOscuro : AppColors.fondo;
    final tarjeta = oscuro ? AppColors.tarjetaOscura : AppColors.tarjeta;
    final textoPrincipal =
        oscuro ? AppColors.textoPrincipalOscuro : AppColors.textoPrincipal;
    final textoSecundario =
        oscuro ? AppColors.textoSecundarioOscuro : AppColors.textoSecundario;
    final divisor = oscuro ? AppColors.divisorOscuro : AppColors.divisor;

    return ThemeData(
      useMaterial3: true,
      brightness: oscuro ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: fondo,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.acentoMenta,
        primary: AppColors.acentoMenta,
        surface: fondo,
        brightness: oscuro ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        foregroundColor: textoPrincipal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textoPrincipal,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: tarjeta,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: divisor, width: 1),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textoPrincipal, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textoPrincipal, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textoPrincipal),
        bodyMedium: TextStyle(color: textoSecundario),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.acentoMenta,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tarjeta,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divisor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divisor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.acentoMenta, width: 1.5),
        ),
        labelStyle: TextStyle(color: textoSecundario),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: fondo,
        selectedItemColor: AppColors.acentoMenta,
        unselectedItemColor: textoSecundario,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(color: divisor, thickness: 1),
    );
  }
}
