// lib/screens/home/coder_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import './pengkodean_form.dart';

class CoderHome extends StatefulWidget {
  const CoderHome({super.key});

  @override
  State<CoderHome> createState() => _CoderHomeState();
}

class _CoderHomeState extends State<CoderHome> {
  final queueService = QueueService();
  late Stream<List<QueueItem>> _codingQueueStream;

  @override
  void initState() {
    super.initState();
    _codingQueueStream = queueService.getCoderCodingQueue();
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

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.assignment,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATISTICS CARDS
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00897B),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menunggu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<List<QueueItem>>(
                              stream: _codingQueueStream,
                              builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                return Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00897B),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perlu Review',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '4',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // PASIEN MENUNGGU PENGKODEAN
                const Text(
                  'Pasien Menunggu Pengkodean ICD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<QueueItem>>(
                  stream: _codingQueueStream,
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
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada pasien menunggu',
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
                            if (patientSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF00897B),
                                      width: 2,
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
                                ),
                              );
                            }

                            if (!patientSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final patient = patientSnapshot.data!;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PengkodeanForm(
                                          queueItem: queueItem,
                                          patient: patient,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF00897B),
                                      width: 2,
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
                                              'Status: Pending Coding',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
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
                const SizedBox(height: 24),

                // PENGKODEAN ICD SECTION
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pengkodean ICD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey[400],
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
    );
  }
}
