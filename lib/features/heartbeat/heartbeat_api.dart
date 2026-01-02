import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_store.dart';
import 'heartbeat_result.dart';
import '../metrics/device_metrics.dart';

class HeartbeatApi {
  HeartbeatApi(this._store) : _api = ApiClient(_store);

  final SecureStore _store;
  final ApiClient _api;

  Future<HeartbeatResult> send({int? storageTotalBytes, int? storageFreeBytes}) async {
    try {
      final payload = await DeviceMetrics.collectHeartbeat();
      final res = await _api.dio.post('/api/devices/heartbeat', data: payload);

      final data = res.data;
      if (data is Map) {
        final status = (data['status'] ?? '').toString();
        if (status != 'ok') return HeartbeatResult.offline(message: 'Risposta non valida');

        final deviceId = int.tryParse(data['device_id']?.toString() ?? '');
        final lastSeenRaw = data['last_seen_at']?.toString();

        final lastSeen = lastSeenRaw != null ? DateTime.tryParse(lastSeenRaw) : null;
        if (lastSeen == null) return HeartbeatResult.offline(message: 'last_seen_at mancante');

        return HeartbeatResult.ok(deviceId: deviceId ?? 0, lastSeenAt: lastSeen);
      }

      return HeartbeatResult.offline(message: 'Risposta non valida');
    } on DioException catch (e) {
      final code = e.response?.statusCode;

      if (code == 401) {
        return HeartbeatResult.reconnect(reason: 'Sessione scaduta o non valida');
      }
      if (code == 409) {
        return HeartbeatResult.reconnect(reason: 'Sessione sostituita per sicurezza');
      }
      if (code == 423) {
        return HeartbeatResult.blocked();
      }

      return HeartbeatResult.offline(message: 'Connessione non disponibile');
    } catch (_) {
      return HeartbeatResult.offline(message: 'Connessione non disponibile');
    }
  }
}
