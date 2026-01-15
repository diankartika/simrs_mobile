// lib/screens/home/pengkodean_form.dart - COMPLETE WORKING VERSION
// ✅ Full diagnosis + procedure coding with ICD-10, ICD-9-CM, and SNOMED CT

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';
import '../../services/queue_service.dart';
import '../../services/history_service.dart';

// Models for coding data
class DiagnosisCoding {
  final String clinicalDiagnosis;
  final String icd10Code;
  final String icd10Display;
  final String? snomedctCode;
  final String? snomedctDisplay;
  final String status; // pending, validated

  DiagnosisCoding({
    required this.clinicalDiagnosis,
    required this.icd10Code,
    required this.icd10Display,
    this.snomedctCode,
    this.snomedctDisplay,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'clinicalDiagnosis': clinicalDiagnosis,
    'icd10Code': icd10Code,
    'icd10Display': icd10Display,
    'snomedctCode': snomedctCode ?? '',
    'snomedctDisplay': snomedctDisplay ?? '',
    'status': status,
  };
}

class ProcedureCoding {
  final String procedureName;
  final String icd9cmCode;
  final String icd9cmDisplay;
  final String? snomedctCode;
  final String? snomedctDisplay;
  final String status; // pending, validated

  ProcedureCoding({
    required this.procedureName,
    required this.icd9cmCode,
    required this.icd9cmDisplay,
    this.snomedctCode,
    this.snomedctDisplay,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'procedureName': procedureName,
    'icd9cmCode': icd9cmCode,
    'icd9cmDisplay': icd9cmDisplay,
    'snomedctCode': snomedctCode ?? '',
    'snomedctDisplay': snomedctDisplay ?? '',
    'status': status,
  };
}

// Reference data
class ICDCode {
  final String code;
  final String display;
  final String? snomedctMapping;

  ICDCode({required this.code, required this.display, this.snomedctMapping});
}

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
  final _procedureCtrl = TextEditingController();
  final _icd9cmSearchCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<DiagnosisCoding> _diagnoses = [];
  List<ProcedureCoding> _procedures = [];

  List<ICDCode> _icd10Results = [];
  List<ICDCode> _icd9cmResults = [];

  bool _isLoadingDiagnosis = false;
  bool _isLoadingProcedure = false;
  bool _isSubmitting = false;

  // Sample ICD-10 data (in production, load from Firestore)
  final Map<String, ICDCode> _icd10Database = {
    'A00': ICDCode(
      code: 'A00',
      display: 'Cholera',
      snomedctMapping: '63650001',
    ),
    'A01': ICDCode(
      code: 'A01',
      display: 'Typhoid and paratyphoid fevers',
      snomedctMapping: '80801009',
    ),
    'A15': ICDCode(
      code: 'A15',
      display: 'Respiratory tuberculosis, unconfirmed',
      snomedctMapping: '399123001',
    ),
    'B20': ICDCode(
      code: 'B20',
      display: 'Human immunodeficiency virus (HIV) disease',
      snomedctMapping: '19030005',
    ),
    'C20': ICDCode(
      code: 'C20',
      display: 'Malignant neoplasm of rectum',
      snomedctMapping: '254662008',
    ),
    'C78.1': ICDCode(
      code: 'C78.1',
      display: 'Secondary malignant neoplasm of lung',
      snomedctMapping: '94564001',
    ),
    'E10': ICDCode(
      code: 'E10',
      display: 'Type 1 diabetes mellitus',
      snomedctMapping: '46635009',
    ),
    'E11': ICDCode(
      code: 'E11',
      display: 'Type 2 diabetes mellitus',
      snomedctMapping: '44054006',
    ),
    'I10': ICDCode(
      code: 'I10',
      display: 'Essential (primary) hypertension',
      snomedctMapping: '59621000',
    ),
    'J06.9': ICDCode(
      code: 'J06.9',
      display: 'Acute upper respiratory infection, unspecified',
      snomedctMapping: '54150009',
    ),
    'J18.9': ICDCode(
      code: 'J18.9',
      display: 'Pneumonia, unspecified',
      snomedctMapping: '68154008',
    ),
    'K35.8': ICDCode(
      code: 'K35.8',
      display: 'Appendicitis, unspecified',
      snomedctMapping: '74400008',
    ),
    'N39.0': ICDCode(
      code: 'N39.0',
      display: 'Urinary tract infection, site not specified',
      snomedctMapping: '68566005',
    ),
    'O13': ICDCode(
      code: 'O13',
      display: 'Gestational hypertension',
      snomedctMapping: '49218002',
    ),
  };

