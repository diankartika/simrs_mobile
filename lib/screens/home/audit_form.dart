import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/history_service.dart';

class AuditFormScreen extends StatefulWidget {
  final String codingFormId;
  final Patient patient;

  const AuditFormScreen({
    super.key,
    required this.codingFormId,
    required this.patient,
  });

  @override
  State<AuditFormScreen> createState() => _AuditFormScreenState();
}

class _AuditFormScreenState extends State<AuditFormScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _codingData;
  late List<AuditChecklist> _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = getDefaultAuditChecklist();
    _loadCodingForm();
  }

  Future<void> _loadCodingForm() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('coding_forms')
            .doc(widget.codingFormId)
            .get();

    if (doc.exists && mounted) {
      setState(() {
        _codingData = doc.data();
        _isLoading = false;
      });
    }
  }

  bool get _isComplete => _checklist.every((c) => c.isChecked);

  // ================= SUBMIT =================

  Future<void> _submitAudit() async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('coding_forms')
          .doc(widget.codingFormId)
          .update({
            'audit': {
              'checklist': _checklist.map((e) => e.toMap()).toList(),
              'auditedAt': Timestamp.now(),
              'auditor': 'Auditor HIM',
            },
            'status': _isComplete ? 'approved' : 'revision',
          });

      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        rmNumber: widget.patient.rmNumber,
        role: 'auditor',
        action:
            _isComplete
                ? 'Audit Pengkodean - Approved'
                : 'Audit Pengkodean - Revision',
        status: _isComplete ? 'approved' : 'revision',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isComplete
                ? 'Audit selesai & dokumen disetujui'
                : 'Audit selesai, perlu revisi coder',
          ),
          backgroundColor: const Color(0xFF00897B),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan audit: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audit Pengkodean Medis',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
                    const SizedBox(height: 24),
                    _codingReadOnlyCard(),
                    const SizedBox(height: 24),
                    _checklistSection(),
                    const SizedBox(height: 32),
                    _submitButton(),
                  ],
                ),
              ),
    );
  }

  // ================= SECTIONS =================

  Widget _patientCard() => _card(
    Column(
      children: [
        _row('No RM', widget.patient.rmNumber),
        _row('Nama', widget.patient.name),
        _row('Umur', '${widget.patient.age} tahun'),
        _row('Jenis Kelamin', widget.patient.gender),
      ],
    ),
  );

  Widget _codingReadOnlyCard() {
    final coding = _codingData?['coding'];

    final icd10 = coding?['icd10'];
    final icd9cm = coding?['icd9cm'];

    final snomedDx = coding?['snomedDiagnosis'];
    final snomedProc = coding?['snomedProcedure'];

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Pengkodean (Read-only)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ================= DIAGNOSIS =================
          const Text(
            'Diagnosis',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _codeRow('ICD-10', icd10),
          _codeRow(
            'SNOMED',
            snomedDx != null
                ? '${snomedDx['targetCode']} – ${snomedDx['targetDisplay']}'
                : '-',
          ),
          if (snomedDx != null) _codeRow('Map Type', snomedDx['mapType']),
          const Divider(),

          // ================= PROCEDURE =================
          const Text('Tindakan', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _codeRow('ICD-9-CM', icd9cm),
          _codeRow(
            'SNOMED',
            snomedProc != null
                ? '${snomedProc['targetCode']} – ${snomedProc['targetDisplay']}'
                : '-',
          ),
          if (snomedProc != null) _codeRow('Map Type', snomedProc['mapType']),
        ],
      ),
    );
  }

  Widget _checklistSection() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Checklist Audit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._checklist.map(
          (item) => CheckboxListTile(
            value: item.isChecked,
            onChanged: (v) => setState(() => item.isChecked = v ?? false),
            title: Text(item.item),
            activeColor: const Color(0xFF00897B),
          ),
        ),
      ],
    ),
  );

  Widget _submitButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: _isSubmitting ? null : _submitAudit,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B)),
      child:
          _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                _isComplete ? 'Setujui Dokumen' : 'Kirim Revisi',
                style: const TextStyle(fontSize: 16),
              ),
    ),
  );

  // ================= UTIL =================

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

  Widget _codeRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '$label: ${value ?? '-'}',
      style: const TextStyle(fontSize: 12),
    ),
  );
}
