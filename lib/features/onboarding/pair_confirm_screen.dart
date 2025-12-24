import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_store.dart';
import 'home/home_screen.dart';

class PairConfirmScreen extends StatefulWidget {
  const PairConfirmScreen({super.key});

  @override
  State<PairConfirmScreen> createState() => _PairConfirmScreenState();
}

class _PairConfirmScreenState extends State<PairConfirmScreen> {
  final _tokenCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  final _store = SecureStore();
  late final _api = ApiClient(_store);

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final deviceId = await _store.getDeviceId();
      if (deviceId == null) throw Exception('device_id non presente (pair request non eseguita?)');

      final res = await _api.dio.post(
        '/api/devices/pair/confirm',
        data: {
          'device_id': int.parse(deviceId),
          'pairing_token': _tokenCtrl.text.trim(),
          'device_name': null,
        },
      );

      print('CONFIRM RESPONSE: ${res.data}');

      final data = res.data;

      final token = (data is Map)
          ? (data['access_token']?.toString() ??
                data['plainTextToken']?.toString() ??
                data['token']?.toString())
          : null;

      if (token == null || token.isEmpty) {
        throw Exception('Token mancante in response: $data');
      }

      await _store.setAccessToken(token);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } catch (e) {
      String msg = e.toString();

      // Se è un errore Dio, prova a mostrare i dettagli JSON di Laravel
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['errors'] is Map) {
          final errors = (data['errors'] as Map).entries
              .map((kv) => '${kv.key}: ${(kv.value as List).join(", ")}')
              .join('\n');
          setState(() => _error = errors);
          return;
        }
        setState(() => _error = data?.toString() ?? e.toString());
        return;
      }
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conferma abbinamento')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inserisci il token/codice mostrato su SOVRA OS.'),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pairing token',
                  hintText: 'UUID o codice',
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _loading ? null : _confirm,
                  child: _loading ? const CircularProgressIndicator() : const Text('Conferma'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
