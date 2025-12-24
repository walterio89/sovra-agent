import 'package:flutter/material.dart';
import '../../../core/storage/secure_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SecureStore();

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
              const Text('Pairing completato. Prossimo step: Heartbeat + Status.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await store.clearAll();
                    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Reset (debug)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
