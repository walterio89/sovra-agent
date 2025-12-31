import 'package:flutter/material.dart';
import '../../core/storage/secure_store.dart';
import '../onboarding/onboarding_screen.dart';

class ReconnectScreen extends StatelessWidget {
  const ReconnectScreen({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final store = SecureStore();

    Future<void> resetAndRestart() async {
      await store.clearAll();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (_) => false,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verifica')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Riconnessione richiesta',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(reason, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(onPressed: resetAndRestart, child: const Text('Riconnetti')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
