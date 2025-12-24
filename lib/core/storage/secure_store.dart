import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage();

  static const _kInstallId = 'sovra.install_id';
  static const _kDeviceId = 'sovra.device_id';
  static const _kAccessToken = 'sovra.access_token';

  Future<String?> getInstallId() => _storage.read(key: _kInstallId);
  Future<void> setInstallId(String v) => _storage.write(key: _kInstallId, value: v);

  Future<String?> getDeviceId() => _storage.read(key: _kDeviceId);
  Future<void> setDeviceId(String v) => _storage.write(key: _kDeviceId, value: v);

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<void> setAccessToken(String v) => _storage.write(key: _kAccessToken, value: v);

  Future<void> clearAll() async {
    await _storage.delete(key: _kInstallId);
    await _storage.delete(key: _kDeviceId);
    await _storage.delete(key: _kAccessToken);
  }
}
