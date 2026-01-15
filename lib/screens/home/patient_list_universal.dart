// ============================================================
// FILE 1: lib/screens/home/patient_list_universal.dart
// ============================================================
// Copy this entire file into your project

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';

class PatientListUniversal extends StatefulWidget {
  final VoidCallback? onPatientSelected;

  const PatientListUniversal({super.key, this.onPatientSelected});

  @override
  State<PatientListUniversal> createState() => _PatientListUniversalState();
}

class _PatientListUniversalState extends State<PatientListUniversal> {
  final _searchCtrl = TextEditingController();
  String _filterType = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Data Pasien',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama pasien atau RM',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00897B)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: _filterType == 'All',
                  onSelected: (selected) {
                    setState(() => _filterType = 'All');
                  },
                  selectedColor: const Color(0xFF00897B),
                  labelStyle: TextStyle(
                    color: _filterType == 'All' ? Colors.white : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('Rajal'),
                  selected: _filterType == 'outpatient',
                  onSelected: (selected) {
                    setState(() => _filterType = 'outpatient');
                  },
                  selectedColor: const Color(0xFF00897B),
                  labelStyle: TextStyle(
                    color:
                        _filterType == 'outpatient'
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('Ranap'),
                  selected: _filterType == 'inpatient',
                  onSelected: (selected) {
                    setState(() => _filterType = 'inpatient');
                  },
                  selectedColor: const Color(0xFF00897B),
                  labelStyle: TextStyle(
                    color:
                        _filterType == 'inpatient'
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                FilterChip(
                  label: const Text('IGD'),
                  selected: _filterType == 'emergency',
                  onSelected: (selected) {
                    setState(() => _filterType = 'emergency');
                  },
                  selectedColor: const Color(0xFF00897B),
                  labelStyle: TextStyle(
                    color:
                        _filterType == 'emergency'
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('patients')
                      .orderBy('registrationDate', descending: true)
                      .snapshots(),
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada data pasien',
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

                final patientDocs = snapshot.data!.docs;
                final searchQuery = _searchCtrl.text.toLowerCase();

                final filteredDocs =
                    patientDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] as String? ?? '').toLowerCase();
                      final rmNumber =
                          (data['rmNumber'] as String? ?? '').toLowerCase();

                      bool matchesSearch =
                          name.contains(searchQuery) ||
                          rmNumber.contains(searchQuery);

                      if (_filterType == 'All') {
                        return matchesSearch;
                      } else {
                        final admissionType =
                            data['admissionType'] as String? ?? 'outpatient';
                        return matchesSearch && admissionType == _filterType;
                      }
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Tidak ada hasil pencarian',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final patient = Patient.fromFirestore(doc);
                    final data = doc.data() as Map<String, dynamic>;
                    final admissionType =
                        data['admissionType'] as String? ?? 'N/A';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          widget.onPatientSelected?.call();
                          Navigator.pop(context, patient);
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${patient.gender} | ${patient.age} tahun',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00897B,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getAdmissionTypeLabel(admissionType),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF00897B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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

  String _getAdmissionTypeLabel(String type) {
    switch (type) {
      case 'outpatient':
        return 'Rawat Jalan';
      case 'inpatient':
        return 'Rawat Inap';
      case 'emergency':
        return 'IGD';
      default:
        return type;
    }
  }
}
