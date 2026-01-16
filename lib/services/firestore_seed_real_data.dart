// lib/services/firestore_seed_real_data.dart
// Real dummy data extracted from case studies (KASUS 1-30 + SNOMED-CT)

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeedRealData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this in main.dart after Firebase initialization
  /// Example: await FirestoreSeedRealData.seedRealData();
  static Future<void> seedRealData() async {
    try {
      // Check if already seeded
      final check = await _firestore.collection('_seed').doc('real_data').get();
      if (check.exists) {
        return; // Already seeded
      }

      // Seed real patients
      await _seedRealPatients();

      // Seed real ICD codes
      await _seedRealICDCodes();

      // Mark as seeded
      await _firestore.collection('_seed').doc('real_data').set({
        'seeded': true,
        'date': Timestamp.now(),
      });
    } catch (e) {
      // Silent fail
    }
  }

  static Future<void> _seedRealPatients() async {
    final patients = [
      // KASUS 1 - Malignant neoplasm of rectum
      {
        'rmNumber': 'RM-2025-0001',
        'name': 'Budi Santoso',
        'nik': '3273456789012345',
        'birthDate': Timestamp.fromDate(DateTime(1960, 5, 15)),
        'gender': 'Laki-laki',
        'age': 65,
        'address': 'Jl. Gatot Subroto No. 456, Jakarta Selatan',
        'phone': '082345678901',
        'education': 'S1',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis':
            'Malignant neoplasm of rectum type mucinous adenocarcinoma',
        'snomedCode': '363351, 72495009',
      },
      // KASUS 2 - Primary malignant neoplasm of lower lobe lung
      {
        'rmNumber': 'RM-2025-0002',
        'name': 'Ahmad Wijaya',
        'nik': '3272987654321098',
        'birthDate': Timestamp.fromDate(DateTime(2009, 3, 20)),
        'gender': 'Laki-laki',
        'age': 15,
        'address': 'Jl. Jenderal Sudirman No. 789, Bandung',
        'phone': '082456789012',
        'education': 'SMA',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis':
            'Primary malignant neoplasm of lower lobe, bronchus or lung',
        'snomedCode': '372110008',
      },
      // KASUS 3 - Complex case
      {
        'rmNumber': 'RM-2025-0003',
        'name': 'Siti Nurhaliza',
        'nik': '3201567890123456',
        'birthDate': Timestamp.fromDate(DateTime(1975, 7, 10)),
        'gender': 'Perempuan',
        'age': 50,
        'address': 'Jl. Ahmad Yani No. 321, Medan',
        'phone': '083456789012',
        'education': 'D3',
        'insurance': 'Asuransi Swasta',
        'serviceType': 'Rawat Jalan',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis': 'Metastatic carcinoma',
        'snomedCode': '94222006',
      },
      // KASUS 4 - Acute lymphoid leukemia
      {
        'rmNumber': 'RM-2025-0004',
        'name': 'Rina Wijayanti',
        'nik': '3202345678901234',
        'birthDate': Timestamp.fromDate(DateTime(2009, 11, 25)),
        'gender': 'Perempuan',
        'age': 15,
        'address': 'Jl. Diponegoro No. 555, Surabaya',
        'phone': '084567890123',
        'education': 'SMA',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis': 'Acute lymphoid leukemia, disease (disorder)',
        'snomedCode': '91857003',
      },
      // KASUS 5 - Head and neck carcinoma
      {
        'rmNumber': 'RM-2025-0005',
        'name': 'Daniella Simamurung',
        'nik': '3201234567890123',
        'birthDate': Timestamp.fromDate(DateTime(1983, 8, 30)),
        'gender': 'Perempuan',
        'age': 41,
        'address': 'Jl. Sudirman No. 123, Jakarta Pusat',
        'phone': '081234567890',
        'education': 'S1',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis': 'Metastatic carcinoma of head and neck',
        'snomedCode': '94222006',
      },
      // KASUS 26 - Severe Preeclampsia
      {
        'rmNumber': 'RM-2025-0006',
        'name': 'Dewi Kusuma',
        'nik': '3205432109876543',
        'birthDate': Timestamp.fromDate(DateTime(1960, 2, 14)),
        'gender': 'Perempuan',
        'age': 64,
        'address': 'Jl. Merdeka No. 100, Yogyakarta',
        'phone': '085678901234',
        'education': 'S1',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis':
            'Severe Preeclampsia dengan Gagal Jantung Kongestif, DM type 2',
        'snomedCode': '105651000119100, 237627000',
      },
      // KASUS 27 - Urinary tract infection
      {
        'rmNumber': 'RM-2025-0007',
        'name': 'Ratna Sari',
        'nik': '3206543210987654',
        'birthDate': Timestamp.fromDate(DateTime(1992, 6, 8)),
        'gender': 'Perempuan',
        'age': 32,
        'address': 'Jl. Gatot Subroto No. 200, Semarang',
        'phone': '086789012345',
        'education': 'S1',
        'insurance': 'Umum',
        'serviceType': 'Rawat Jalan',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis':
            'Acute cystitis, Urinary tract infection, Escherichia coli',
        'snomedCode': '68226007, 68566005, 112283007',
      },
      // KASUS 28 - Cardiogenic shock
      {
        'rmNumber': 'RM-2025-0008',
        'name': 'Hendra Gunawan',
        'nik': '3207654321098765',
        'birthDate': Timestamp.fromDate(DateTime(1996, 9, 12)),
        'gender': 'Laki-laki',
        'age': 28,
        'address': 'Jl. Pemuda No. 300, Palembang',
        'phone': '087890123456',
        'education': 'S1',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis':
            'Cardiogenic shock, Electrocardiographic myocardial infarction, hypertension, diabetes mellitus type 2',
        'snomedCode': '89138009, 164865005, 38341003, 237627000',
      },
      // KASUS 29 - Tuberculosis
      {
        'rmNumber': 'RM-2025-0009',
        'name': 'Bambang Sudiro',
        'nik': '3208765432109876',
        'birthDate': Timestamp.fromDate(DateTime(1965, 4, 18)),
        'gender': 'Laki-laki',
        'age': 59,
        'address': 'Jl. Imam Bonjol No. 400, Medan',
        'phone': '088901234567',
        'education': 'SMA',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis': 'Tuberculosis of lung, confirmed by sputum microscopy',
        'snomedCode': '186193001',
      },
      // KASUS 30 - Pneumonia
      {
        'rmNumber': 'RM-2025-0010',
        'name': 'Mujiono Hartanto',
        'nik': '3209876543210987',
        'birthDate': Timestamp.fromDate(DateTime(1942, 11, 28)),
        'gender': 'Laki-laki',
        'age': 82,
        'address': 'Jl. Diponegoro No. 500, Jakarta Timur',
        'phone': '089012345678',
        'education': 'SMA',
        'insurance': 'BPJS',
        'serviceType': 'Rawat Inap',
        'registrationDate': Timestamp.now(),
        'status': 'active',
        'diagnosis': 'Pneumonia due to Klebsiella pneumoniae',
        'snomedCode': '53084003',
      },
    ];

    for (final patient in patients) {
      final docRef = await _firestore.collection('patients').add(patient);

      // Also create queue items for first 5 patients
      if (patients.indexOf(patient) < 5) {
        await _firestore.collection('queues').add({
          'patientId': docRef.id,
          'patientName': patient['name'],
          'rmNumber': patient['rmNumber'],
          'currentQueue': 'rme',
          'createdAt': Timestamp.now(),
          'completedAt': null,
          'metadata': {
            'serviceType': patient['serviceType'],
            'diagnosis': patient['diagnosis'],
          },
        });
      }
    }
  }

  static Future<void> _seedRealICDCodes() async {
    // Real ICD-10 codes from case studies
    final icdCodes = [
      {
        'code': 'C20',
        'description': 'Malignant neoplasm of rectum',
        'category': 'Neoplasms',
      },
      {
        'code': 'C34.3',
        'description': 'Malignant neoplasm of lower lobe of lung',
        'category': 'Neoplasms',
      },
      {
        'code': 'C80.1',
        'description': 'Malignant neoplasm of unspecified site',
        'category': 'Neoplasms',
      },
      {
        'code': 'C91.0',
        'description': 'Acute lymphoblastic leukemia',
        'category': 'Neoplasms',
      },
      {
        'code': 'O14.9',
        'description': 'Unspecified pre-eclampsia',
        'category': 'Pregnancy',
      },
      {
        'code': 'N39.0',
        'description': 'Urinary tract infection, site not specified',
        'category': 'Urinary',
      },
      {
        'code': 'I50.9',
        'description': 'Heart failure, unspecified',
        'category': 'Circulatory',
      },
      {
        'code': 'I21.9',
        'description': 'Acute myocardial infarction, unspecified',
        'category': 'Circulatory',
      },
      {
        'code': 'A15.0',
        'description': 'Tuberculosis of lung',
        'category': 'Infectious',
      },
      {
        'code': 'J15.8',
        'description': 'Pneumonia due to other specified infectious organisms',
        'category': 'Respiratory',
      },
      {
        'code': 'I10',
        'description': 'Essential (primary) hypertension',
        'category': 'Circulatory',
      },
      {
        'code': 'E11.9',
        'description': 'Type 2 diabetes mellitus without complications',
        'category': 'Endocrine',
      },
    ];

    for (final code in icdCodes) {
      try {
        await _firestore
            .collection('icd_codes')
            .doc('icd10')
            .collection('codes')
            .doc(code['code'] as String)
            .set(code);
      } catch (e) {
        // Silent fail
      }
    }
  }
}
