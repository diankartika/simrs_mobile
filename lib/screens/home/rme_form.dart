// lib/screens/home/rme_form.dart - FIXED VERSION
// Fixed: Notification message ke pengkodean (bukan audit langsung)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';

class RMEForm extends StatefulWidget {
  final QueueItem queueItem;
  final Patient patient;

  const RMEForm({super.key, required this.queueItem, required this.patient});

  @override
  State<RMEForm> createState() => _RMEFormState();
}

class _RMEFormState extends State<RMEForm> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanCtrl = TextEditingController();
  final _riwayatCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _terapiCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _keluhanCtrl.dispose();
    _riwayatCtrl.dispose();
    _diagnosisCtrl.dispose();
    _terapiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Save RME Form to Firestore
      final rmeFormData = {
        'queueItemId': widget.queueItem.id,
        'patientId': widget.patient.id,
        'keluhan': _keluhanCtrl.text,
        'riwayat': _riwayatCtrl.text,
        'diagnosis': _diagnosisCtrl.text,
        'terapi': _terapiCtrl.text,
        'doctorName': 'Dr. Budi Santoso',
        'createdAt': Timestamp.now(),
        'status': 'completed',
      };

      await FirebaseFirestore.instance.collection('rme_forms').add(rmeFormData);

      // Move queue to coding stage (NOT directly to audit!)
      await QueueService().moveToNextQueue(
        queueItemId: widget.queueItem.id,
        fromQueue: 'rme',
        toQueue: 'coding',
      );

      if (mounted) {
        // ✅ FIXED: Message now correctly says "pengkodean" not "audit"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data pasien berhasil disimpan dan dalam antrian pengkodean',
            ),
            backgroundColor: Color(0xFF00897B),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // ✅ FIXED: User-friendly error message (not raw exception)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan data'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rekam Medis Elektronik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PATIENT INFO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00897B), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('No. RM Pasien', widget.patient.rmNumber),
                    _buildInfoRow('Nama Pasien', widget.patient.name),
                    _buildInfoRow('Jenis Kelamin', widget.patient.gender),
                    _buildInfoRow('Usia', '${widget.patient.age} Tahun'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // KELUHAN UTAMA
              const Text(
                'Keluhan Utama',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keluhanCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan keluhan utama pasien',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keluhan utama harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // RIWAYAT PENYAKIT
              const Text(
                'Riwayat Penyakit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _riwayatCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan riwayat penyakit pasien',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Riwayat penyakit harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // DIAGNOSIS KLINIS
              const Text(
                'Diagnosis Klinis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan diagnosis klinis',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Diagnosis klinis harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // RENCANA TATALAKSANA / TERAPI
              const Text(
                'Rencana Tatalaksana / Terapi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _terapiCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan rencana tatalaksana atau terapi',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Terapi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Kirim ke Pengkodean',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
