import 'dart:async';
import 'package:flutter/material.dart';
import '../services/import_service.dart';
import '../services/firestore_seed_real_data.dart';
import '../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // 🔥 SEMUA LOGIC BERAT PINDAH KE SINI
      final importService = ImportService();
      final hasData = await importService.hasExistingData();

      if (!hasData) {
        await FirestoreSeedRealData.seedRealData();
        await importService.importAllStudyCases();
      }
    } catch (e) {
      debugPrint('Init error: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [SizedBox(height: 24), CircularProgressIndicator()],
        ),
      ),
    );
  }
}
