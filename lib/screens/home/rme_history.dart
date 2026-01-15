// lib/screens/home/rme_history.dart
// FINAL VERSION - History Log based on `histories` collection
// Used by doctor / coder / auditor via role filter

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RMEHistory extends StatefulWidget {
  final String role; // doctor | coder | auditor

  const RMEHistory({super.key, required this.role});

  @override
  State<RMEHistory> createState() => _RMEHistoryState();
}

class _RMEHistoryState extends State<RMEHistory> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'semua'; // semua | 7hari | 30hari

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Base query for histories
  Query _baseQuery() {
    Query query = FirebaseFirestore.instance
        .collection('histories')
        .where('role', isEqualTo: widget.role)
        .orderBy('createdAt', descending: true);

    if (_selectedFilter == '7hari') {
      final sevenDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 7)),
      );
      query = query.where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo);
    } else if (_selectedFilter == '30hari') {
      final thirtyDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 30)),
      );
      query = query.where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo);
    }

    return query;
  }

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
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
              'Riwayat Aktivitas',
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
                hintText: 'Cari nama pasien atau No. RM',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00897B)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

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
              stream: _baseQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00897B),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final search = _searchCtrl.text.toLowerCase();
                final docs =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['patientName'] ?? '').toString().toLowerCase();
                      final id =
                          (data['patientId'] ?? '').toString().toLowerCase();
                      return name.contains(search) || id.contains(search);
                    }).toList();

                if (docs.isEmpty) {
                  return _noSearchResult();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return _buildHistoryCard(data);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI COMPONENTS =====================

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
      onSelected: (_) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: Color(0xFF00897B), width: 1.5),
      selectedColor: const Color(0xFF00897B),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: const Border(
            left: BorderSide(color: Color(0xFF00897B), width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00897B).withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['patientName'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM: ${data['patientId'] ?? '-'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['action'] ?? '-',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(
                    data['status'] ?? '-',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(data['createdAt']),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _noSearchResult() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        'Tidak ada hasil pencarian',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

  // ===================== DETAIL DIALOG =====================

  void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Aktivitas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _detailRow('Nama Pasien', data['patientName']),
                _detailRow('No. RM', data['patientId']),
                _detailRow('Aksi', data['action']),
                _detailRow('Status', data['status']),
                _detailRow('Tanggal', _formatDate(data['createdAt'])),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
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

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
