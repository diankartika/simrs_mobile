// lib/screens/admin/admin_patient_list.dart
// List all patients by service type

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';

class AdminPatientList extends StatefulWidget {
  final String serviceType; // 'all', 'Rawat Jalan', 'Rawat Inap'

  const AdminPatientList({super.key, required this.serviceType});

  @override
  State<AdminPatientList> createState() => _AdminPatientListState();
}

class _AdminPatientListState extends State<AdminPatientList> {
  late Stream<List<Patient>> _patientStream;

  @override
  void initState() {
    super.initState();
    _patientStream = _getPatientsStream();
  }

  Stream<List<Patient>> _getPatientsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('patients')
        .where('status', isEqualTo: 'active');

    // Filter by service type if not 'all'
    if (widget.serviceType != 'all') {
      query = query.where('serviceType', isEqualTo: widget.serviceType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
    });
  }

  String _getTitle() {
    switch (widget.serviceType) {
      case 'Rawat Jalan':
        return 'Rawat Jalan (RME)';
      case 'Rawat Inap':
        return 'Rawat Inap';
      default:
        return 'Data Pasien';
    }
  }

  String _getSubtitle() {
    switch (widget.serviceType) {
      case 'Rawat Jalan':
        return 'Data Pasien Rawat Jalan';
      case 'Rawat Inap':
        return 'Data Pasien Rawat Inap';
      default:
        return 'Data Pasien yang Terdaftar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Patient>>(
        stream: _patientStream,
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
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada pasien ditemukan',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          final patients = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                      Text(
                        _getSubtitle(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          patients.length.toString(),
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
                  'Daftar Pasien',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // PATIENT LIST
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Show patient details
                          _showPatientDetails(context, patient);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No. RM : ${patient.rmNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00897B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Nama : ${patient.name}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Usia : ${patient.age} Tahun',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPatientDetails(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Detail Pasien'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('No. RM', patient.rmNumber),
                  _buildDetailRow('Nama', patient.name),
                  _buildDetailRow('NIK', patient.nik),
                  _buildDetailRow('Usia', '${patient.age} Tahun'),
                  _buildDetailRow('Jenis Kelamin', patient.gender),
                  _buildDetailRow('Alamat', patient.address),
                  _buildDetailRow('No. HP', patient.phone),
                  _buildDetailRow('Asuransi', patient.insurance),
                  _buildDetailRow('Jenis Pelayanan', patient.serviceType),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
