import 'package:flutter/material.dart';
import 'splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMRS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F766E),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
