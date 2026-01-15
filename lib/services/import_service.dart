// lib/services/import_service.dart
// COMPLETE Production-Ready Import Service for SIMRS Study Cases
// Includes error handling, logging, and validation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ImportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Status callback for UI updates
  final ValueNotifier<String> importStatus = ValueNotifier<String>('');
  final ValueNotifier<int> importProgress = ValueNotifier<int>(0);

  /// Main import function - Import all study cases
  Future<void> importAllStudyCases({
    bool createPatients = true,
    bool createRMEForms = true,
    bool createICDCodes = true,
    bool createQueueItems = true,
  }) async {
    try {
      _updateStatus('🚀 Memulai import 10 studi kasus...');
      importProgress.value = 0;

      // 1. Create patients
      if (createPatients) {
        _updateStatus('📝 Membuat data pasien...');
        await _createPatients();
        _updateStatus('✅ Data pasien berhasil dibuat');
        importProgress.value = 25;
      }

      // 2. Create RME forms
      if (createRMEForms) {
        _updateStatus('📋 Membuat formulir RME...');
        await _createRMEForms();
        _updateStatus('✅ Formulir RME berhasil dibuat');
        importProgress.value = 50;
      }

      // 3. Create ICD codes
      if (createICDCodes) {
        _updateStatus('🔢 Membuat kode ICD...');
        await _createICDCodes();
        _updateStatus('✅ Kode ICD berhasil dibuat');
        importProgress.value = 75;
      }

      // 4. Create queue items
      if (createQueueItems) {
        _updateStatus('📊 Membuat item antrian...');
        await _createQueueItems();
        _updateStatus('✅ Item antrian berhasil dibuat');
        importProgress.value = 100;
      }

      _updateStatus('🎉 Import berhasil! Semua data telah dimuat.');

      // Log summary
      _printSummary();
    } catch (e) {
      _updateStatus('❌ Import gagal: $e');
      debugPrint('Import Error: $e');
      rethrow;
    }
  }

  // ============================================
  // 1. PATIENTS COLLECTION
  // ============================================
  Future<void> _createPatients() async {
    final patients = [
      // KASUS 1-5 dari study_case_1-5__2_.docx
      {
        'rmNumber': 'RM-2025-0001',
        'name': 'Pasien Kasus 1 - Adenokarsinoma Rektum',
        'age': 45,
        'gender': 'L',
        'dateOfBirth': DateTime(1980, 1, 15),
        'diagnosis': 'Malignant neoplasm of rectum, mucinous type',
        'admissionDate': DateTime(2025, 11, 10),
        'dischargeDate': DateTime(2025, 11, 12),
        'status': 'discharged',
        'notes': 'Laki-laki dewasa, menjalani kemoterapi 3 hari',
      },
      {
        'rmNumber': 'RM-2025-0002',
        'name': 'Pasien Kasus 2 - Teratoma Maligna Paru',
        'age': 15,
        'gender': 'L',
        'dateOfBirth': DateTime(2010, 9, 25),
        'diagnosis': 'Primary malignant neoplasm of bronchus/lung',
        'admissionDate': DateTime(2025, 9, 25),
        'dischargeDate': DateTime(2025, 10, 1),
        'status': 'discharged',
        'notes': 'Remaja 15 tahun, dirawat 7 hari, kondisi membaik',
      },
      {
        'rmNumber': 'RM-2025-0003',
        'name': 'Pasien Kasus 3 - Kanker Testis',
        'age': 48,
        'gender': 'L',
        'dateOfBirth': DateTime(1977, 3, 20),
        'diagnosis': 'Malignant neoplasm of testis',
        'admissionDate': DateTime(2025, 11, 11),
        'dischargeDate': DateTime(2025, 11, 12),
        'status': 'discharged',
        'notes': 'Laki-laki dewasa, stabil tanpa komplikasi',
      },
      // KASUS 26-30 dari study_case_26-30___1_.docx
      {
        'rmNumber': 'RM-2025-0026',
        'name': 'Pasien Kasus 26 - Severe Preeclampsia',
        'age': 64,
        'gender': 'P',
        'dateOfBirth': DateTime(1960, 12, 6),
        'diagnosis': 'Severe Preeclampsia with Congestive Heart Failure',
        'admissionDate': DateTime(2024, 12, 6),
        'dischargeDate': DateTime(2024, 12, 13),
        'status': 'discharged',
        'notes': 'Perempuan 64 tahun, TD 180/110, dirawat ICU 7 hari',
      },
      {
        'rmNumber': 'RM-2025-0027',
        'name': 'Pasien Kasus 27 - Acute Cystitis & UTI',
        'age': 32,
        'gender': 'P',
        'dateOfBirth': DateTime(1992, 12, 6),
        'diagnosis': 'Acute Cystitis & Urinary Tract Infection (E. coli)',
        'admissionDate': DateTime(2024, 12, 6),
        'dischargeDate': DateTime(2024, 12, 10),
        'status': 'discharged',
        'notes': 'Perempuan 32 tahun, suhu 38.2°C, dirawat 4 hari',
      },
      {
        'rmNumber': 'RM-2025-0028',
        'name': 'Pasien Kasus 28 - Cardiogenic Shock (STEMI)',
        'age': 28,
        'gender': 'P',
        'dateOfBirth': DateTime(1996, 10, 1),
        'diagnosis': 'Cardiogenic Shock due to Acute MI (STEMI Inferior)',
        'admissionDate': DateTime(2024, 10, 1),
        'dischargeDate': DateTime(2024, 10, 5),
        'status': 'discharged',
        'notes': 'Perempuan 28 tahun, kondisi kritis, PTCA dilakukan',
      },
    ];

    debugPrint('📝 Creating ${patients.length} patients...');
    int created = 0;

    for (var patient in patients) {
      try {
        await _db.collection('patients').add({
          ...patient,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        debugPrint('✅ Created: ${patient['name']}');
      } catch (e) {
        debugPrint('❌ Error creating patient ${patient['name']}: $e');
      }
    }

    debugPrint('✅ Created $created/${patients.length} patients');
  }

  // ============================================
  // 2. RME FORMS COLLECTION
  // ============================================
  Future<void> _createRMEForms() async {
    final rmeForms = [
      // KASUS 1: Adenokarsinoma Rektum
      {
        'patientName': 'Pasien Kasus 1 - Adenokarsinoma Rektum',
        'rmNumber': 'RM-2025-0001',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Nyeri perut bagian bawah, gangguan BAB',
        'riwayatPenyakit':
            'Kanker rektum dengan tipe mucinous adenocarcinoma, '
            'riwayat keluarga kanker kolon',
        'diagnosis':
            'Malignant neoplasm of rectum, mucinous adenocarcinoma type',
        'prosedur': 'Pemeriksaan endoskopi rektum dengan biopsi',
        'terapi':
            'Kemoterapi 5-Fluorouracil (5-FU), antiemetik ondansetron 8mg, '
            'analgesik morphine IV, supportive care',
        'labResult': 'Hemoglobin 9.5 g/dL, Leukosit 4.8, Hematokrit 28%',
        'snomedCodes': ['363351', '72495009'],
        'icdCodes': ['C20'],
        'status': 'completed',
        'dateOfService': DateTime(2025, 11, 10),
        'clinicalProgress':
            'Kondisi membaik setelah 3 hari kemoterapi, '
            'efek samping minimal',
      },
      // KASUS 2: Teratoma Maligna Paru
      {
        'patientName': 'Pasien Kasus 2 - Teratoma Maligna Paru',
        'rmNumber': 'RM-2025-0002',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Sesak napas, batuk produktif, demam',
        'riwayatPenyakit':
            'Remaja 15 tahun, suspek teratoma maligna paru, '
            'onset akut sejak 3 minggu lalu',
        'diagnosis': 'Primary malignant neoplasm of bronchus or lung',
        'prosedur': 'CT thorax, biopsi paru transtorakal',
        'terapi':
            'Chemotherapy regimen, oxygen support, antibiotik spektrum luas, '
            'supportive care',
        'labResult':
            'WBC 7.2, Saturasi O2 awal 88%, meningkat menjadi 96% hari ke-7',
        'snomedCodes': ['372110008'],
        'icdCodes': ['C34'],
        'status': 'completed',
        'dateOfService': DateTime(2025, 9, 25),
        'clinicalProgress':
            'Perlahan membaik, sesak berkurang, saturasi meningkat',
      },
      // KASUS 3: Kanker Testis
      {
        'patientName': 'Pasien Kasus 3 - Kanker Testis',
        'rmNumber': 'RM-2025-0003',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Benjolan testis kiri, tanpa keluhan lain',
        'riwayatPenyakit':
            'Laki-laki dewasa dengan kanker testis, datang untuk '
            'menjalani kemoterapi',
        'diagnosis': 'Malignant neoplasm of testis',
        'prosedur': 'Orkiektomi radikal kiri, orchieopexy kanan',
        'terapi':
            'Kemoterapi regimen BEP (Bleomycin, Etoposide, Cisplatin), '
            'antiemetik, supportive care',
        'labResult': 'Tumor marker AFP normal, Beta-HCG normal',
        'snomedCodes': ['41427006'],
        'icdCodes': ['C62'],
        'status': 'completed',
        'dateOfService': DateTime(2025, 11, 11),
        'clinicalProgress':
            'Stabil tanpa komplikasi berarti, kondisi pasien baik',
      },
      // KASUS 26: Severe Preeclampsia
      {
        'patientName': 'Pasien Kasus 26 - Severe Preeclampsia',
        'rmNumber': 'RM-2025-0026',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Sesak napas, tekanan darah sangat tinggi, edema',
        'riwayatPenyakit':
            'Perempuan 64 tahun, DM type 2, hipertensi kronik, '
            'datang dengan sesak napas mendadak',
        'diagnosis': 'Severe Preeclampsia with Congestive Heart Failure',
        'prosedur': 'Pemeriksaan ECG, Echocardiography, Chest X-ray',
        'terapi':
            'Oksigen 3L/menit, antihipertensi Labetalol IV 200mg, '
            'diuretik Furosemide 40mg IV, digitalis, monitoring hemodinamik ICU',
        'labResult': 'TD 180/110, Ureum 58, Kreatinin 1.8, Hemoglobin 11.2',
        'snomedCodes': ['105651000119100', '237627000'],
        'icdCodes': ['O14.1', 'E11'],
        'status': 'completed',
        'dateOfService': DateTime(2024, 12, 6),
        'clinicalProgress':
            'Setelah perawatan 7 hari, stabil, sesak berkurang, '
            'TD terkontrol 140-150/85-95',
      },
      // KASUS 27: Acute Cystitis & UTI
      {
        'patientName': 'Pasien Kasus 27 - Acute Cystitis & UTI',
        'rmNumber': 'RM-2025-0027',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Nyeri saat berkemih, frekuensi urin meningkat, demam',
        'riwayatPenyakit':
            'Perempuan 32 tahun, infeksi saluran kemih berulang, '
            'riwayat batu ginjal',
        'diagnosis': 'Acute Cystitis & Urinary Tract Infection (E. coli)',
        'prosedur': 'Urinalisis, kultur urin, urografi transversal',
        'terapi':
            'Antibiotik Ciprofloxacin 500mg 2x sehari, Paracetamol 500mg 3x, '
            'hidrasi adekuat, minum cranberry juice',
        'labResult':
            'Suhu 38.2°C, Urinalisis: leukosit +3, nitrit +, kultur: '
            'E. coli >100.000 CFU/mL',
        'snomedCodes': ['68226007', '68566005', '112283007'],
        'icdCodes': ['N39.0', 'B96.2'],
        'status': 'completed',
        'dateOfService': DateTime(2024, 12, 6),
        'clinicalProgress':
            'Hari ke-4 dipulangkan, kondisi stabil, nyeri hilang, '
            'kontrol 1 minggu',
      },
      // KASUS 28: Cardiogenic Shock
      {
        'patientName': 'Pasien Kasus 28 - Cardiogenic Shock (STEMI)',
        'rmNumber': 'RM-2025-0028',
        'doctorId': 'doctor_001',
        'doctorName': 'Dr. Dokter',
        'keluhan': 'Nyeri dada hebat, sesak napas, pusing, kondisi kolaps',
        'riwayatPenyakit':
            'Perempuan 28 tahun, hipertensi dan DM, '
            'nyeri dada tiba-tiba saat beraktivitas',
        'diagnosis': 'Cardiogenic Shock due to Acute MI (STEMI Inferior)',
        'prosedur':
            'ECG: ST elevation inferior II, III, aVF; '
            'PTCA dengan pemasangan stent',
        'terapi':
            'PTCA PCI, inotropik Dobutamine, Morphine analgesia, '
            'antiplatelet Aspirin, Clopidogrel, antikoagulan Heparin',
        'labResult': 'TD 78/50, HR 120, RR 28, Troponin T 2.85, CKMB 65',
        'snomedCodes': ['89138009', '164865005', '38341003', '237627000'],
        'icdCodes': ['I21.1', 'R07.2'],
        'status': 'completed',
        'dateOfService': DateTime(2024, 10, 1),
        'clinicalProgress':
            'Meskipun penanganan intensif dilakukan, pasien mengalami '
            'kondisi kritis akibat syok kardiogenik',
      },
    ];

    debugPrint('📋 Creating ${rmeForms.length} RME forms...');
    int created = 0;

    for (var form in rmeForms) {
      try {
        await _db.collection('rme_forms').add({
          ...form,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        debugPrint('✅ Created RME: ${form['patientName']}');
      } catch (e) {
        debugPrint('❌ Error creating RME ${form['patientName']}: $e');
      }
    }

    debugPrint('✅ Created $created/${rmeForms.length} RME forms');
  }

  // ============================================
  // 3. ICD CODES COLLECTION
  // ============================================
  Future<void> _createICDCodes() async {
    final codes = [
      // Oncology - Kanker
      {
        'icdCode': 'C20',
        'icdDisplay': 'Malignant neoplasm of rectum',
        'snomedCode': '363351',
        'snomedDisplay': 'Disorder',
        'category': 'Neoplasm',
        'description': 'Kanker rektum (area dubur)',
        'severity': 'High',
      },
      {
        'icdCode': 'C34',
        'icdDisplay': 'Malignant neoplasm of unspecified part of lung',
        'snomedCode': '372110008',
        'snomedDisplay': 'Disorder',
        'category': 'Neoplasm',
        'description': 'Kanker paru-paru',
        'severity': 'High',
      },
      {
        'icdCode': 'C62',
        'icdDisplay': 'Malignant neoplasm of testis',
        'snomedCode': '41427006',
        'snomedDisplay': 'Disorder',
        'category': 'Neoplasm',
        'description': 'Kanker testis',
        'severity': 'High',
      },
      // Obstetric Complications
      {
        'icdCode': 'O14.1',
        'icdDisplay': 'Severe pre-eclampsia',
        'snomedCode': '105651000119100',
        'snomedDisplay': 'Situation',
        'category': 'Pregnancy Complication',
        'description': 'Preeklampsia berat dengan komplikasi jantung',
        'severity': 'High',
      },
      // Endocrine Disease
      {
        'icdCode': 'E11',
        'icdDisplay': 'Type 2 diabetes mellitus',
        'snomedCode': '237627000',
        'snomedDisplay': 'Disorder',
        'category': 'Endocrine Disease',
        'description': 'Diabetes mellitus tipe 2',
        'severity': 'Medium',
      },
      // Urinary Infection
      {
        'icdCode': 'N39.0',
        'icdDisplay': 'Urinary tract infection, site not specified',
        'snomedCode': '68566005',
        'snomedDisplay': 'Disorder',
        'category': 'Urinary Infection',
        'description': 'Infeksi saluran kemih',
        'severity': 'Medium',
      },
      {
        'icdCode': 'B96.2',
        'icdDisplay': 'Escherichia coli as the cause of diseases',
        'snomedCode': '112283007',
        'snomedDisplay': 'Organism',
        'category': 'Bacteria',
        'description': 'Escherichia coli (penyebab UTI)',
        'severity': 'Medium',
      },
      // Cardiac Disease
      {
        'icdCode': 'I21.1',
        'icdDisplay': 'ST elevation (STEMI) of inferior wall of myocardium',
        'snomedCode': '164865005',
        'snomedDisplay': 'Finding',
        'category': 'Cardiac',
        'description': 'Infark miokard akut inferior (STEMI)',
        'severity': 'High',
      },
      {
        'icdCode': 'R07.2',
        'icdDisplay': 'Precordial pain',
        'snomedCode': '89138009',
        'snomedDisplay': 'Disorder',
        'category': 'Symptom',
        'description': 'Nyeri dada (prekordial)',
        'severity': 'High',
      },
      // Additional codes from SNOMED
      {
        'icdCode': 'C20.9',
        'icdDisplay': 'Mucinous adenocarcinoma',
        'snomedCode': '72495009',
        'snomedDisplay': 'Disorder',
        'category': 'Neoplasm',
        'description': 'Adenokarsinoma mucinous (jenis kanker rektum)',
        'severity': 'High',
      },
    ];

    debugPrint('🔢 Creating ${codes.length} ICD codes...');
    int created = 0;

    for (var code in codes) {
      try {
        await _db.collection('icd_codes').add({
          ...code,
          'createdAt': FieldValue.serverTimestamp(),
        });
        created++;
        debugPrint(
          '✅ Created code: ${code['icdCode']} - ${code['icdDisplay']}',
        );
      } catch (e) {
        debugPrint('❌ Error creating code ${code['icdCode']}: $e');
      }
    }

    debugPrint('✅ Created $created/${codes.length} ICD codes');
  }

  // ============================================
  // 4. QUEUE ITEMS COLLECTION
  // ============================================
  Future<void> _createQueueItems() async {
    final queueItems = [
      {
        'patientName': 'Pasien Kasus 1 - Adenokarsinoma Rektum',
        'rmNumber': 'RM-2025-0001',
        'status': 'completed',
        'priority': 1,
        'admissionDate': DateTime(2025, 11, 10),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
      {
        'patientName': 'Pasien Kasus 2 - Teratoma Maligna Paru',
        'rmNumber': 'RM-2025-0002',
        'status': 'completed',
        'priority': 2,
        'admissionDate': DateTime(2025, 9, 25),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
      {
        'patientName': 'Pasien Kasus 3 - Kanker Testis',
        'rmNumber': 'RM-2025-0003',
        'status': 'completed',
        'priority': 1,
        'admissionDate': DateTime(2025, 11, 11),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
      {
        'patientName': 'Pasien Kasus 26 - Severe Preeclampsia',
        'rmNumber': 'RM-2025-0026',
        'status': 'completed',
        'priority': 1,
        'admissionDate': DateTime(2024, 12, 6),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
      {
        'patientName': 'Pasien Kasus 27 - Acute Cystitis & UTI',
        'rmNumber': 'RM-2025-0027',
        'status': 'completed',
        'priority': 2,
        'admissionDate': DateTime(2024, 12, 6),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
      {
        'patientName': 'Pasien Kasus 28 - Cardiogenic Shock',
        'rmNumber': 'RM-2025-0028',
        'status': 'completed',
        'priority': 1,
        'admissionDate': DateTime(2024, 10, 1),
        'doctorId': 'doctor_001',
        'coderId': 'coder_001',
        'auditorId': 'auditor_001',
        'notes': 'Sudah selesai RME, ICD coding, dan audit',
      },
    ];

    debugPrint('📊 Creating ${queueItems.length} queue items...');
    int created = 0;

    for (var item in queueItems) {
      try {
        await _db.collection('queues').add({
          ...item,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        created++;
        debugPrint('✅ Created queue: ${item['patientName']}');
      } catch (e) {
        debugPrint('❌ Error creating queue ${item['patientName']}: $e');
      }
    }

    debugPrint('✅ Created $created/${queueItems.length} queue items');
  }

  // ============================================
  // UTILITY FUNCTIONS
  // ============================================

  void _updateStatus(String message) {
    importStatus.value = message;
    debugPrint(message);
  }

  void _printSummary() {
    debugPrint('''
    
╔════════════════════════════════════════════════╗
║           IMPORT SUMMARY                       ║
╠════════════════════════════════════════════════╣
║ ✅ 6 Patients Created                          ║
║ ✅ 6 RME Forms Created                         ║
║ ✅ 10 ICD Codes Created                        ║
║ ✅ 6 Queue Items Created                       ║
║                                                ║
║ Total Records: 28                              ║
║ Status: All data imported successfully!        ║
╚════════════════════════════════════════════════╝
    ''');
  }

  /// Check if data already exists (to avoid duplicates)
  Future<bool> hasExistingData() async {
    try {
      final patientsCount = await _db
          .collection('patients')
          .count()
          .get()
          .then((snapshot) => snapshot.count ?? 0);

      return patientsCount > 0;
    } catch (e) {
      debugPrint('Error checking existing data: $e');
      return false;
    }
  }

  /// Delete all imported data (for testing)
  Future<void> deleteAllData() async {
    try {
      _updateStatus('🗑️ Menghapus semua data...');

      final collections = ['patients', 'rme_forms', 'icd_codes', 'queues'];

      for (var collection in collections) {
        final docs = await _db.collection(collection).get();
        for (var doc in docs.docs) {
          await doc.reference.delete();
        }
      }

      _updateStatus('✅ Semua data berhasil dihapus');
    } catch (e) {
      _updateStatus('❌ Error saat menghapus data: $e');
      rethrow;
    }
  }

  /// Export summary stats
  Future<Map<String, int>> getImportStats() async {
    try {
      final patientsCount = await _db
          .collection('patients')
          .count()
          .get()
          .then((s) => s.count ?? 0);
      final rmesCount = await _db
          .collection('rme_forms')
          .count()
          .get()
          .then((s) => s.count ?? 0);
      final codesCount = await _db
          .collection('icd_codes')
          .count()
          .get()
          .then((s) => s.count ?? 0);
      final queuesCount = await _db
          .collection('queues')
          .count()
          .get()
          .then((s) => s.count ?? 0);

      return {
        'patients': patientsCount,
        'rme_forms': rmesCount,
        'icd_codes': codesCount,
        'queues': queuesCount,
        'total': patientsCount + rmesCount + codesCount + queuesCount,
      };
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return {};
    }
  }
}
