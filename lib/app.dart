import 'package:flutter/material.dart';
import 'features/bootstrap/app_boot.dart';

class SovraApp extends StatelessWidget {
  const SovraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOVRA Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppBoot(),
    );
  }
}
