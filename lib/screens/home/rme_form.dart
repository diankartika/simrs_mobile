// lib/screens/home/rme_form.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import '../../services/history_service.dart';

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

  // ================= SUBMIT RME =================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ SAVE RME
      await FirebaseFirestore.instance.collection('rme_forms').add({
        'queueItemId': widget.queueItem.id,
        'patientId': widget.patient.id,
        'patientName': widget.patient.name,
        'keluhan': _keluhanCtrl.text,
        'riwayat': _riwayatCtrl.text,
        'diagnosis': _diagnosisCtrl.text,
        'terapi': _terapiCtrl.text,
        'doctorName': 'Dokter',
        'createdAt': Timestamp.now(),
        'status': 'completed',
      });

      // 2️⃣ HISTORY
      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        rmNumber: widget.patient.rmNumber, // 🔑 WAJIB
        role: 'doctor',
        action: 'Mengisi Rekam Medis Elektronik',
        status: 'completed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data pasien berhasil disimpan dan masuk antrian coder',
            ),
            backgroundColor: Color(0xFF00897B),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan RME'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekam Medis Elektronik'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _patientInfo(),
              const SizedBox(height: 24),
              _inputField('Keluhan Utama', _keluhanCtrl),
              _inputField('Riwayat Penyakit', _riwayatCtrl),
              _inputField('Diagnosis Dokter', _diagnosisCtrl),
              _inputField('Terapi / Tindakan', _terapiCtrl),
              const SizedBox(height: 32),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================
  Widget _patientInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _infoRow('No RM', widget.patient.rmNumber),
          _infoRow('Nama', widget.patient.name),
          _infoRow('JK', widget.patient.gender),
          _infoRow('Usia', '${widget.patient.age} Tahun'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(),
          ),
          validator:
              (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Kirim ke Coder'),
      ),
    );
  }
}
