// lib/screens/home/rme_history.dart - RME FORM HISTORY
// Shows all completed RME forms by doctor with search, filter, and detail view

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';

class RMEHistory extends StatefulWidget {
  const RMEHistory({super.key});

  @override
  State<RMEHistory> createState() => _RMEHistoryState();
}

class _RMEHistoryState extends State<RMEHistory> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'semua'; // semua, 7hari, 30hari

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      // Silent
    }
    return null;
  }

  Query _getFilteredQuery() {
    Query query = FirebaseFirestore.instance
        .collection('rme_forms')
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true);

    if (_selectedFilter == '7hari') {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      query = query.where('createdAt', isGreaterThan: sevenDaysAgo);
    } else if (_selectedFilter == '30hari') {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      query = query.where('createdAt', isGreaterThan: thirtyDaysAgo);
    }

    return query;
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            const Text(
              'Histori RME',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // SEARCH BAR
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

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('7 Hari', '7hari'),
                  const SizedBox(width: 8),
                  _buildFilterChip('30 Hari', '30hari'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // HISTORY LIST
            StreamBuilder<QuerySnapshot>(
              stream: _getFilteredQuery().snapshots(),
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
                          Icon(
                            Icons.history_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada histori RME',
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

                final docs = snapshot.data!.docs;
                final searchQuery = _searchCtrl.text.toLowerCase();

                // Filter by search query
                final filteredDocs =
                    docs.where((doc) {
                      final patientName =
                          (doc['patientName'] as String? ?? '').toLowerCase();
                      final patientId =
                          (doc['patientId'] as String? ?? '').toLowerCase();
                      return patientName.contains(searchQuery) ||
                          patientId.contains(searchQuery);
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
                    final data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        _showDetailDialog(context, data);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama: ${data['patientName'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00897B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'RM: ${data['patientId'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tanggal: ${_formatDate(data['createdAt'] as Timestamp)}',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF00897B),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.transparent,
      side: BorderSide(color: const Color(0xFF00897B), width: 1.5),
      selectedColor: const Color(0xFF00897B),
    );
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail RME',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Patient Info
                _buildDetailRow('Nama Pasien', data['patientName'] ?? '-'),
                _buildDetailRow('No. RM', data['patientId'] ?? '-'),
                _buildDetailRow(
                  'Tanggal',
                  _formatDate(data['createdAt'] as Timestamp),
                ),
                const SizedBox(height: 12),

                // Form Data
                const Text(
                  'Keluhan Utama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  data['keluhan'] ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Riwayat Penyakit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  data['riwayat'] ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Diagnosis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  data['diagnosis'] ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Terapi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  data['terapi'] ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
