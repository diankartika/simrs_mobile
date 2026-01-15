// lib/screens/home/coder_home.dart - FINAL VERSION
// All errors fixed, UI matches screenshots with role-based design

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import './pengkodean_form.dart';
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
        child: StreamBuilder<List<QueueItem>>(
          stream: queueService.getCoderCodingQueue(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = snapshot.data!;
            final codingCount = items.length;
            final reviewCount = 4; // Example count

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP CARDS - Menunggu Pengkodean & Perlu Review
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00897B),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00897B,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.healing,
                                    size: 20,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Menunggu\nPengkodean',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00897B),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00897B,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    codingCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00897B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Perlu Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF00897B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // CODING ICD SECTION
                const Text(
                  'Koding ICD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // QUEUE LIST
                for (var item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FutureBuilder<Patient?>(
                      future: _getPatientData(item.patientId),
                      builder: (context, patientSnapshot) {
                        if (!patientSnapshot.hasData) {
                          return Container(
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
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00897B),
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
                            if (mounted) {
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No. RM Pasien  : ${item.rmNumber} (Laki-laki)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nama Pasien  : ${item.patientName}',
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
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF00897B),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // LIHAT SEMUA BUTTON
                Center(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      label: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // STATISTICS SECTION
                const Text(
                  'Statistik',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00897B),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top 5 Kode ICD-10 Hari Ini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatItem(
                        '1. I10 - Hipertensi Essensial',
                        '5 Kasus',
                      ),
                      _buildStatItem(
                        '2. TB14 - Infeksi Luka Operasi',
                        '2 Kasus',
                      ),
                      _buildStatItem(
                        '3. K35.8 - Appendisitis Akut Non-Spesifik',
                        '1 Kasus',
                      ),
                      _buildStatItem(
                        '4. J06.9 - Infeksi Saluran Napas Akut',
                        '1 Kasus',
                      ),
                      _buildStatItem(
                        '5. N39.0 - Infeksi Saluran Kemih',
                        '1 Kasus',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // LIHAT SEMUA BUTTON
                Center(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      label: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Row(
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00897B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF00897B),
              ),
            ],
          ),
        ],
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
