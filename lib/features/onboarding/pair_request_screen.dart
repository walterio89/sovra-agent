import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_store.dart';
import 'pair_confirm_screen.dart';

class PairRequestScreen extends StatefulWidget {
  const PairRequestScreen({super.key});

  @override
  State<PairRequestScreen> createState() => _PairRequestScreenState();
}

class _PairRequestScreenState extends State<PairRequestScreen> {
  final _nameCtrl = TextEditingController(text: 'Device');
  bool _loading = false;
  String? _error;

  final _store = SecureStore();
  late final _api = ApiClient(_store);

  Future<String> _getOrCreateInstallId() async {
    final existing = await _store.getInstallId();
    if (existing != null && existing.isNotEmpty) return existing;

    final rnd = Random.secure();
    final id = List.generate(32, (_) => rnd.nextInt(16).toRadixString(16)).join();
    await _store.setInstallId(id);
    return id;
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final installId = await _getOrCreateInstallId();

      final res = await _api.dio.post(
        '/api/devices/pair/request',
        data: {
          'name': _nameCtrl.text.trim(),
          'type': 'phone',
          'platform': 'android',
          'os_version': null,
          'app_version': '0.1.0',
          'device_identifier': installId,
          'hardware_model': null,
        },
      );

      final deviceId = res.data['device_id']?.toString();
      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('device_id mancante in response');
      }

      await _store.setDeviceId(deviceId);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PairConfirmScreen()));
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
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collega dispositivo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome dispositivo',
                  hintText: 'Es. Tablet cucina',
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Richiedi abbinamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
