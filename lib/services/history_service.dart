import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> add({
    required String patientId,
    required String patientName,
    required String rmNumber, // ✅ WAJIB ADA
    required String role,
    required String action,
    required String status,
  }) async {
    await _db.collection('histories').add({
      'patientId': patientId,
      'patientName': patientName,
      'rmNumber': rmNumber, // ✅ DISIMPAN
      'role': role,
      'action': action,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