  // Sample ICD-9-CM data
  final Map<String, ICDCode> _icd9cmDatabase = {
    '88.39': ICDCode(
      code: '88.39',
      display: 'Diagnostic ultrasound of extremities',
      snomedctMapping: '396538006',
    ),
    '89.37': ICDCode(
      code: '89.37',
      display: 'Electrocardiogram',
      snomedctMapping: '29303009',
    ),
    '90.14': ICDCode(
      code: '90.14',
      display: 'Chest X-ray',
      snomedctMapping: '168537006',
    ),
    '92.27': ICDCode(
      code: '92.27',
      display: 'Therapeutic drug injection',
      snomedctMapping: '6078001',
    ),
    '96.04': ICDCode(
      code: '96.04',
      display: 'Insertion of endotracheal tube',
      snomedctMapping: '6145007',
    ),
    '96.57': ICDCode(
      code: '96.57',
      display: 'Oxygen therapy (breathing apparatus)',
      snomedctMapping: '57485005',
    ),
    '99.02': ICDCode(
      code: '99.02',
      display: 'Transfusion of packed cells',
      snomedctMapping: '86891008',
    ),
    '99.04': ICDCode(
      code: '99.04',
      display: 'Transfusion of platelets',
      snomedctMapping: '5971006',
    ),
    '99.05': ICDCode(
      code: '99.05',
      display: 'Transfusion of coagulation factors',
      snomedctMapping: '243026004',
    ),
    '99.15': ICDCode(
      code: '99.15',
      display: 'Parenteral infusion of nutrients',
      snomedctMapping: '71388002',
    ),
  };

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _icd10SearchCtrl.dispose();
    _procedureCtrl.dispose();
    _icd9cmSearchCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Search ICD-10 codes
  Future<void> _searchICD10(String query) async {
    if (query.isEmpty) {
      setState(() => _icd10Results = []);
      return;
    }

    setState(() => _isLoadingDiagnosis = true);

    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Simulate network delay

      final results =
          _icd10Database.values
              .where(
                (code) =>
                    code.code.toUpperCase().contains(query.toUpperCase()) ||
                    code.display.toUpperCase().contains(query.toUpperCase()),
              )
              .toList();

      if (mounted) {
        setState(() => _icd10Results = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDiagnosis = false);
      }
    }
  }

  // Search ICD-9-CM codes
  Future<void> _searchICD9CM(String query) async {
    if (query.isEmpty) {
      setState(() => _icd9cmResults = []);
      return;
    }

    setState(() => _isLoadingProcedure = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final results =
          _icd9cmDatabase.values
              .where(
                (code) =>
                    code.code.contains(query) ||
                    code.display.toUpperCase().contains(query.toUpperCase()),
              )
              .toList();

      if (mounted) {
        setState(() => _icd9cmResults = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProcedure = false);
      }
    }
  }

  void _addDiagnosis(ICDCode code) {
    setState(() {
      _diagnoses.add(
        DiagnosisCoding(
          clinicalDiagnosis: _diagnosisCtrl.text,
          icd10Code: code.code,
          icd10Display: code.display,
          snomedctCode: code.snomedctMapping,
          snomedctDisplay: code.snomedctMapping,
        ),
      );
      _diagnosisCtrl.clear();
      _icd10SearchCtrl.clear();
      _icd10Results.clear();
    });
  }

  void _addProcedure(ICDCode code) {
    setState(() {
      _procedures.add(
        ProcedureCoding(
          procedureName: _procedureCtrl.text,
          icd9cmCode: code.code,
          icd9cmDisplay: code.display,
          snomedctCode: code.snomedctMapping,
          snomedctDisplay: code.snomedctMapping,
        ),
      );
      _procedureCtrl.clear();
      _icd9cmSearchCtrl.clear();
      _icd9cmResults.clear();
    });
  }

