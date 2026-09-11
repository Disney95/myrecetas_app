import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaProvider extends ChangeNotifier {
  static const _clave = 'tema_modo';
  ThemeMode _modo = ThemeMode.system;
  ThemeMode get modo => _modo;

  TemaProvider() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString(_clave);
    switch (valor) {
      case 'claro':
        _modo = ThemeMode.light;
        break;
      case 'oscuro':
        _modo = ThemeMode.dark;
        break;
      default:
        _modo = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setModo(ThemeMode modo) async {
    _modo = modo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final valor = modo == ThemeMode.light
        ? 'claro'
        : modo == ThemeMode.dark
            ? 'oscuro'
            : 'sistema';
    await prefs.setString(_clave, valor);
  }
}
