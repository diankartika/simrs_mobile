import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/history_service.dart';
import '../../services/terminology_service.dart';

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
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _rmeData;

  // Controllers
  final _icd10Ctrl = TextEditingController();
  final _icd9cmCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // ICD values
  String? _icd10Code;
  String? _icd9cmCode;

  // SNOMED result
  Map<String, dynamic>? _snomedDiagnosis;
  Map<String, dynamic>? _snomedProcedure;

  @override
  void initState() {
    super.initState();
    _loadRME();
  }

  @override
  void dispose() {
    _icd10Ctrl.dispose();
    _icd9cmCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD RME =================

  Future<void> _loadRME() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('rme_forms')
            .doc(widget.rmeFormId)
            .get();

    if (doc.exists && mounted) {
      setState(() {
        _rmeData = doc.data();
        _isLoading = false;
      });
    }
  }

  // ================= ICD → SNOMED =================

  Future<void> _mapICD10(String value) async {
    final code = value.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _icd10Code = null;
        _snomedDiagnosis = null;
      });
      return;
    }

    _icd10Code = code;

    final result = await TerminologyService.mapICDToSNOMED(
      system: 'ICD-10',
      code: value,
    );

    debugPrint('SNOMED RESULT FOR $value => $result');

    if (mounted) {
      setState(() {
        _snomedDiagnosis = result;
      });
    }
  }

  Future<void> _mapICD9CM(String value) async {
    final code = value.trim();
    if (code.isEmpty) {
      setState(() {
        _icd9cmCode = null;
        _snomedProcedure = null;
      });
      return;
    }

    _icd9cmCode = code;

    final result = await TerminologyService.mapICDToSNOMED(
      system: 'ICD-9-CM',
      code: code,
    );

    // 🔍 DEBUG WAJIB
    debugPrint('SNOMED ICD-9-CM RESULT: $result');

    if (mounted) {
      setState(() {
        _snomedProcedure = result;
      });
    }
  }

  // ================= SUBMIT =================

  Future<void> _submitCoding() async {
    if (_icd10Code == null && _icd9cmCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minimal satu kode ICD')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('coding_forms').add({
        'rmeFormId': widget.rmeFormId,
        'patientId': widget.patient.id,
        'rmNumber': widget.patient.rmNumber,
        'patientName': widget.patient.name,

        'doctorSummary': {
          'keluhan': _rmeData?['keluhan'] ?? '',
          'diagnosis': _rmeData?['diagnosis'] ?? '',
          'terapi': _rmeData?['terapi'] ?? '',
        },

        'coding': {
          'icd10': _icd10Code,
          'icd9cm': _icd9cmCode,
          'snomedDiagnosis': _snomedDiagnosis,
          'snomedProcedure': _snomedProcedure,
        },

        'notes': _notesCtrl.text,
        'status': 'submitted',
        'createdAt': Timestamp.now(),
      });

      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        rmNumber: widget.patient.rmNumber,
        role: 'coder',
        action: 'Pengkodean Medis (ICD → SNOMED)',
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

  // ================= UI =================

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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _patientCard(),
                    const SizedBox(height: 16),
                    _rmeSummary(),
                    const SizedBox(height: 24),
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

  Widget _patientCard() {
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

  Widget _rmeSummary() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan RME Dokter',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Keluhan: ${_rmeData?['keluhan'] ?? '-'}'),
          Text('Diagnosis: ${_rmeData?['diagnosis'] ?? '-'}'),
          Text('Terapi: ${_rmeData?['terapi'] ?? '-'}'),
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
        const SizedBox(height: 12),

        TextField(
          controller: _icd10Ctrl,
          decoration: const InputDecoration(
            labelText: 'ICD-10 Diagnosis',
            border: OutlineInputBorder(),
          ),
          onChanged: _mapICD10,
        ),
        if (_snomedDiagnosis != null) _snomedBox(_snomedDiagnosis!),

        const SizedBox(height: 16),

        TextField(
          controller: _icd9cmCtrl,
          decoration: const InputDecoration(
            labelText: 'ICD-9-CM Tindakan',
            border: OutlineInputBorder(),
          ),
          onChanged: _mapICD9CM,
        ),
        if (_snomedProcedure != null) _snomedBox(_snomedProcedure!),
      ],
    );
  }

  Widget _snomedBox(Map<String, dynamic> snomed) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SNOMED CT (Auto Mapping)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${snomed['targetCode']} - ${snomed['targetDisplay']}'),
          Text(
            'Map Type: ${snomed['mapType']}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _notesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catatan Coder'),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Opsional',
            border: OutlineInputBorder(),
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

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF00897B)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(l), Text(v)],
    ),
  );
}
