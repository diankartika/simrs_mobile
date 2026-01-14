// lib/screens/home/pengkodean_form.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/icd_database_service.dart';
import '../../services/queue_service.dart';

class PengkodeanForm extends StatefulWidget {
  final QueueItem queueItem;
  final Patient patient;

  const PengkodeanForm({
    super.key,
    required this.queueItem,
    required this.patient,
  });

  @override
  State<PengkodeanForm> createState() => _PengkodeanFormState();
}

class _PengkodeanFormState extends State<PengkodeanForm> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _icd10SearchCtrl = TextEditingController();
  final _icd9CMSearchCtrl = TextEditingController();
  final _tindakanCtrl = TextEditingController();

  String _selectedICD10Code = '';
  String _selectedICD10Desc = '';
  String _selectedICD9CMCode = '';
  String _selectedICD9CMDesc = '';

  List<ICDCode> _icd10Results = [];
  List<ICDCode> _icd9CMResults = [];
  bool _isLoading = false;
  bool _isSearchingICD10 = false;
  bool _isSearchingICD9CM = false;

  final icdService = ICDDatabaseService();

  Future<void> _searchICD10(String query) async {
    if (query.isEmpty) {
      setState(() => _icd10Results = []);
      return;
    }

    setState(() => _isSearchingICD10 = true);

    try {
      final results = await icdService.searchICD10(query);

      if (!mounted) return;
      setState(() => _icd10Results = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (!mounted) return;
    setState(() => _isSearchingICD10 = false);
  }

  Future<void> _searchICD9CM(String query) async {
    if (query.isEmpty) {
      setState(() => _icd9CMResults = []);
      return;
    }

    if (!mounted) return;

    setState(() => _isSearchingICD9CM = true);

    try {
      final results = await icdService.searchICD9CM(query);

      if (!mounted) return;
      setState(() => _icd9CMResults = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (!mounted) return;
    setState(() => _isSearchingICD9CM = false);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedICD10Code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kode ICD-10')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save Coding Form to Firestore
      final codingFormData = {
        'queueItemId': widget.queueItem.id,
        'patientId': widget.patient.id,
        'diagnosisKlinis': _diagnosisCtrl.text,
        'icd10Code': _selectedICD10Code,
        'icd10Description': _selectedICD10Desc,
        'icd9CMCode': _selectedICD9CMCode,
        'icd9CMDescription': _selectedICD9CMDesc,
        'tindakan': _tindakanCtrl.text,
        'coderName': 'HIM Coder',
        'createdAt': Timestamp.now(),
        'status': 'completed',
      };

      await FirebaseFirestore.instance
          .collection('coding_forms')
          .add(codingFormData);

      // Move queue to audit
      await QueueService().moveToNextQueue(
        queueItemId: widget.queueItem.id,
        fromQueue: 'coding',
        toQueue: 'audit',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengkodean berhasil disimpan dan dikirim ke Auditor',
            ),
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
  void dispose() {
    _diagnosisCtrl.dispose();
    _icd10SearchCtrl.dispose();
    _icd9CMSearchCtrl.dispose();
    _tindakanCtrl.dispose();
    super.dispose();
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
          'Pengkodean ICD',
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
                    _buildInfoRow('Status', 'Pending Coding'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                validator:
                    (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
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
              ),
              const SizedBox(height: 24),

              // ICD-10 CODE SELECTION
              const Text(
                'Kode ICD-10 (Diagnosis Utama)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _icd10SearchCtrl,
                onChanged: _searchICD10,
                decoration: InputDecoration(
                  hintText: 'Cari kode ICD-10 (misal: J11, influenza)',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00897B),
                  ),
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
              const SizedBox(height: 12),

              // ICD-10 RESULTS
              if (_isSearchingICD10)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00897B),
                    ),
                  ),
                )
              else if (_icd10Results.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children:
                        _icd10Results
                            .map(
                              (code) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedICD10Code = code.code;
                                    _selectedICD10Desc = code.description;
                                    _icd10SearchCtrl.clear();
                                    _icd10Results = [];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        code.code,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        code.description,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),

              // SELECTED ICD-10
              if (_selectedICD10Code.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      border: Border.all(color: const Color(0xFF00897B)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode ICD-10 Terpilih:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_selectedICD10Code - $_selectedICD10Desc',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // ICD-9-CM CODE SELECTION (Optional)
              const Text(
                'Kode ICD-9-CM (Prosedur/Tindakan) - Optional',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _icd9CMSearchCtrl,
                onChanged: _searchICD9CM,
                decoration: InputDecoration(
                  hintText: 'Cari kode ICD-9-CM (misal: 99.04)',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00897B),
                  ),
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
              const SizedBox(height: 12),

              // ICD-9-CM RESULTS
              if (_isSearchingICD9CM)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00897B),
                    ),
                  ),
                )
              else if (_icd9CMResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children:
                        _icd9CMResults
                            .map(
                              (code) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedICD9CMCode = code.code;
                                    _selectedICD9CMDesc = code.description;
                                    _icd9CMSearchCtrl.clear();
                                    _icd9CMResults = [];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        code.code,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        code.description,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),

              // SELECTED ICD-9-CM
              if (_selectedICD9CMCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      border: Border.all(color: const Color(0xFF00897B)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode ICD-9-CM Terpilih:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_selectedICD9CMCode - $_selectedICD9CMDesc',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // TINDAKAN / PROCEDURE
              const Text(
                'Tindakan / Prosedur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tindakanCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan tindakan / prosedur (opsional)',
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
                            'Kirim ke Auditor',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // INFO MESSAGE
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
                        'Pengkodean berhasil disimpan dan dalam antrian Auditor',
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
