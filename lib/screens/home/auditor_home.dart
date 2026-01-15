// lib/screens/home/auditor_home.dart - FIXED VERSION
// All errors fixed, correct widget structure, profile navigation working

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import './audit_form.dart';
import '../profile_screen.dart';
import './patient_list_universal.dart';

class AuditorHome extends StatefulWidget {
  const AuditorHome({super.key});

  @override
  State<AuditorHome> createState() => _AuditorHomeState();
}

class _AuditorHomeState extends State<AuditorHome> {
  final queueService = QueueService();
  int _currentNavIndex = 0;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
        return _buildAuditorHome();
      case 1:
        return const ProfileScreen();
      default:
        return _buildAuditorHome();
    }
  }

  // ✅ FIXED: Correct widget structure
  Widget _buildAuditorHome() {
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
              child: const Center(
                child: Icon(Icons.favorite, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      // ✅ FIXED: SingleChildScrollView wraps entire body content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ "Lihat Data Pasien" button
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
                            'Akses data pasien untuk audit',
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

            // ✅ Audit queue list
            StreamBuilder<List<QueueItem>>(
              stream: queueService.getAuditorAuditQueue(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00897B),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('Loading...'),
                        ],
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
                            'Tidak ada audit',
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COUNTER CARD
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
                          const Expanded(
                            child: Text(
                              'Dokumen Pasien\nYang Perlu di Audit',
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
                              items.length.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LIST HEADER
                    const Text(
                      'List Pasien',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // QUEUE LIST
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: FutureBuilder<Patient?>(
                            future: _getPatientData(item.patientId),
                            builder: (context, patientSnapshot) {
                              if (!patientSnapshot.hasData) {
                                return Container(
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
                                            (context) => AuditFormScreen(
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
                                              'No. RM Pasien  : ${patient.rmNumber} (${patient.gender})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF00897B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Nama Pasien  : ${patient.name}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tgl. Kunjungan: ${_formatDate(DateTime.now())} (14.00)',
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
                        );
                      },
                    ),
                  ],
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
