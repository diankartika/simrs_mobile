import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home/admin_home.dart';
import 'screens/home/doctor_home.dart';
import 'screens/home/coder_home.dart';
import 'screens/home/auditor_home.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIMRS',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: false),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const _RoleBasedHomeRouter(),
        '/admin': (context) => const AdminHome(),
        '/doctor': (context) => const DoctorHome(),
        '/coder': (context) => const CoderHome(),
        '/auditor': (context) => const AuditorHome(),
      },
      onGenerateRoute: (settings) {
        print('🛣️ Route requested: ${settings.name}');
        return null;
      },
      onUnknownRoute: (settings) {
        print('❌ Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(child: Text('Unknown route: ${settings.name}')),
              ),
        );
      },
    );
  }
}

/// Separate widget to handle role-based routing
class _RoleBasedHomeRouter extends StatelessWidget {
  const _RoleBasedHomeRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        print('🔍 _RoleBasedHomeRouter: isLoggedIn=${auth.isLoggedIn}');
        print('🔍 _RoleBasedHomeRouter: currentUser=${auth.currentUser}');

        if (!auth.isLoggedIn || auth.currentUser == null) {
          print('❌ Not logged in, routing to /login');
          // Not logged in, go to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = auth.currentUser!.role;
        print('✅ User logged in with role: $role');

        // Route based on role
        switch (role) {
          case UserRole.admin:
            print('→ Routing to AdminHome');
            return const AdminHome();
          case UserRole.doctor:
            print('→ Routing to DoctorHome');
            return const DoctorHome();
          case UserRole.coder:
            print('→ Routing to CoderHome');
            return const CoderHome();
          case UserRole.auditor:
            print('→ Routing to AuditorHome');
            return const AuditorHome();
        }
      },
    );
  }
}
