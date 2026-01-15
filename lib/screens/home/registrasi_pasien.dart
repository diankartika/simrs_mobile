// lib/screens/home/registrasi_pasien.dart
// COMPLETE - Pasien Lama search works, service buttons functional

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_models.dart';

class RegistrasiPasien extends StatefulWidget {
  const RegistrasiPasien({super.key});

  @override
  State<RegistrasiPasien> createState() => _RegistrasiPasienState();
}

class _RegistrasiPasienState extends State<RegistrasiPasien>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  // State variables
  String _jenisKelamin = 'Pilih';
  String _asuransi = 'Pilih Asuransi';
  DateTime _tanggalLahir = DateTime.now();
  String _serviceType = 'Rawat Jalan';

  bool _isLoading = false;
  bool _showSuccess = false;

  // Pasien Lama state
  Patient? _foundPatient;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // SEARCH PASIEN LAMA
  Future<void> _searchPasienLama() async {
    final searchTerm = _searchCtrl.text.trim();
    if (searchTerm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan No. RM atau NIK')));
      return;
    }

    setState(() => _hasSearched = true);

    try {
      // Search by RM or NIK
      final queryByRM =
          await FirebaseFirestore.instance
              .collection('patients')
              .where('rmNumber', isEqualTo: searchTerm)
              .get();

      if (queryByRM.docs.isNotEmpty) {
        setState(() {
          _foundPatient = Patient.fromFirestore(queryByRM.docs.first);
        });
        return;
      }

      final queryByNIK =
          await FirebaseFirestore.instance
              .collection('patients')
              .where('nik', isEqualTo: searchTerm)
              .get();

      if (queryByNIK.docs.isNotEmpty) {
        setState(() {
          _foundPatient = Patient.fromFirestore(queryByNIK.docs.first);
        });
      } else {
        setState(() => _foundPatient = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pasien tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // SUBMIT PASIEN LAMA (Send to queue)
  Future<void> _submitPasienLama() async {
    if (_foundPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cari dan pilih pasien terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _showSuccess = false;
      _isLoading = true;
    });

    try {
      // Check if patient already in queue
      final existingQueue =
          await FirebaseFirestore.instance
              .collection('queues')
              .where('patientId', isEqualTo: _foundPatient!.id)
              .where('currentQueue', isNotEqualTo: 'completed')
              .get();

      if (existingQueue.docs.isNotEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pasien sudah dalam antrian'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create new queue item
      await FirebaseFirestore.instance.collection('queues').add({
        'patientId': _foundPatient!.id,
        'patientName': _foundPatient!.name,
        'rmNumber': _foundPatient!.rmNumber,
        'currentQueue': 'rme',
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'metadata': {'serviceType': _foundPatient!.serviceType},
      });

      setState(() {
        _showSuccess = true;
        _isLoading = false;
      });

      // Clear search after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _searchCtrl.clear();
        setState(() {
          _foundPatient = null;
          _hasSearched = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // SUBMIT PASIEN BARU
  Future<void> _submitNewPatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _showSuccess = false;
      _isLoading = true;
    });

    try {
      final patientData = {
        'rmNumber': _generateRMNumber(),
        'name': _namaCtrl.text,
        'nik': _nikCtrl.text,
        'birthDate': Timestamp.fromDate(_tanggalLahir),
        'gender': _jenisKelamin,
        'age': _calculateAge(_tanggalLahir),
        'address': _alamatCtrl.text,
        'phone': _telpCtrl.text,
        'education': 'Unknown',
        'insurance': _asuransi,
        'serviceType': _serviceType,
        'registrationDate': Timestamp.now(),
        'status': 'active',
      };

      final patientRef = await FirebaseFirestore.instance
          .collection('patients')
          .add(patientData);

      await FirebaseFirestore.instance.collection('queues').add({
        'patientId': patientRef.id,
        'patientName': _namaCtrl.text,
        'rmNumber': patientData['rmNumber'],
        'currentQueue': 'rme',
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'metadata': {'serviceType': _serviceType},
      });

      setState(() {
        _showSuccess = true;
        _isLoading = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _namaCtrl.clear();
        _nikCtrl.clear();
        _alamatCtrl.clear();
        _telpCtrl.clear();
        setState(() {
          _jenisKelamin = 'Pilih';
          _asuransi = 'Pilih Asuransi';
          _serviceType = 'Rawat Jalan';
          _tanggalLahir = DateTime.now();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _generateRMNumber() {
    final now = DateTime.now();
    final random = DateTime.now().millisecond;
    return 'RM-${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
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
          'Registrasi Pasien',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // TAB BAR
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00897B),
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: const Color(0xFF00897B),
              tabs: const [Tab(text: 'Pasien Lama'), Tab(text: 'Pasien Baru')],
            ),
          ),
          // TAB VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPasienLama(context), _buildPasienBaru(context)],
            ),
          ),
        ],
      ),
    );
  }

  // ============ PASIEN LAMA TAB ============
  Widget _buildPasienLama(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cari Pasien Lama',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // SEARCH BOX
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'No. RM atau NIK',
                    hintStyle: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 13,
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
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _searchPasienLama,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PATIENT DATA CARD - ONLY SHOWS AFTER SEARCH
          if (_hasSearched && _foundPatient != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Pasien',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow('No. RM', _foundPatient!.rmNumber),
                  _buildDataRow('Nama', _foundPatient!.name),
                  _buildDataRow('Usia', '${_foundPatient!.age} Tahun'),
                  _buildDataRow('Jenis Kelamin', _foundPatient!.gender),
                ],
              ),
            )
          else if (_hasSearched && _foundPatient == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.red[50],
              ),
              child: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pasien tidak ditemukan. Cek kembali No. RM atau NIK.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // JENIS PELAYANAN - ONLY SHOWS WHEN PATIENT FOUND
          if (_foundPatient != null) ...[
            const Text(
              'Jenis Pelayanan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildServiceButton(
                  'Rawat Jalan',
                  _foundPatient!.serviceType == 'Rawat Jalan',
                  () => setState(
                    () => _foundPatient!.serviceType = 'Rawat Jalan',
                  ),
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'Rawat Inap',
                  _foundPatient!.serviceType == 'Rawat Inap',
                  () =>
                      setState(() => _foundPatient!.serviceType = 'Rawat Inap'),
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'IGD',
                  _foundPatient!.serviceType == 'IGD',
                  () => setState(() => _foundPatient!.serviceType = 'IGD'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KIRIM KE DOKTER BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPasienLama,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                          'Kirim ke Dokter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // SUCCESS MESSAGE - ONLY SHOWS AFTER SAVE
            if (_showSuccess)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal[700], size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Data pasien berhasil disimpan dan dalam antrian tinjauan dokter',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ============ PASIEN BARU TAB ============
  Widget _buildPasienBaru(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REGISTRASI BARU HEADER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: Color(0xFF00897B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Registrasi Baru',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // NAMA LENGKAP
            const Text(
              'Nama Lengkap',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaCtrl,
              decoration: InputDecoration(
                hintText: 'Masukkan nama sesuai KTP',
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
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NIK
            const Text(
              'Nomor Induk Kependudukan (NIK)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nikCtrl,
              decoration: InputDecoration(
                hintText: 'Masukkan NIK 16 digit sesuai KTP',
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
                  return 'NIK tidak boleh kosong';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // JENIS KELAMIN & TANGGAL LAHIR
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Kelamin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _jenisKelamin,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items:
                              ['Pilih', 'Laki-laki', 'Perempuan']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(
                                () => _jenisKelamin = val ?? 'Pilih',
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Lahir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _tanggalLahir,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _tanggalLahir = picked);
                          }
                        },
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: 'dd/mm/yyyy',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF00897B),
                              size: 18,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                '${_tanggalLahir.day.toString().padLeft(2, '0')}/${_tanggalLahir.month.toString().padLeft(2, '0')}/${_tanggalLahir.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ALAMAT
            const Text(
              'Alamat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _alamatCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap sesuai domisili',
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
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // TELEPON
            const Text(
              'No. Telp/HP Pasien',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _telpCtrl,
              decoration: InputDecoration(
                hintText: 'Masukkan no. hp pasien',
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
                  return 'No. HP tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // JENIS PELAYANAN
            const Text(
              'Jenis Pelayanan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildServiceButton(
                  'Rawat Jalan',
                  _serviceType == 'Rawat Jalan',
                  () => setState(() => _serviceType = 'Rawat Jalan'),
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'Rawat Inap',
                  _serviceType == 'Rawat Inap',
                  () => setState(() => _serviceType = 'Rawat Inap'),
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'IGD',
                  _serviceType == 'IGD',
                  () => setState(() => _serviceType = 'IGD'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ASURANSI
            const Text(
              'Asuransi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _asuransi,
                isExpanded: true,
                underline: const SizedBox(),
                items:
                    ['Pilih Asuransi', 'BPJS', 'Umum', 'Asuransi Swasta']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged:
                    (val) =>
                        setState(() => _asuransi = val ?? 'Pilih Asuransi'),
              ),
            ),
            const SizedBox(height: 32),

            // KIRIM KE DOKTER BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitNewPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                          'Kirim ke Dokter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // SUCCESS MESSAGE - ONLY SHOWS AFTER SAVE
            if (_showSuccess)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal[700], size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Data pasien berhasil disimpan dan dalam antrian tinjauan dokter',
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
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildServiceButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00897B) : Colors.white,
            border: Border.all(color: const Color(0xFF00897B), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF00897B),
            ),
          ),
        ),
      ),
    );
  }
}
