import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/history_service.dart';

class PengkodeanForm extends StatefulWidget {
  final String rmeFormId;
  final Patient patient;

  const PengkodeanForm({
    super.key,
    required this.rmeFormId,
    required this.patient,
  });

  @override
  State<PengkodeanForm> createState() => _PengkodeanFormState();
}

class _PengkodeanFormState extends State<PengkodeanForm> {
  final _notesCtrl = TextEditingController();
  final _icd10Ctrl = TextEditingController();
  final _icd9Ctrl = TextEditingController();

  bool _isSubmitting = false;
  Map<String, dynamic>? _rmeData;

  @override
  void initState() {
    super.initState();
    _loadRME();
  }

  Future<void> _loadRME() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('rme_forms')
            .doc(widget.rmeFormId)
            .get();

    if (doc.exists && mounted) {
      setState(() => _rmeData = doc.data());
    }
  }

  Future<void> _submitCoding() async {
    if (_icd10Ctrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kode ICD-10 wajib diisi')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('coding_forms').add({
        'rmeFormId': widget.rmeFormId,
        'patientId': widget.patient.id,
        'rmNumber': widget.patient.rmNumber,
        'patientName': widget.patient.name,

        // READ ONLY FROM RME
        'clinicalDiagnosis': _rmeData!['diagnosis'],
        'keluhan': _rmeData!['keluhan'],
        'terapi': _rmeData!['terapi'],

        // ICD CODING (CORE CAPSTONE)
        'icd10': _icd10Ctrl.text,
        'icd9cm': _icd9Ctrl.text,

        'catatanCoder': _notesCtrl.text,
        'status': 'submitted',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('rme_forms')
          .doc(widget.rmeFormId)
          .update({'status': 'coded'});

      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        role: 'coder',
        action: 'Melakukan pengkodean ICD',
        status: 'submitted',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengkodean berhasil dikirim ke audit'),
          backgroundColor: Color(0xFF00897B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengkodean Medis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _rmeData == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoCard(),
                    const SizedBox(height: 16),
                    _rmeCard(),
                    const SizedBox(height: 16),
                    _icdSection(),
                    const SizedBox(height: 16),
                    _notesSection(),
                    const SizedBox(height: 24),
                    _submitButton(),
                  ],
                ),
              ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _infoCard() {
    return _card(
      Column(
        children: [
          _row('No RM', widget.patient.rmNumber),
          _row('Nama', widget.patient.name),
          _row('Umur', '${widget.patient.age} tahun'),
          _row('Jenis Kelamin', widget.patient.gender),
        ],
      ),
    );
  }

  Widget _rmeCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnosis Dokter (Read Only)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Keluhan: ${_rmeData!['keluhan']}'),
          Text('Diagnosis: ${_rmeData!['diagnosis']}'),
          Text('Terapi: ${_rmeData!['terapi']}'),
        ],
      ),
    );
  }

  Widget _icdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengkodean ICD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _icd10Ctrl,
          decoration: const InputDecoration(
            labelText: 'ICD-10 (Diagnosis)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _icd9Ctrl,
          decoration: const InputDecoration(
            labelText: 'ICD-9-CM (Tindakan)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _notesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catatan Pengkodean'),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Tambahkan catatan coder...',
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitCoding,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
        ),
        child:
            _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Kirim ke Audit', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l), Text(v)],
      ),
    );
  }
}
