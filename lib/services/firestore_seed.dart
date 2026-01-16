// lib/services/firestore_seed.dart
// Run this ONCE to populate dummy data into Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeed {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this in main.dart after Firebase initialization
  /// Example: await FirestoreSeed.seedDatabase();
  static Future<void> seedDatabase() async {
    try {
      // Check if already seeded
      final check = await _firestore.collection('_seed').doc('status').get();
      if (check.exists) {
        return; // Already seeded
      }

      // Seed patients
      await _seedPatients();

      // Seed queue items
      await _seedQueueItems();

      // Mark as seeded
      await _firestore.collection('_seed').doc('status').set({
        'seeded': true,
        'date': Timestamp.now(),
      });
    } catch (e) {
      // Silent fail - app can still work
    }
  }

  static Future<void> _seedPatients() async {
    final patients = [
      {
        'rmNumber': 'RM-2025-0001',
        'name': 'Daniella Simamurung',
        'nik': '3201234567890123',
        'birthDate': Timestamp.fromDate(DateTime(2004, 3, 15)),
        'gender': 'Perempuan',
        'age': 21,
        'address': 'Jl. Sudirman No. 123, Jakarta',
        'phone': '081234567890',
        'education': 'S1',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Jalan',
        'registrationDate': Timestamp.now(),
        'status': 'active',
      },
      {
        'rmNumber': 'RM-2025-0002',
        'name': 'Budi Santoso',
        'nik': '3271987654321098',
        'birthDate': Timestamp.fromDate(DateTime(1987, 6, 20)),
        'gender': 'Laki-laki',
        'age': 37,
        'address': 'Jl. Gatot Subroto No. 456, Bandung',
        'phone': '082345678901',
        'education': 'S1',
        'insurance': 'Asuransi Swasta',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
      },
      {
        'rmNumber': 'RM-2025-0003',
        'name': 'Siti Nurhaliza',
        'nik': '3201567890123456',
        'birthDate': Timestamp.fromDate(DateTime(1995, 11, 28)),
        'gender': 'Perempuan',
        'age': 29,
        'address': 'Jl. Ahmad Yani No. 789, Medan',
        'phone': '083456789012',
        'education': 'SMA',
        'insurance': 'BPJS',
        'serviceType': 'IGD',
        'registrationDate': Timestamp.now(),
        'status': 'active',
      },
      {
        'rmNumber': 'RM-2025-0004',
        'name': 'Ahmad Wijaya',
        'nik': '3273456789012345',
        'birthDate': Timestamp.fromDate(DateTime(1980, 1, 10)),
        'gender': 'Laki-laki',
        'age': 45,
        'address': 'Jl. Diponegoro No. 321, Surabaya',
        'phone': '084567890123',
        'education': 'S2',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Jalan',
        'registrationDate': Timestamp.now(),
        'status': 'active',
      },
      {
        'rmNumber': 'RM-2025-0005',
        'name': 'Rina Wijayanti',
        'nik': '3202345678901234',
        'birthDate': Timestamp.fromDate(DateTime(1992, 8, 14)),
        'gender': 'Perempuan',
        'age': 32,
        'address': 'Jl. Jenderal Sudirman No. 555, Jakarta',
        'phone': '085678901234',
        'education': 'D3',
        'insurance': 'Umum',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
      },
    ];

    for (final patient in patients) {
      await _firestore.collection('patients').add(patient);
    }
  }

  static Future<void> _seedQueueItems() async {
    // Get first 3 patients for queue
    final patientsQuery =
        await _firestore.collection('patients').limit(3).get();

    for (final patientDoc in patientsQuery.docs) {
      final patient = patientDoc.data();

      // Create queue item in RME queue
      await _firestore.collection('queues').add({
        'patientId': patientDoc.id,
        'patientName': patient['name'],
        'rmNumber': patient['rmNumber'],
        'currentQueue': 'rme', // Next: rme → coding → audit → completed
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'metadata': {'serviceType': patient['serviceType']},
      });
    }
  }
}