  Future<void> _submitCoding() async {
    if (_diagnoses.isEmpty && _procedures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 diagnosis atau tindakan'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Save coding to Firestore
      final codingData = {
        'patientId': widget.patient.id,
        'rmNumber': widget.patient.rmNumber,
        'patientName': widget.patient.name,
        'diagnoses': _diagnoses.map((d) => d.toMap()).toList(),
        'procedures': _procedures.map((p) => p.toMap()).toList(),
        'notes': _notesCtrl.text,
        'codingStatus': 'submitted',
        'codedBy': 'Current User ID', // Replace with actual user ID from auth
        'codedDate': Timestamp.now(),
        'visitDate': DateTime.now(),
      };

      // Save to Firestore in /patients/{patientId}/coding/{codingId}
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patient.id)
          .collection('coding')
          .add(codingData);

      // Update queue status
      await QueueService().completeQueueItem(widget.queueItem.id);

      await HistoryService.add(
        patientId: widget.patient.id,
        patientName: widget.patient.name,
        role: 'coder',
        action: 'Pengkodean Diagnosis & Tindakan',
        status: 'submitted',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengkodean berhasil disimpan'),
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
      setState(() => _isSubmitting = false);
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
          'Pengkodean Medis',
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
              // Patient Info Section
              _buildPatientInfoCard(),
              const SizedBox(height: 24),

              // Diagnosis Coding Section
              _buildDiagnosisSection(),
              const SizedBox(height: 24),

              // Procedure Coding Section
              _buildProcedureSection(),
              const SizedBox(height: 24),

              // Notes Section
              _buildNotesSection(),
              const SizedBox(height: 24),

              // Summary Section
              _buildSummarySection(),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCoding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                  ),
                  child:
                      _isSubmitting
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
                            'Kirim Pengkodean',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('No. RM', widget.patient.rmNumber),
          const SizedBox(height: 8),
          _buildInfoRow('Nama Pasien', widget.patient.name),
          const SizedBox(height: 8),
          _buildInfoRow('Umur', '${widget.patient.age} tahun'),
          const SizedBox(height: 8),
          _buildInfoRow('Jenis Kelamin', widget.patient.gender),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengkodean Diagnosis (ICD-10)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        // Diagnosis input
        TextField(
          controller: _diagnosisCtrl,
          decoration: InputDecoration(
            labelText: 'Diagnosis Klinis',
            hintText: 'Ketik diagnosis...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.medical_information),
          ),
        ),
        const SizedBox(height: 12),

        // ICD-10 search
        TextField(
          controller: _icd10SearchCtrl,
          decoration: InputDecoration(
            labelText: 'Cari Kode ICD-10',
            hintText: 'Ketik kode atau nama diagnosis...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon:
                _isLoadingDiagnosis
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.search),
          ),
          onChanged: (value) => _searchICD10(value),
        ),
        const SizedBox(height: 8),

        // ICD-10 suggestions
        if (_icd10Results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _icd10Results.length,
              itemBuilder: (context, index) {
                final code = _icd10Results[index];
                return ListTile(
                  title: Text('${code.code}: ${code.display}'),
                  onTap: () => _addDiagnosis(code),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        // Added diagnoses list
        if (_diagnoses.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnosis yang ditambahkan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._diagnoses.asMap().entries.map((entry) {
                final idx = entry.key;
                final diag = entry.value;
                return Dismissible(
                  key: Key('diag-$idx'),
                  onDismissed: (_) {
                    setState(() => _diagnoses.removeAt(idx));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diag.clinicalDiagnosis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ICD-10: ${diag.icd10Code} - ${diag.icd10Display}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (diag.snomedctCode != null &&
                              diag.snomedctCode!.isNotEmpty)
                            Text(
                              'SNOMED CT: ${diag.snomedctCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildProcedureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengkodean Tindakan (ICD-9-CM)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        // Procedure input
        TextField(
          controller: _procedureCtrl,
          decoration: InputDecoration(
            labelText: 'Nama Tindakan',
            hintText: 'Ketik tindakan medis...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.healing),
          ),
        ),
        const SizedBox(height: 12),

        // ICD-9-CM search
        TextField(
          controller: _icd9cmSearchCtrl,
          decoration: InputDecoration(
            labelText: 'Cari Kode ICD-9-CM',
            hintText: 'Ketik kode atau nama tindakan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon:
                _isLoadingProcedure
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.search),
          ),
          onChanged: (value) => _searchICD9CM(value),
        ),
        const SizedBox(height: 8),

        // ICD-9-CM suggestions
        if (_icd9cmResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _icd9cmResults.length,
              itemBuilder: (context, index) {
                final code = _icd9cmResults[index];
                return ListTile(
                  title: Text('${code.code}: ${code.display}'),
                  onTap: () => _addProcedure(code),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        // Added procedures list
        if (_procedures.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tindakan yang ditambahkan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._procedures.asMap().entries.map((entry) {
                final idx = entry.key;
                final proc = entry.value;
                return Dismissible(
                  key: Key('proc-$idx'),
                  onDismissed: (_) {
                    setState(() => _procedures.removeAt(idx));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proc.procedureName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ICD-9-CM: ${proc.icd9cmCode} - ${proc.icd9cmDisplay}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (proc.snomedctCode != null &&
                              proc.snomedctCode!.isNotEmpty)
                            Text(
                              'SNOMED CT: ${proc.snomedctCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Pengkodean (Opsional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan jika diperlukan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF00897B).withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pengkodean',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Diagnosis:'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _diagnoses.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tindakan:'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _procedures.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
    );
  }
}
