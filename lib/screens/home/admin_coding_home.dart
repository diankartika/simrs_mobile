// lib/screens/home/admin_coding_home.dart - ADMIN CODING/ICD (TAB 2)
// Shows coding queue with counters and top 5 ICD statistics

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCodingHome extends StatefulWidget {
  const AdminCodingHome({super.key});

  @override
  State<AdminCodingHome> createState() => _AdminCodingHomeState();
}

class _AdminCodingHomeState extends State<AdminCodingHome> {
  Future<List<Map<String, dynamic>>> _getTopICDCodes() async {
    try {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      final docs =
          await FirebaseFirestore.instance
              .collection('coding_forms')
              .where('createdAt', isGreaterThan: tenDaysAgo)
              .get();

      Map<String, int> icdCount = {};
      for (var doc in docs.docs) {
        final data = doc.data();
        final icdCodes = data['icdCodes'] as List<dynamic>?;
        if (icdCodes != null) {
          for (var code in icdCodes) {
            final codeStr = code.toString();
            icdCount[codeStr] = (icdCount[codeStr] ?? 0) + 1;
          }
        }
      }

      final sortedCodes =
          icdCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      return sortedCodes
          .take(5)
          .map((e) => {'code': e.key, 'count': e.value})
          .toList();
    } catch (e) {
      return [];
    }
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
            // TITLE WITH SUBTITLE
            const Text(
              'Halo Admin!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Pengkodean ICD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // COUNTERS ROW
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment,
                            color: Color(0xFF00897B),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Menunggu\nPengkodean',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('coding_forms')
                                    .where('status', isEqualTo: 'pending')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B),
                                  borderRadius: BorderRadius.circular(4),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.done,
                            color: Color(0xFF00897B),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Perlu\nReview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('coding_forms')
                                    .where(
                                      'status',
                                      isEqualTo: 'pending_review',
                                    )
                                    .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B),
                                  borderRadius: BorderRadius.circular(4),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KODING ICD SECTION
            const Text(
              'Koding ICD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // CODING QUEUE LIST
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('coding_forms')
                      .where('status', isEqualTo: 'pending')
                      .orderBy('createdAt', descending: true)
                      .limit(3)
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
                            'Tidak ada form yang perlu dikoding',
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

                final codingDocs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: codingDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        codingDocs[index].data() as Map<String, dynamic>;
                    return Padding(
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
                                    'No. RM Pasien : ${data['patientId'] ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00897B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nama Pasien : ${data['patientName'] ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tgl. : 10 Nov 2025 (1 hari lalu)',
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
                );
              },
            ),
            const SizedBox(height: 16),

            // LIHAT SEMUA BUTTON
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list),
                label: const Text('Lihat Semua'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // STATISTIK SECTION
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // TOP 5 ICD CODES
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top 5 Kode ICD - 10 Hari Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getTopICDCodes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'Tidak ada data',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      }

                      final topCodes = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topCodes.length,
                        itemBuilder: (context, index) {
                          final item = topCodes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${item['code']} - ICD Code',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${item['count']} kasus',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: Color(0xFF00897B),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // LIHAT SEMUA STATISTIK
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list),
                label: const Text('Lihat Semua'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
