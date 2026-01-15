import 'package:cloud_firestore/cloud_firestore.dart';

class TerminologyService {
  static Future<Map<String, dynamic>?> mapICDToSNOMED({
    required String system, // ICD-10 / ICD-9-CM
    required String code,
  }) async {
    final docId =
        system == 'ICD-10'
            ? 'icd10_${code.replaceAll('.', '_')}'
            : 'icd9cm_${code.replaceAll('.', '_')}';

    final doc =
        await FirebaseFirestore.instance
            .collection('terminology_map')
            .doc(docId)
            .get();

    return doc.exists ? doc.data() : null;
  }
}
