import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../profile_screen.dart';
import './audit_form.dart';
import './patient_list_universal.dart';

class AuditorHome extends StatefulWidget {
  const AuditorHome({super.key});

  @override
  State<AuditorHome> createState() => _AuditorHomeState();
}

class _AuditorHomeState extends State<AuditorHome> {
  int _currentNavIndex = 0;

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildAuditList();
      case 1:
        return const ProfileScreen();
      default:
        return _buildAuditList();
    }
  }

  // ================= AUDIT LIST =================

  Widget _buildAuditList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Halo Auditor!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QUICK ACCESS
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientListUniversal(),
                  ),
                );
              },
              child: _quickAccessCard(),
            ),
            const SizedBox(height: 24),

            // 🔥 CORE STREAM: coding_forms
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('coding_forms')
                      .where('status', isEqualTo: 'submitted')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final docs = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _counterCard(docs.length),
                    const SizedBox(height: 16),
                    const Text(
                      'List Dokumen Audit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;

                        return _auditCard(data, docId);
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

  // ================= UI PARTS =================

  Widget _auditCard(Map<String, dynamic> data, String docId) {
    return GestureDetector(
      onTap: () async {
        final patient = await _getPatient(data['patientId']);
        if (!mounted || patient == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AuditFormScreen(codingFormId: docId, patient: patient),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: const Color(0xFF00897B), width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00897B).withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No RM: ${data['rmNumber']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00897B),
              ),
            ),
            const SizedBox(height: 4),
            Text('Nama: ${data['patientName']}'),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${_formatDate(data['createdAt'])}',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF00897B), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      children: [
        Icon(Icons.people, color: Color(0xFF00897B)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Lihat Data Pasien',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF00897B),
            ),
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFF00897B)),
      ],
    ),
  );

  Widget _counterCard(int count) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF00897B), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dokumen Menunggu Audit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text('Tidak ada dokumen untuk diaudit'),
    ),
  );

  // ================= HELPER =================

  Future<Patient?> _getPatient(String patientId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get();

    if (doc.exists) {
      return Patient.fromFirestore(doc);
    }
    return null;
  }
}
