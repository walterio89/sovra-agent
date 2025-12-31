import 'dart:async';
import '../../core/storage/secure_store.dart';
import 'heartbeat_api.dart';

class HeartbeatForegroundService {
  HeartbeatForegroundService(this._store) : _api = HeartbeatApi(_store);

  final SecureStore _store;
  final HeartbeatApi _api;

  Timer? _timer;

  Future<void> start() async {
    // evita doppio timer
    _timer?.cancel();

    // manda subito un heartbeat
    await _safeSend();

    // poi ogni 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _safeSend();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _safeSend() async {
    final token = await _store.getAccessToken();
    if (token == null || token.isEmpty) return; // non paired

    try {
      await _api.send();
      // qui potrai salvare last_seen localmente se vuoi
    } catch (_) {
      // in v0 non “disturbiamo” l’utente: fail silenzioso
      // (poi gestiamo 401/423 con uno strato più intelligente)
    }
  }
}
