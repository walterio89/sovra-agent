import '../../core/network/api_client.dart';
import '../../core/storage/secure_store.dart';
import 'package:dio/dio.dart';

class HeartbeatApi {
  HeartbeatApi(this._store) : _api = ApiClient(_store);

  final SecureStore _store;
  final ApiClient _api;

  Future<Map<String, dynamic>> send({int? storageTotalBytes, int? storageFreeBytes}) async {
    final res = await _api.dio.post(
      '/api/devices/heartbeat',
      data: {
        'app_version': '0.1.0',
        'os_version': null,
        'storage_total_bytes': storageTotalBytes,
        'storage_free_bytes': storageFreeBytes,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'status': 'ok'};
  }
}
