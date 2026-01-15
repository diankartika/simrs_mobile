import 'package:cloud_firestore/cloud_firestore.dart';

class TerminologyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> mapICDToSNOMED({
    required String system,
    required String code,
  }) async {
    try {
      final query =
          await _db
              .collection('terminology_maps')
              .where('sourceSystem', isEqualTo: system)
              .where('sourceCode', isEqualTo: code)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        print('❌ NO SNOMED MAPPING FOUND for $system:$code');
        return null;
      }

      final data = query.docs.first.data();

      print('✅ SNOMED FOUND for $code → ${data['targetCode']}');

      return {
        'targetCode': data['targetCode'],
        'targetDisplay': data['targetDisplay'],
        'mapType': data['mapType'],
        'targetSystem': data['targetSystem'],
      };
    } catch (e) {
      print('🔥 TERMINOLOGY ERROR: $e');
      return null;
    }
  }
}
