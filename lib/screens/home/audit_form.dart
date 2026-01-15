// lib/screens/home/audit_form.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import '../../services/history_service.dart';

class AuditFormScreen extends StatefulWidget {
  final QueueItem queueItem;
  final Patient patient;

  const AuditFormScreen({
    super.key,
    required this.queueItem,
    required this.patient,
  });

  @override
  State<AuditFormScreen> createState() => _AuditFormScreenState();
}

class _AuditFormScreenState extends State<AuditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  late List<AuditChecklist> _checklist;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checklist = getDefaultAuditChecklist();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isComplete => _checklist.every((item) => item.isChecked);

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auditFormData = {
        'queueItemId': widget.queueItem.id,
        'patientId': widget.patient.id,
        'patientName': widget.patient.name,
        'checklist': _checklist.map((c) => c.toMap()).toList(),
        'notes': _notesCtrl.text,
        'auditorName': 'Auditor HIM',
        'createdAt': Timestamp.now(),
        'status': _isComplete ? 'completed' : 'incomplete',
      };

      await FirebaseFirestore.instance
          .collection('audit_forms')
          .add(auditFormData);

      // ✅ WAJIB: ADD HISTORY (PAKAI SERVICE)
      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        role: 'auditor',
        action: 'Validasi & Finalisasi Rekam Medis',
        status: 'approved',
      );

      // Complete queue
      await QueueService().completeQueueItem(widget.queueItem.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audit berhasil disimpan. Data selesai diproses!'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          'Audit Rekam Medis',
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
                    _buildInfoRow(
                      'Tgl. Encounter',
                      '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                    ),
                    _buildInfoRow('Status Dokumen', 'Lengkap'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CHECKLIST KELENGKAPAN
              const Text(
                'Checklist Kelengkapan Dokumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _checklist.length; i++)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _checklist[i].isChecked =
                                    !_checklist[i].isChecked;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _checklist[i].isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _checklist[i].isChecked =
                                            value ?? false;
                                      });
                                    },
                                    fillColor: WidgetStateProperty.all(
                                      _checklist[i].isChecked
                                          ? const Color(0xFF00897B)
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _checklist[i].item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        decoration:
                                            _checklist[i].isChecked
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _checklist[i].isChecked
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color:
                                        _checklist[i].isChecked
                                            ? const Color(0xFF00897B)
                                            : Colors.grey[400],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i < _checklist.length - 1)
                            Divider(height: 0, color: Colors.grey[300]),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // COMPLETION STATUS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isComplete ? Colors.green[50] : Colors.orange[50],
                  border: Border.all(
                    color: _isComplete ? Colors.green : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isComplete ? Icons.check_circle : Icons.info_outline,
                      color: _isComplete ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isComplete
                            ? 'Semua dokumen lengkap ✓'
                            : 'Masih ada dokumen yang belum lengkap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isComplete ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CATATAN AUDIT
              const Text(
                'Catatan Audit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan catatan audit (opsional)',
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
                  onPressed: (_isLoading || !_isComplete) ? null : _submitForm,
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
                            'Kirim Hasil Audit',
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
                        'Data pasien telah selesai di audit',
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

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
