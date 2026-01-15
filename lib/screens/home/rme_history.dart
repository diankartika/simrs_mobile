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

  // 🔑 QUERY STABIL (TIDAK PAKE FILTER TANGGAL DI FIRESTORE)
  Query _baseQuery() {
    return FirebaseFirestore.instance
        .collection('histories')
        .where('role', isEqualTo: widget.role)
        .orderBy('createdAt', descending: true);
  }

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }

  bool _matchDateFilter(Timestamp? ts) {
    if (ts == null) return false;

    final now = DateTime.now();
    final date = ts.toDate();

    if (_selectedFilter == '7hari') {
      return date.isAfter(now.subtract(const Duration(days: 7)));
    }

    if (_selectedFilter == '30hari') {
      return date.isAfter(now.subtract(const Duration(days: 30)));
    }

    return true; // semua
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
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // FILTER
            Row(
              children: [
                _filterChip('Semua', 'semua'),
                const SizedBox(width: 8),
                _filterChip('7 Hari', '7hari'),
                const SizedBox(width: 8),
                _filterChip('30 Hari', '30hari'),
              ],
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

                // 🔑 FILTER DI CLIENT (AMAN)
                final filteredDocs =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final ts = data['createdAt'] as Timestamp?;
                      if (!_matchDateFilter(ts)) return false;

                      final name =
                          (data['patientName'] ?? '').toString().toLowerCase();
                      final rm =
                          (data['rmNumber'] ?? '').toString().toLowerCase();

                      return name.contains(search) || rm.contains(search);
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return _noResult();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    return _historyCard(data);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _filterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF00897B),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: const Color(0xFF00897B),
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: Color(0xFF00897B)),
    );
  }

  Widget _historyCard(Map<String, dynamic> data) {
    return Container(
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
                  'Aksi: ${data['action'] ?? '-'}',
                  style: const TextStyle(fontSize: 12),
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
              if (data['createdAt'] != null)
                Text(
                  _formatDate(data['createdAt']),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
            ],
          ),
        ],
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

  Widget _noResult() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        'Tidak ada hasil',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }
}
