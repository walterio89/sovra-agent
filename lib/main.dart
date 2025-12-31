import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/heartbeat/heartbeat_workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HeartbeatWorkManager.init();
  runApp(const ProviderScope(child: SovraApp()));
}
