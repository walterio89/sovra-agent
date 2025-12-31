import 'package:workmanager/workmanager.dart';
import '../../core/storage/secure_store.dart';
import 'heartbeat_api.dart';

const String sovraHeartbeatTask = 'sovra_heartbeat_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != sovraHeartbeatTask) return Future.value(true);

    final store = SecureStore();
    final token = await store.getAccessToken();

    // se non c’è token, non inviare
    if (token == null || token.isEmpty) return Future.value(true);

    try {
      final api = HeartbeatApi(store);
      await api.send();
      return Future.value(true);
    } catch (_) {
      // best-effort: non falliamo il task (evita backoff aggressivo)
      return Future.value(true);
    }
  });
}

class HeartbeatWorkManager {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // in dev: utile
    );
  }

  static Future<void> register() async {
    // periodic task: Android impone min ~15 minuti
    await Workmanager().registerPeriodicTask(
      'sovra_heartbeat_periodic',
      sovraHeartbeatTask,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName('sovra_heartbeat_periodic');
  }
}
