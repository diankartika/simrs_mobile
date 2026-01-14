// lib/screens/home/auditor_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import './audit_form.dart';

class AuditorHome extends StatefulWidget {
  const AuditorHome({super.key}); // No const for body rebuild

  @override
  State<AuditorHome> createState() => _AuditorHomeState();
}

class _AuditorHomeState extends State<AuditorHome> {
  final queueService = QueueService();
  late Stream<List<QueueItem>> _auditQueueStream;

  @override
  void initState() {
    super.initState();
    _auditQueueStream = queueService.getAuditorAuditQueue();
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
          'Halo Auditor!',
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
                Icons.verified_user,
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
                // DOKUMEN YANG PERLU DIAUDIT
                Container(
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
                      const Text(
                        'Dokumen Pasien',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      const Text(
                        'Yang Perlu di Audit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      StreamBuilder<List<QueueItem>>(
                        stream: _auditQueueStream,
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // LIST PASIEN MENUNGGU AUDIT
                const Text(
                  'Daftar Pasien Menunggu Audit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<QueueItem>>(
                  stream: _auditQueueStream,
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
                                        (context) => AuditFormScreen(
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
                                              'Tgl. Kunjungan: ${_formatDate(DateTime.now())}',
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
