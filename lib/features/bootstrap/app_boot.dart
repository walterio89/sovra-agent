import 'package:flutter/material.dart';
import '../../core/storage/secure_store.dart';
import '../home/home_screen.dart';
import '../onboarding/pair_request_screen.dart';

class AppBoot extends StatefulWidget {
  const AppBoot({super.key});

  @override
  State<AppBoot> createState() => _AppBootState();
}

class _AppBootState extends State<AppBoot> {
  final _store = SecureStore();

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final token = await _store.getAccessToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PairRequestScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // splash minimale, “calmo”
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
