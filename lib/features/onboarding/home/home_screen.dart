import 'package:flutter/material.dart';
import '../../../core/storage/secure_store.dart';
import '../../heartbeat/heartbeat_foreground_service.dart';
import '../../heartbeat/heartbeat_workmanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final store = SecureStore();
  late final HeartbeatForegroundService hb;

  @override
  void initState() {
    super.initState();
    hb = HeartbeatForegroundService(store);
    _start();
  }

  Future<void> _start() async {
    await hb.start();
    await HeartbeatWorkManager.register();
  }

  @override
  void dispose() {
    hb.stop();
    super.dispose();
  }

  Future<void> _reset() async {
    await store.clearAll();
    await HeartbeatWorkManager.cancel();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOVRA')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Connesso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('Heartbeat attivo (foreground 30s + background Android 15m).'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: _reset, child: const Text('Reset (debug)')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
