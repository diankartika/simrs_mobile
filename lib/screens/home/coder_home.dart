// lib/screens/home/coder_home.dart - FIXED VERSION
// Now shows patient data + coding queue

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import './pengkodean_form.dart';
import './patient_list_universal.dart';
import '../profile_screen.dart';

class CoderHome extends StatefulWidget {
  const CoderHome({super.key});

  @override
  State<CoderHome> createState() => _CoderHomeState();
}

class _CoderHomeState extends State<CoderHome> {
  final queueService = QueueService();
  int _currentNavIndex = 0;

  String _formatDate(DateTime date) {
    return '${date.day} Nov ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildCoderHome();
      case 1:
        return const ProfileScreen();
      default:
        return _buildCoderHome();
    }
  }

  Widget _buildCoderHome() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Halo HIM/Coder!',
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
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00897B),
              ),
              child: const Center(
                child: Icon(Icons.favorite, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // âœ… ADD: QUICK ACCESS TO PATIENT DATA
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
                            'Akses data semua pasien untuk pengkodean',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF00897B)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PENGKODEAN QUEUE
            const Text(
              'Antrian Pengkodean',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // QUEUE COUNTER
            StreamBuilder<List<QueueItem>>(
              stream: queueService.getCoderCodingQueue(),
              builder: (context, snapshot) {
                final codingCount =
                    snapshot.hasData ? snapshot.data!.length : 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00897B),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Dokumen yang\nPerlu Dikodekan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          codingCount.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // QUEUE LIST
            StreamBuilder<List<QueueItem>>(
              stream: queueService.getCoderCodingQueue(),
              builder: (context, snapshot) {
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada pengkodean',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          _getPatientData(item.patientId).then((patient) {
                            if (patient != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PengkodeanForm(
                                        queueItem: item,
                                        patient: patient,
                                      ),
                                ),
                              );
                            }
                          });
                        },
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No. RM: ${item.rmNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nama: ${item.patientName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tgl. Kunjungan: ${_formatDate(DateTime.now())} (1 hari lalu)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
      // Silent fail
    }
    return null;
  }
}
