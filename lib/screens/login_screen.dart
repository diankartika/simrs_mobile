// lib/screens/login_screen.dart - DEBUG VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  UserRole? _selectedRole;
  String _debugMessage = ''; // DEBUG

  @override
  void initState() {
    super.initState();
    // Set default test credentials for easier testing
    _usernameCtrl.text = 'simrs';
    _passwordCtrl.text = '123456';
    _debugMessage = 'Ready for login';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin(AuthProvider auth) async {
    print('🔐 DEBUG: _handleLogin called');
    print('🔐 DEBUG: username=${_usernameCtrl.text}');
    print('🔐 DEBUG: password=${_passwordCtrl.text}');
    print('🔐 DEBUG: role=$_selectedRole');

    setState(() => _debugMessage = '⏳ Validating...');

    // Validate role is selected
    if (_selectedRole == null) {
      print('❌ DEBUG: No role selected');
      setState(() => _debugMessage = '❌ No role selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih role/posisi terlebih dahulu'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('✅ DEBUG: Role selected, calling auth.login()');
    setState(() => _debugMessage = '📱 Logging in...');

    final success = await auth.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
      role: _selectedRole!,
    );

    print('🔐 DEBUG: Login returned success=$success');
    print('🔐 DEBUG: isLoggedIn=${auth.isLoggedIn}');
    print('🔐 DEBUG: currentUser=${auth.currentUser}');
    print('🔐 DEBUG: errorMessage=${auth.errorMessage}');

    if (success && mounted) {
      print('✅ DEBUG: Login success! Navigating to /home');
      setState(() => _debugMessage = '✅ Login successful! Redirecting...');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('❌ DEBUG: Login failed');
      setState(() => _debugMessage = '❌ Login failed: ${auth.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'SIMRS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem Informasi Manajemen Rumah Sakit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 🔍 DEBUG MESSAGE
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      'DEBUG: $_debugMessage',
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // USERNAME FIELD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Masukkan username',
                      hintStyle: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00897B),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD FIELD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      hintStyle: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF00897B),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                        color: const Color(0xFF999999),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ROLE DROPDOWN
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Role/Posisi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: DropdownButton<UserRole?>(
                      value: _selectedRole,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Pilih Role/Posisi',
                          style: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.expand_more,
                          color: Color(0xFF00897B),
                          size: 24,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: const Text(
                            'Admin',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        DropdownMenuItem(
                          value: UserRole.doctor,
                          child: const Text(
                            'Dokter',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        DropdownMenuItem(
                          value: UserRole.coder,
                          child: const Text(
                            'HIM/Coder',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        DropdownMenuItem(
                          value: UserRole.auditor,
                          child: const Text(
                            'Auditor',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                      onChanged: (role) {
                        if (role != null) {
                          setState(() => _selectedRole = role);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          (auth.isLoading || _selectedRole == null)
                              ? null
                              : () => _handleLogin(auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child:
                          auth.isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  // ERROR MESSAGE
                  if (auth.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
