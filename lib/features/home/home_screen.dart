import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/secure_store.dart';
import '../heartbeat/heartbeat_api.dart';
import '../heartbeat/heartbeat_foreground_service.dart';
import '../heartbeat/heartbeat_workmanager.dart';
import 'home_status.dart';
import 'time_ago.dart';
import '../security/blocked_screen.dart';
import '../security/reconnect_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final store = SecureStore();

  late final HeartbeatForegroundService hb;
  late final HeartbeatApi hbApi;

  DateTime? _lastOkAt;
  String? _lastError;
  Timer? _uiTick;

  @override
  void initState() {
    super.initState();
    hb = HeartbeatForegroundService(store);
    hbApi = HeartbeatApi(store);

    _start();

    // solo per aggiornare il "time ago" senza fare chiamate
    _uiTick = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _start() async {
    await hb.start();
    await HeartbeatWorkManager.register();

    // manda un heartbeat “visibile” subito per aggiornare UI
    await _sendHeartbeatAndUpdateUi();
  }

  Future<void> _sendHeartbeatAndUpdateUi() async {
    final result = await hbApi.send();

    if (result.isOk) {
      setState(() {
        _lastError = null;
        _lastOkAt = result.lastSeenAt; // server time
      });
      return;
    }

    if (result.isBlocked) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const BlockedScreen()));
      return;
    }

    if (result.isReconnect) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReconnectScreen(reason: result.reason ?? 'Verifica richiesta'),
        ),
      );
      return;
    }

    // offline
    setState(() {
      _lastError = result.message ?? 'offline';
    });
  }

  HomeStatus _computeStatus() {
    // Priorità: blocked > offline > attention > protected
    if (_lastError != null) {
      return HomeStatus(
        state: SovraSafetyState.offline,
        subtitle: 'Connessione non disponibile',
        lastSeenLabel: timeAgo(_lastOkAt),
      );
    }

    if (_lastOkAt == null) {
      return HomeStatus(
        state: SovraSafetyState.attention,
        subtitle: 'In attesa di primo contatto',
        lastSeenLabel: 'mai',
      );
    }

    final diff = DateTime.now().difference(_lastOkAt!);
    if (diff.inMinutes >= 2) {
      return HomeStatus(
        state: SovraSafetyState.attention,
        subtitle: 'Ultimo contatto non recente',
        lastSeenLabel: timeAgo(_lastOkAt),
      );
    }

    return HomeStatus(
      state: SovraSafetyState.protected,
      subtitle: 'Tutto sotto controllo',
      lastSeenLabel: timeAgo(_lastOkAt),
    );
  }

  @override
  void dispose() {
    hb.stop();
    _uiTick?.cancel();
    super.dispose();
  }

  Future<void> _reset() async {
    await store.clearAll();
    await HeartbeatWorkManager.cancel();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final s = _computeStatus();

    String title;
    IconData icon;

    switch (s.state) {
      case SovraSafetyState.protected:
        title = 'Protetto';
        icon = Icons.verified_rounded;
        break;
      case SovraSafetyState.attention:
        title = 'Attenzione';
        icon = Icons.info_rounded;
        break;
      case SovraSafetyState.blocked:
        title = 'Bloccato';
        icon = Icons.block_rounded;
        break;
      case SovraSafetyState.offline:
        title = 'Offline';
        icon = Icons.wifi_off_rounded;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SOVRA')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusCard(
                title: title,
                subtitle: s.subtitle,
                lastSeen: s.lastSeenLabel,
                icon: icon,
                onRefresh: _sendHeartbeatAndUpdateUi,
              ),
              const SizedBox(height: 16),

              // Azione debug (poi la nascondiamo)
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.lastSeen,
    required this.icon,
    required this.onRefresh,
  });

  final String title;
  final String subtitle;
  final String lastSeen;
  final IconData icon;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Aggiorna',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text('Ultimo contatto: $lastSeen', style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
