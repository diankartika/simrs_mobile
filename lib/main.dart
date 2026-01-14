// lib/main.dart
// FIXED - All errors removed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'services/icd_database_service.dart';
import 'screens/login_screen.dart';
import 'screens/home/admin_home.dart';
import 'screens/home/doctor_home.dart';
import 'screens/home/coder_home.dart';
import 'screens/home/auditor_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Sync ICD codes to Firestore on first run
  await ICDDatabaseService().syncMockDataToFirestore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'SIMRS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF00897B),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const AuthWrapper(),
          '/auth': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

// Splash Screen (3 seconds then go to login/home)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 32),
            const Text(
              'SIMRS',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sistem Informasi Manajemen Rumah Sakit',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 80),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Auth Wrapper - Routes based on login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        final user = authProvider.currentUser;
        if (user == null) return const LoginScreen();

        switch (user.role) {
          case UserRole.admin:
            return const AdminHome();
          case UserRole.doctor:
            return const DoctorHome();
          case UserRole.coder:
            return const CoderHome();
          case UserRole.auditor:
            return const AuditorHome();
        }
      },
    );
  }
}
