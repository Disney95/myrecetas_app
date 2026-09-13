import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:install_time_plugin/install_time_plugin.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Maneja la prueba gratis de la app y su activación con un código offline
/// atado al dispositivo (no es un código único reutilizable).
///
/// La fecha de instalación se toma del `firstInstallTime` nativo de Android
/// (a través de install_time_plugin), el mismo mecanismo que usa POS Pro.
/// Esto evita que borrar los datos de la app o reinstalarla reinicie la
/// cuenta de días, ya que Android conserva ese valor mientras el APK siga
/// instalado con la misma firma.
///
/// La activación funciona así: la app calcula un identificador del
/// dispositivo (el `androidId` nativo de Android) y lo muestra en pantalla.
/// Quien genera los códigos firma ESE identificador con la clave privada
/// (RSA-SHA256) y entrega el resultado como código de activación. La app
/// solo acepta el código si, al verificarlo con la clave pública, la firma
/// corresponde exactamente al identificador de ese mismo dispositivo — por
/// lo que un código copiado no sirve en otro celular. No requiere conexión
/// a internet.
class LicenciaProvider extends ChangeNotifier {
  static const int diasPrueba = 3;

  // Clave pública RSA exclusiva de esta app (no es la misma de POS Pro).
  static const String _clavePublicaPem = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz1DSIRLK+JqpSjqLKsKI
coCtS8nsNht4geL/pNvHne0g5bZZpCa1HHZZOjG4ovMXHF1gTtmu04To7acOkP6r
tTl/VAHJFdGg0QJj8AmNoYXDpkcbVlAyWZ8SFQkq80Lt7uqPC1M9x1wuOuunrUG4
tO88u9OG2pLg862o62UhDfCZTKjG4GIRbJfs37air/JeFcNRQw7JTBjPS+gfWwNc
NL+cuzbce7zxIAFQ5gqAVwkRKsx1qykHRUP2CktbaT+XkWds+qpaWJ3uDFT1yGeV
8NgDU00YLG1E1TM/YPp21MljLCaDQVt0L51ZsHP8PIdZyNzilzTq6sJ0rTXGVvZ7
HwIDAQAB
-----END PUBLIC KEY-----''';

  static const _keyCodigo = 'licencia_codigo_activacion';
  static const _keyRespaldoFecha = 'licencia_fecha_instalacion_respaldo';
  static const _keyIdentificador = 'licencia_identificador_dispositivo';

  bool _activada = false;
  int _diasRestantes = diasPrueba;
  bool _cargando = true;
  String _identificador = '';

  bool get activada => _activada;
  bool get cargando => _cargando;
  int get diasRestantes => _diasRestantes;

  /// Identificador único de este dispositivo. Se le muestra al usuario para
  /// que lo envíe y le generen su código de activación personal.
  String get identificador => _identificador;

  /// true mientras la app está bloqueada (prueba vencida y no activada).
  bool get bloqueada => !_activada && _diasRestantes <= 0;

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    _identificador = await _obtenerIdentificador(prefs);

    final codigoGuardado = prefs.getString(_keyCodigo);
    if (codigoGuardado != null && _verificarCodigo(codigoGuardado)) {
      _activada = true;
      _diasRestantes = 0;
      _cargando = false;
      notifyListeners();
      return;
    }

    final instalacion = await _fechaInstalacion(prefs);
    final transcurridos = DateTime.now().difference(instalacion).inDays;
    _diasRestantes = (diasPrueba - transcurridos).clamp(0, diasPrueba);
    _activada = false;
    _cargando = false;
    notifyListeners();
  }

  Future<String> _obtenerIdentificador(SharedPreferences prefs) async {
    final guardado = prefs.getString(_keyIdentificador);
    if (guardado != null && guardado.isNotEmpty) return guardado;

    String id = '';
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      id = info.androidId;
    } catch (_) {
      // Se resuelve abajo con el respaldo.
    }
    if (id.isEmpty) {
      // Respaldo por si el dispositivo no entrega androidId: un
      // identificador aleatorio que se guarda localmente y no cambia
      // mientras no se borren los datos de la app.
      id = _generarIdRespaldo();
    }
    await prefs.setString(_keyIdentificador, id);
    return id;
  }

  String _generarIdRespaldo() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Future<DateTime> _fechaInstalacion(SharedPreferences prefs) async {
    try {
      final ms = await InstallTimePlugin.getFirstInstallTime();
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      // Sigue con el respaldo si el plugin falla en algún dispositivo.
    }
    final guardado = prefs.getInt(_keyRespaldoFecha);
    if (guardado != null) return DateTime.fromMillisecondsSinceEpoch(guardado);
    final ahora = DateTime.now();
    await prefs.setInt(_keyRespaldoFecha, ahora.millisecondsSinceEpoch);
    return ahora;
  }

  /// Intenta activar la app con el código ingresado. Devuelve true si el
  /// código es válido para ESTE dispositivo (firma RSA correcta sobre su
  /// identificador) y queda guardado.
  Future<bool> activar(String codigoIngresado) async {
    final codigo = codigoIngresado.trim();
    if (codigo.isEmpty || !_verificarCodigo(codigo)) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCodigo, codigo);
    _activada = true;
    _diasRestantes = 0;
    notifyListeners();
    return true;
  }

  bool _verificarCodigo(String codigo) {
    if (_identificador.isEmpty) return false;
    try {
      final limpio = codigo.trim().replaceAll(RegExp(r'\s'), '');
      final firma = base64.decode(limpio);
      final clavePublica = CryptoUtils.rsaPublicKeyFromPem(_clavePublicaPem);
      return CryptoUtils.rsaVerify(
        clavePublica,
        Uint8List.fromList(utf8.encode(_identificador)),
        firma,
      );
    } catch (_) {
      return false;
    }
  }
}
