import 'package:flutter/material.dart';
import 'pair_request_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text('SOVRA', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const Text(
                'Collega questo dispositivo alla tua famiglia.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const PairRequestScreen()));
                  },
                  child: const Text('Collega'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
