class Env {
  /// Cambiala in base al tuo server:
  /// - Android emulator: http://192.168.178.93:8000
  /// - iOS simulator: http://localhost:8000
  /// - device fisico: http://IP_LAN_DEL_SERVER:8000
  static const String baseUrl = String.fromEnvironment(
    'SOVRA_BASE_URL',
    defaultValue: 'http://192.168.178.93:8000',
  );
}
