// lib/services/queue_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Queue System Flow:
/// 1. Admin: Registrasi Pasien → Create Patient
/// 2. Doctor: Fill RME → RME in "awaiting_coding" queue
/// 3. Coder: Code ICD-10 & ICD-9 → Coding in "awaiting_audit" queue
/// 4. Auditor: Validate & Complete → Mark as "completed"

class QueueItem {
  final String id;
  final String patientId;
  final String patientName;
  final String rmNumber;
  final String currentQueue; // registration, rme, coding, audit, completed
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata; // extra data

  QueueItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.rmNumber,
    required this.currentQueue,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'rmNumber': rmNumber,
      'currentQueue': currentQueue,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }

  factory QueueItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QueueItem(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      rmNumber: data['rmNumber'] ?? '',
      currentQueue: data['currentQueue'] ?? 'registration',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
      metadata: data['metadata'] ?? {},
    );
  }
}

class QueueService {
  static final QueueService _instance = QueueService._internal();

  factory QueueService() {
    return _instance;
  }

  QueueService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ CREATE QUEUE ITEM (After Registration) ============
  Future<void> createQueueItem({
    required String patientId,
    required String patientName,
    required String rmNumber,
  }) async {
    try {
      await _firestore
          .collection('queues')
          .add(
            QueueItem(
              id: '',
              patientId: patientId,
              patientName: patientName,
              rmNumber: rmNumber,
              currentQueue: 'rme', // After registration, goes to RME queue
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
    } catch (e) {
      rethrow;
    }
  }

  // ============ GET DOCTOR'S RME QUEUE ============
  Stream<List<QueueItem>> getDoctorRMEQueue() {
    return _firestore
        .collection('queues')
        .where('currentQueue', isEqualTo: 'rme')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // ============ GET CODER'S CODING QUEUE ============
  Stream<List<QueueItem>> getCoderCodingQueue() {
    return _firestore
        .collection('queues')
        .where('currentQueue', isEqualTo: 'coding')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // ============ GET AUDITOR'S AUDIT QUEUE ============
  Stream<List<QueueItem>> getAuditorAuditQueue() {
    return _firestore
        .collection('queues')
        .where('currentQueue', isEqualTo: 'audit')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // ============ MOVE TO NEXT QUEUE ============
  Future<void> moveToNextQueue({
    required String queueItemId,
    required String fromQueue,
    required String toQueue,
  }) async {
    try {
      await _firestore.collection('queues').doc(queueItemId).update({
        'currentQueue': toQueue,
        'metadata.movedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============ COMPLETE QUEUE ITEM ============
  Future<void> completeQueueItem(String queueItemId) async {
    try {
      await _firestore.collection('queues').doc(queueItemId).update({
        'currentQueue': 'completed',
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============ GET COMPLETED ITEMS (for archive/reporting) ============
  Stream<List<QueueItem>> getCompletedItems() {
    return _firestore
        .collection('queues')
        .where('currentQueue', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // ============ GET QUEUE STATISTICS (for dashboard) ============
  Future<Map<String, int>> getQueueStats() async {
    try {
      final rmeCount =
          await _firestore
              .collection('queues')
              .where('currentQueue', isEqualTo: 'rme')
              .count()
              .get();

      final codingCount =
          await _firestore
              .collection('queues')
              .where('currentQueue', isEqualTo: 'coding')
              .count()
              .get();

      final auditCount =
          await _firestore
              .collection('queues')
              .where('currentQueue', isEqualTo: 'audit')
              .count()
              .get();

      return <String, int>{
        'rme': rmeCount.count ?? 0,
        'coding': codingCount.count ?? 0,
        'audit': auditCount.count ?? 0,
      };
    } catch (e) {
      return <String, int>{'rme': 0, 'coding': 0, 'audit': 0};
    }
  }

  // ============ SEARCH PATIENT IN QUEUE ============
  Future<QueueItem?> searchPatientInQueue(String rmNumber) async {
    try {
      final snapshot =
          await _firestore
              .collection('queues')
              .where('rmNumber', isEqualTo: rmNumber)
              .where('currentQueue', isNotEqualTo: 'completed')
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return QueueItem.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ GET QUEUE ITEM BY ID ============
  Future<QueueItem?> getQueueItemById(String queueItemId) async {
    try {
      final doc = await _firestore.collection('queues').doc(queueItemId).get();
      if (doc.exists) {
        return QueueItem.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
