// lib/screens/home/admin_home.dart - COMPLETE ADMIN DASHBOARD (5 TABS)
// Tabs: Home, RME, Pengkodean ICD, Audit, Profile

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/queue_service.dart';
import '../../models/patient_models.dart';
import 'registrasi_pasien.dart';
import '../profile_screen.dart';
import 'admin_rme_home.dart';
import 'admin_coding_home.dart';
import 'admin_audit_home.dart';
import 'admin_patient_list.dart';
import 'admin_inpatient_list.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final queueService = QueueService();
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
          leading: SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
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
          ],
        ),
        // ✅ FIX: Handle 5 tabs properly
        body: _buildBody(),
        // ✅ FIX: 5 tabs (Home, RME, Coding, Audit, Profile)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00897B),
          unselectedItemColor: Colors.grey[400],
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'RME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Pengkodean',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Audit',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // ✅ FIX: Handle all 5 tabs
  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildAdminHome();
      case 1:
        return const AdminRMEHome();
      case 2:
        return const AdminCodingHome();
      case 3:
        return const AdminAuditHome();
      case 4:
        return const ProfileScreen();
      default:
        return _buildAdminHome();
    }
  }

  // Tab 0: HOME - Menu Dashboard
  Widget _buildAdminHome() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MENU CARDS - MAIN FUNCTIONS
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrasiPasien(),
                      ),
                    ),
                child: _menuCard(
                  icon: Icons.person_add,
                  title: 'Pendaftaran',
                  subtitle: 'Registrasi Pasien',
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPatientList(),
                      ),
                    ),
                child: _menuCard(
                  icon: Icons.list,
                  title: 'Data Pasien',
                  subtitle: 'Data Pasien yang Terdaftar',
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() => _currentNavIndex = 1);
                },
                child: _menuCard(
                  icon: Icons.medical_services,
                  title: 'Rawat Jalan (RME)',
                  subtitle: 'Data Pasien Rawat Jalan',
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminInpatientList(),
                      ),
                    ),
                child: _menuCard(
                  icon: Icons.hotel,
                  title: 'Rawat Inap',
                  subtitle: 'Data Pasien Rawat Inap',
                  color: const Color(0xFF00897B),
                ),
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
                    () {
                      setState(() => _currentNavIndex = 1);
                    },
                  ),
                  _featureIcon(Icons.assignment, 'Pengkodean\nICD', () {
                    setState(() => _currentNavIndex = 2);
                  }),
                  _featureIcon(Icons.checklist, 'Audit Rekam\nMedis', () {
                    setState(() => _currentNavIndex = 3);
                  }),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _featureIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00897B), size: 32),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
