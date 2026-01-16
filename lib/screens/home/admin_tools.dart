// lib/screens/home/admin_tools.dart
// FINAL VERSION - MANUAL SEED ONLY (BEST PRACTICE)

import 'package:flutter/material.dart';

import '../../services/icd_database_service.dart';
import '../../services/firestore_seed_real_data.dart';
import '../../services/import_service.dart';

class AdminTools extends StatelessWidget {
  const AdminTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _toolButton(
              context,
              title: 'Seed ICD Codes',
              subtitle: 'Import ICD-10 & ICD-9-CM ke Firestore',
              action: () async {
                await ICDDatabaseService().syncMockDataToFirestore();
              },
            ),
            _toolButton(
              context,
              title: 'Seed Patient Data',
              subtitle: 'Import data pasien dummy',
              action: () async {
                await FirestoreSeedRealData.seedRealData();
              },
            ),
            _toolButton(
              context,
              title: 'Import Study Cases',
              subtitle: 'Import kasus studi (RME + coding)',
              action: () async {
                await ImportService().importAllStudyCases();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Future<void> Function() action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        onPressed: () async {
          try {
            await action();
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$title berhasil')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
            }
          }
        },
        child: Row(
          children: [
            const Icon(Icons.build),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
