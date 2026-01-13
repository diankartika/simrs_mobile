// lib/screens/home/admin_home.dart
// EXACT DESIGN - Matches your screenshot perfectly

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Halo Admin!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00897B),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder:
            (context, auth, _) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MENU ITEMS - EXACT DESIGN FROM YOUR IMAGE
                  _menuCard(
                    icon: Icons.person_add,
                    title: 'Pendaftaran',
                    subtitle: 'Registrasi Pasien',
                    color: const Color(0xFF00897B),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    icon: Icons.list,
                    title: 'Data Pasien',
                    subtitle: 'Data Pasien yang Terdaftar',
                    color: const Color(0xFF00897B),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    icon: Icons.medical_services,
                    title: 'Rawat Jalan (RME)',
                    subtitle: 'Data Pasien Rawat Jalan',
                    color: const Color(0xFF00897B),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    icon: Icons.hotel,
                    title: 'Rawat Inap',
                    subtitle: 'Data Pasien Rawat Inap',
                    color: const Color(0xFF00897B),
                  ),
                  const SizedBox(height: 24),

                  // FITUR LAINNYA SECTION
                  const Text(
                    'Fitur Lainnya',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _featureIcon(
                        Icons.description,
                        'Rekam Medis\nElektronik (RME)',
                      ),
                      _featureIcon(Icons.share, 'Pengkodean\nICD'),
                      _featureIcon(Icons.checklist, 'Audit Rekam\nMedis'),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey[400],
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/logo.png', width: 24, height: 24),
            label: 'Records',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Share',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }

  Widget _featureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00897B), size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
