import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_screen.dart';

class SovraApp extends StatelessWidget {
  const SovraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOVRA Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      home: const OnboardingScreen(),
    );
  }
}
