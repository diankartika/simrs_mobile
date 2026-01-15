// lib/screens/home/doctor_home.dart - WITH PATIENT COUNTER
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/queue_service.dart';
import '../../models/patient_models.dart';
import '../profile_screen.dart';
import 'rme_form.dart';
import 'rme_history.dart';
import './patient_list_universal.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  final queueService = QueueService();
  int _currentNavIndex = 0;

  Future<Patient?> _getPatientData(String patientId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();
      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
    } catch (e) {
      // Silent
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        // ✅ ONLY show "Halo Dokter!" on home tab
        appBar:
            _currentNavIndex == 0
                ? AppBar(
                  title: const Text(
                    'Halo Dokter!',
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
                )
                : null,
        body: _buildBody(),
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
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'RME'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // ✅ Handle all 3 tabs
  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildRMEQueue();
      case 1:
        return const RMEHistory(role: 'doctor');
      case 2:
        return const ProfileScreen();
      default:
        return _buildRMEQueue();
    }
  }

  // Tab 0: RME QUEUE - Show patients waiting for RME
  Widget _buildRMEQueue() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TITLE WITH PATIENT COUNT BADGE
          StreamBuilder<List<QueueItem>>(
            stream: queueService.getDoctorRMEQueue(),
            builder: (context, snapshot) {
              final queueCount = snapshot.hasData ? snapshot.data!.length : 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Antrian RME',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$queueCount pasien',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Akses Cepat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientListUniversal(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.people,
                      size: 20,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lihat Data Pasien',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Akses data semua pasien terdaftar',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF00897B)),
                ],
              ),
            ),
          ),

          StreamBuilder<List<QueueItem>>(
            stream: queueService.getDoctorRMEQueue(),
            builder: (context, snapshot) {
              // 🔴 PENTING: tampilkan error Firestore kalau ada
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Firestore error:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00897B),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pasien yang menunggu RME',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final queueItems = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queueItems.length,
                itemBuilder: (context, index) {
                  final queueItem = queueItems[index];

                  return FutureBuilder<Patient?>(
                    future: _getPatientData(queueItem.patientId),
                    builder: (context, patientSnapshot) {
                      if (!patientSnapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF00897B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00897B),
                              ),
                            ),
                          ),
                        );
                      }

                      final patient = patientSnapshot.data;
                      if (patient == null) {
                        return const SizedBox();
                      }

                      return GestureDetector(
                        onTap: () {
                          // ✅ Navigate to RMEForm WITH patient data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RMEForm(
                                    queueItem: queueItem,
                                    patient: patient,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFF00897B),
                                  width: 4,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(
                                0xFF00897B,
                              ).withValues(alpha: 0.05),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No. RM: ${patient.rmNumber}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nama: ${patient.name}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Umur: ${patient.age} tahun | ${patient.gender}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF00897B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
