import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Moneda { eur, usd, cup }

extension MonedaExt on Moneda {
  String get simbolo {
    switch (this) {
      case Moneda.eur:
        return 'EUR';
      case Moneda.usd:
        return 'USD';
      case Moneda.cup:
        return 'CUP';
    }
  }
}

/// Todos los costos se guardan internamente en CUP. Este provider guarda
/// las tasas de cambio para poder convertir cuando el usuario carga un
/// costo en USD o EUR.
class MonedaProvider extends ChangeNotifier {
  static const _claveTasaUsd = 'tasa_usd_cup';
  static const _claveTasaEur = 'tasa_eur_cup';
  static const _claveMonedaPref = 'moneda_preferida';

  double tasaUsdCup = 0;
  double tasaEurCup = 0;
  Moneda monedaPreferida = Moneda.cup;

  MonedaProvider() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    tasaUsdCup = prefs.getDouble(_claveTasaUsd) ?? 0;
    tasaEurCup = prefs.getDouble(_claveTasaEur) ?? 0;
    final m = prefs.getString(_claveMonedaPref);
    monedaPreferida = Moneda.values.firstWhere(
      (e) => e.name == m,
      orElse: () => Moneda.cup,
    );
    notifyListeners();
  }

  Future<void> setMonedaPreferida(Moneda moneda) async {
    monedaPreferida = moneda;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveMonedaPref, moneda.name);
  }

  Future<void> setTasas({double? usdCup, double? eurCup}) async {
    final prefs = await SharedPreferences.getInstance();
    if (usdCup != null) {
      tasaUsdCup = usdCup;
      await prefs.setDouble(_claveTasaUsd, usdCup);
    }
    if (eurCup != null) {
      tasaEurCup = eurCup;
      await prefs.setDouble(_claveTasaEur, eurCup);
    }
    notifyListeners();
  }

  /// Convierte [valor] desde [moneda] a CUP usando la tasa cargada.
  double convertirACup(double valor, Moneda moneda) {
    switch (moneda) {
      case Moneda.usd:
        return valor * tasaUsdCup;
      case Moneda.eur:
        return valor * tasaEurCup;
      case Moneda.cup:
        return valor;
    }
  }
}
