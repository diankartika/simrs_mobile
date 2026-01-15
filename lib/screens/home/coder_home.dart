// lib/screens/home/coder_home.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../profile_screen.dart';
import './pengkodean_form.dart';

class CoderHome extends StatefulWidget {
  const CoderHome({super.key});

  @override
  State<CoderHome> createState() => _CoderHomeState();
}

class _CoderHomeState extends State<CoderHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _codingQueue() : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00897B),
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Pengkodean',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // ================= CODING QUEUE =================

  Widget _codingQueue() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Antrian Pengkodean Medis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rme_forms')
                .where('status', isEqualTo: 'completed')
                .orderBy('createdAt')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final rme = docs[index].data() as Map<String, dynamic>;
              final rmeId = docs[index].id;

              return _rmeCard(rme, rmeId);
            },
          );
        },
      ),
    );
  }

  Widget _rmeCard(Map<String, dynamic> rme, String rmeId) {
    return GestureDetector(
      onTap: () async {
        final patient = await _getPatient(rme['patientId']);
        if (!mounted || patient == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PengkodeanForm(rmeFormId: rmeId, patient: patient),
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
          color: const Color(0xFF00897B).withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No. RM: ${rme['rmNumber'] ?? '-'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00897B),
              ),
            ),
            const SizedBox(height: 4),
            Text('Nama: ${rme['patientName'] ?? '-'}'),
            const SizedBox(height: 4),
            Text(
              'Diagnosis: ${rme['diagnosis'] ?? '-'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'Tidak ada RME yang perlu dikodekan',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Future<Patient?> _getPatient(String patientId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();

      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
    } catch (_) {}
    return null;
  }
}
