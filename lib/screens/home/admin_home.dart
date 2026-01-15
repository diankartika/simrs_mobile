// lib/screens/home/admin_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/queue_service.dart';
import '../../models/patient_models.dart';
import 'registrasi_pasien.dart';
import '../profile_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final queueService = QueueService();
  late Future<Map<String, int>> _queueStats;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _queueStats = queueService.getQueueStats();
  }

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

        body:
            _currentNavIndex == 0
                ? _buildAdminHome(context)
                : const ProfileScreen(),

        // BOTTOM NAVIGATION - NOW WITH WORKING onTap
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
              icon: Icon(Icons.description),
              label: 'Records',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHome(BuildContext context) {
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
              _menuCard(
                icon: Icons.list,
                title: 'Data Pasien',
                subtitle: 'Data Pasien yang Terdaftar',
                color: const Color(0xFF00897B),
                onTap: () {
                  // Navigate to patient data list
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRMEHome(),
                      ),
                    ),
                child: _menuCard(
                  icon: Icons.medical_services,
                  title: 'Rawat Jalan (RME)',
                  subtitle: 'Data Pasien Rawat Jalan',
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 12),
              _menuCard(
                icon: Icons.hotel,
                title: 'Rawat Inap',
                subtitle: 'Data Pasien Rawat Inap',
                color: const Color(0xFF00897B),
                onTap: () {
                  // Navigate to inpatient data
                },
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRMEHome(),
                        ),
                      );
                    },
                  ),
                  _featureIcon(Icons.assignment, 'Pengkodean\nICD', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminCodingHome(),
                      ),
                    );
                  }),
                  _featureIcon(Icons.checklist, 'Audit Rekam\nMedis', () {
                    // Navigate to audit
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

// PLACEHOLDER CLASSES - REPLACE WITH YOUR ACTUAL IMPLEMENTATIONS
class AdminRMEHome extends StatelessWidget {
  const AdminRMEHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rawat Jalan (RME)')),
      body: const Center(child: Text('RME Home')),
    );
  }
}

class AdminCodingHome extends StatelessWidget {
  const AdminCodingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengkodean ICD')),
      body: const Center(child: Text('Coding Home')),
    );
  }
}
