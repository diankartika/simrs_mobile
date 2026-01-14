// lib/services/icd_database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ICDCode {
  final String code;
  final String description;

  ICDCode({required this.code, required this.description});

  Map<String, dynamic> toMap() {
    return {'code': code, 'description': description};
  }

  factory ICDCode.fromMap(Map<String, dynamic> map) {
    return ICDCode(
      code: map['code'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  String toString() => '$code - $description';
}

class ICDDatabaseService {
  static final ICDDatabaseService _instance = ICDDatabaseService._internal();

  factory ICDDatabaseService() {
    return _instance;
  }

  ICDDatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock ICD-10 Database (will be synced to Firestore)
  // In production, you'd fetch from: https://www.who.int/standards/classifications/icd
  static final List<ICDCode> icd10Codes = [
    // Common diagnoses from your study cases
    ICDCode(code: 'J11.0', description: 'Influenza with pneumonia'),
    ICDCode(code: 'J02.9', description: 'Acute pharyngitis, unspecified'),
    ICDCode(
      code: 'I10',
      description: 'Essential (primary) hypertension / Hipertensi Esensial',
    ),
    ICDCode(
      code: 'K35.8',
      description: 'Appendicitis, unspecified / Apendesitis Akut Non-Spesifik',
    ),
    ICDCode(
      code: 'J06.9',
      description:
          'Acute upper respiratory infection, unspecified / Infeksi Saluran Napas Akut',
    ),
    ICDCode(
      code: 'N39.0',
      description: 'Urinary tract infection, site not specified',
    ),
    ICDCode(
      code: 'E11.9',
      description: 'Type 2 diabetes mellitus without complications',
    ),
    ICDCode(code: 'F41.1', description: 'Generalized anxiety disorder'),
    ICDCode(code: 'M79.3', description: 'Panniculitis, unspecified'),
    ICDCode(code: 'R10.9', description: 'Unspecified abdominal pain'),
    // Add more as needed
  ];

  // Mock ICD-9-CM Database (Procedure codes)
  static final List<ICDCode> icd9CMCodes = [
    ICDCode(
      code: '99.04',
      description: 'Infusion of chemotherapeutic substance',
    ),
    ICDCode(
      code: '99.15',
      description: 'Parenteral infusion of nutritious substance',
    ),
    ICDCode(code: '88.04', description: 'Routine chest X-ray'),
    ICDCode(code: '81.02', description: 'Arthroscopy of knee'),
    ICDCode(code: '99.84', description: 'Insertion of endotracheal tube'),
    ICDCode(code: '38.91', description: 'Venipuncture'),
    ICDCode(code: '72.72', description: 'Episiotomy'),
    ICDCode(code: '86.04', description: 'Debridement of wound, infection'),
  ];

  // ============ FETCH ICD-10 CODES ============
  Future<List<ICDCode>> searchICD10(String query) async {
    try {
      // First try Firestore
      final snapshot =
          await _firestore
              .collection('icd_codes')
              .doc('icd10')
              .collection('codes')
              .where('code', isGreaterThanOrEqualTo: query.toUpperCase())
              .where('code', isLessThan: query.toUpperCase() + 'z')
              .limit(20)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => ICDCode.fromMap(doc.data())).toList();
      }

      // Fall back to local mock data
      return icd10Codes
          .where(
            (code) =>
                code.code.toUpperCase().contains(query.toUpperCase()) ||
                code.description.toUpperCase().contains(query.toUpperCase()),
          )
          .toList();
    } catch (e) {
      return icd10Codes
          .where(
            (code) =>
                code.code.toUpperCase().contains(query.toUpperCase()) ||
                code.description.toUpperCase().contains(query.toUpperCase()),
          )
          .toList();
    }
  }

  // ============ FETCH ICD-9-CM CODES ============
  Future<List<ICDCode>> searchICD9CM(String query) async {
    try {
      final snapshot =
          await _firestore
              .collection('icd_codes')
              .doc('icd9cm')
              .collection('codes')
              .where('code', isGreaterThanOrEqualTo: query.toUpperCase())
              .where('code', isLessThan: query.toUpperCase() + 'z')
              .limit(20)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => ICDCode.fromMap(doc.data())).toList();
      }

      // Fall back to local mock data
      return icd9CMCodes
          .where(
            (code) =>
                code.code.toUpperCase().contains(query.toUpperCase()) ||
                code.description.toUpperCase().contains(query.toUpperCase()),
          )
          .toList();
    } catch (e) {
      return icd9CMCodes
          .where(
            (code) =>
                code.code.toUpperCase().contains(query.toUpperCase()) ||
                code.description.toUpperCase().contains(query.toUpperCase()),
          )
          .toList();
    }
  }

  // ============ VALIDATE ICD CODE ============
  Future<bool> validateICD10(String code) async {
    try {
      final doc =
          await _firestore
              .collection('icd_codes')
              .doc('icd10')
              .collection('codes')
              .doc(code.toUpperCase())
              .get();

      if (doc.exists) return true;

      // Check local data
      return icd10Codes.any((c) => c.code == code.toUpperCase());
    } catch (e) {
      return icd10Codes.any((c) => c.code == code.toUpperCase());
    }
  }

  // ============ GET ICD CODE DETAILS ============
  Future<ICDCode?> getICD10Details(String code) async {
    try {
      final doc =
          await _firestore
              .collection('icd_codes')
              .doc('icd10')
              .collection('codes')
              .doc(code.toUpperCase())
              .get();

      if (doc.exists) {
        return ICDCode.fromMap(doc.data() as Map<String, dynamic>);
      }

      // Check local data
      return icd10Codes.firstWhere(
        (c) => c.code == code.toUpperCase(),
        orElse: () => ICDCode(code: code, description: 'Code not found'),
      );
    } catch (e) {
      return icd10Codes.firstWhere(
        (c) => c.code == code.toUpperCase(),
        orElse: () => ICDCode(code: code, description: 'Code not found'),
      );
    }
  }

  // ============ SYNC MOCK DATA TO FIRESTORE ============
  Future<void> syncMockDataToFirestore() async {
    try {
      // Sync ICD-10
      for (var code in icd10Codes) {
        await _firestore
            .collection('icd_codes')
            .doc('icd10')
            .collection('codes')
            .doc(code.code)
            .set(code.toMap(), SetOptions(merge: true));
      }

      // Sync ICD-9-CM
      for (var code in icd9CMCodes) {
        await _firestore
            .collection('icd_codes')
            .doc('icd9cm')
            .collection('codes')
            .doc(code.code)
            .set(code.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      // Silently fail - will use mock data as fallback
    }
  }

  // ============ GET ALL ICD-10 CODES (for offline use) ============
  List<ICDCode> getAllICD10Codes() {
    return icd10Codes;
  }

  // ============ GET ALL ICD-9-CM CODES (for offline use) ============
  List<ICDCode> getAllICD9CMCodes() {
    return icd9CMCodes;
  }
}
