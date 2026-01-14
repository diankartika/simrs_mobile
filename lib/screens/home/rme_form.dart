// lib/screens/home/rme_form.dart

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
  final _obatCtrl = TextEditingController();
  final _hasilPemeriksaanCtrl = TextEditingController();

  final List<String> _obatList = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _keluhanCtrl.dispose();
    _riwayatCtrl.dispose();
    _diagnosisCtrl.dispose();
    _terapiCtrl.dispose();
    _obatCtrl.dispose();
    _hasilPemeriksaanCtrl.dispose();
    super.dispose();
  }

  void _addObat() {
    if (_obatCtrl.text.isNotEmpty) {
      setState(() {
        _obatList.add(_obatCtrl.text);
        _obatCtrl.clear();
      });
    }
  }

  void _removeObat(int index) {
    setState(() {
      _obatList.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Save RME Form to Firestore
      final rmeFormData = {
        'patientId': widget.patient.id,
        'queueItemId': widget.queueItem.id,
        'keluhanUtama': _keluhanCtrl.text,
        'riwayatPenyakit': _riwayatCtrl.text,
        'diagnosisDokter': _diagnosisCtrl.text,
        'terapi': _terapiCtrl.text,
        'obat': _obatList,
        'hasilPemeriksaan': _hasilPemeriksaanCtrl.text,
        'doctorName': 'Dr. Budi',
        'createdAt': Timestamp.now(),
        'status': 'completed',
      };

      await FirebaseFirestore.instance.collection('rme_forms').add(rmeFormData);

      // Move queue to coding
      await QueueService().moveToNextQueue(
        queueItemId: widget.queueItem.id,
        fromQueue: 'rme',
        toQueue: 'coding',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RME berhasil disimpan dan dikirim ke Coder'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    _buildInfoRow('Usia', '${widget.patient.age} Tahun'),
                    _buildInfoRow('Jenis Kelamin', widget.patient.gender),
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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
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
              ),
              const SizedBox(height: 16),

              // DIAGNOSIS DOKTER
              const Text(
                'Diagnosis Dokter',
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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan diagnosis dokter',
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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan rencana tatalaksana',
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
              ),
              const SizedBox(height: 16),

              // OBAT / MEDICATION
              const Text(
                'Obat / Medication',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _obatCtrl,
                      decoration: InputDecoration(
                        hintText: 'Nama obat',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addObat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Tambah',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_obatList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Obat:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < _obatList.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _obatList[i],
                                style: const TextStyle(fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () => _removeObat(i),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // HASIL PEMERIKSAAN PENUNJANG
              const Text(
                'Hasil Pemeriksaan Penunjang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hasilPemeriksaanCtrl,
                maxLines: 3,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan hasil pemeriksaan penunjang',
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
                            'Kirim ke Coder',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // SUCCESS MESSAGE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal[700], size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Data RME berhasil disimpan dan dalam antrian Coder',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
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
