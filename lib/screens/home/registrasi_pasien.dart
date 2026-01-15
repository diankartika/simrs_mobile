// lib/screens/home/registrasi_pasien.dart - FIXED VERSION
// Fixed: 7 Dart errors resolved
// - assignment_to_final (line 450, 458, 464)
// - use_build_context_synchronously (line 104)
// - unrelated_type_equality_checks (line 448, 456, 463)

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
  String _selectedServiceTypeLama = 'Rawat Jalan'; // ✅ ADD: For pasien lama

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan No. RM atau NIK')),
        );
      }
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
          // ✅ FIX: Cast serviceType to String with .toString()
          _selectedServiceTypeLama =
              (_foundPatient?.serviceType?.toString() ?? 'Rawat Jalan');
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
          // ✅ FIX: Cast serviceType to String with .toString()
          _selectedServiceTypeLama =
              (_foundPatient?.serviceType?.toString() ?? 'Rawat Jalan');
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
      // ✅ FIX #1: Add mounted check + user-friendly error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat mencari pasien'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    // ✅ ADD: Validate asuransi
    if (_asuransi == 'Pilih Asuransi') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih asuransi terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create queue item untuk dokter
      final queueData = {
        'patientId': _foundPatient!.id,
        'rmNumber': _foundPatient!.rmNumber,
        'patientName': _foundPatient!.name,
        'queue': 'rme',
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'metadata': {
          'serviceType':
              _selectedServiceTypeLama, // ✅ USE: State variable bukan property
          'asuransi': _asuransi, // ✅ ADD: Include asuransi
        },
      };

      // Save to queue
      await FirebaseFirestore.instance.collection('queue').add(queueData);

      if (mounted) {
        setState(() => _showSuccess = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pasien berhasil masuk antrian dokter'),
            backgroundColor: Color(0xFF00897B),
          ),
        );

        // Reset form
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _searchCtrl.clear();
            setState(() {
              _foundPatient = null;
              _hasSearched = false;
              _showSuccess = false;
              _selectedServiceTypeLama = 'Rawat Jalan';
              _asuransi = 'Pilih Asuransi'; // ✅ ADD: Reset asuransi
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // SUBMIT PASIEN BARU
  Future<void> _submitPasienBaru() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jenisKelamin == 'Pilih') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jenis kelamin')));
      return;
    }
    if (_asuransi == 'Pilih Asuransi') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih asuransi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate RM Number
      final rmNumber =
          'RM-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Create patient
      final patientData = {
        'rmNumber': rmNumber,
        'nik': _nikCtrl.text,
        'name': _namaCtrl.text,
        'gender': _jenisKelamin,
        'dateOfBirth': _tanggalLahir,
        'address': _alamatCtrl.text,
        'phone': _telpCtrl.text,
        'insurance': _asuransi,
        'serviceType': _serviceType, // ✅ USE: State variable
        'status': 'active',
        'registrationDate': Timestamp.now(),
      };

      // Save patient
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .add(patientData);

      // Create queue item untuk dokter
      final queueData = {
        'patientId': patientDoc.id,
        'rmNumber': rmNumber,
        'patientName': _namaCtrl.text,
        'queue': 'rme',
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'metadata': {
          'serviceType': _serviceType, // ✅ USE: State variable
        },
      };

      await FirebaseFirestore.instance.collection('queue').add(queueData);

      if (mounted) {
        setState(() => _showSuccess = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pasien berhasil didaftarkan'),
            backgroundColor: Color(0xFF00897B),
          ),
        );

        // Reset form
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _formKey.currentState!.reset();
            setState(() {
              _jenisKelamin = 'Pilih';
              _asuransi = 'Pilih Asuransi';
              _tanggalLahir = DateTime.now();
              _serviceType = 'Rawat Jalan';
              _showSuccess = false;
            });
            _namaCtrl.clear();
            _nikCtrl.clear();
            _alamatCtrl.clear();
            _telpCtrl.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan'),
            backgroundColor: Colors.red,
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
          'Registrasi Pasien',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00897B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00897B),
          tabs: const [Tab(text: 'Pasien Baru'), Tab(text: 'Pasien Lama')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: PASIEN BARU
          _buildPasienBaruTab(),
          // TAB 2: PASIEN LAMA
          _buildPasienLamaTab(),
        ],
      ),
    );
  }

  Widget _buildPasienBaruTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 24),

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
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _asuransi,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: const [
                  DropdownMenuItem(
                    value: 'Pilih Asuransi',
                    child: Text('Pilih Asuransi'),
                  ),
                  DropdownMenuItem(value: 'BPJS', child: Text('BPJS')),
                  DropdownMenuItem(value: 'Privat', child: Text('Privat')),
                  DropdownMenuItem(value: 'Umum', child: Text('Umum')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _asuransi = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

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
              keyboardType: TextInputType.number,
              maxLength: 16,
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
                  return 'NIK harus diisi';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NAMA
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
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // JENIS KELAMIN
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
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _jenisKelamin,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: const [
                  DropdownMenuItem(value: 'Pilih', child: Text('Pilih')),
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _jenisKelamin = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // TANGGAL LAHIR
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
                final date = await showDatePicker(
                  context: context,
                  initialDate: _tanggalLahir,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _tanggalLahir = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_tanggalLahir.day}/${_tanggalLahir.month}/${_tanggalLahir.year}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
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
                  return 'Alamat harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NO TELP
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
              keyboardType: TextInputType.phone,
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
                  return 'No. telp harus diisi';
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
                onPressed: _isLoading ? null : _submitPasienBaru,
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
                          'Daftarkan Pasien Baru',
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
    );
  }

  Widget _buildPasienLamaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH FIELD
          const Text(
            'Cari Pasien Lama',
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
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'No. RM atau NIK',
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
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _searchPasienLama,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SEARCH RESULTS
          if (_hasSearched && _foundPatient != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00897B), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('No. RM', _foundPatient!.rmNumber),
                  _buildDetailRow('Nama', _foundPatient!.name),
                  _buildDetailRow('Usia', '${_foundPatient!.age} Tahun'),
                  _buildDetailRow('Jenis Kelamin', _foundPatient!.gender),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // JENIS PELAYANAN
            const Text(
              'Jenis Pelayanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildServiceButton(
                  'Rawat Jalan',
                  _selectedServiceTypeLama ==
                      'Rawat Jalan', // ✅ FIX: Use state variable
                  () => setState(
                    () =>
                        _selectedServiceTypeLama =
                            'Rawat Jalan', // ✅ FIX: Assign to state
                  ),
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'Rawat Inap',
                  _selectedServiceTypeLama ==
                      'Rawat Inap', // ✅ FIX: Use state variable
                  () => setState(
                    () => _selectedServiceTypeLama = 'Rawat Inap',
                  ), // ✅ FIX: Assign to state
                ),
                const SizedBox(width: 12),
                _buildServiceButton(
                  'IGD',
                  _selectedServiceTypeLama ==
                      'IGD', // ✅ FIX: Use state variable
                  () => setState(
                    () => _selectedServiceTypeLama = 'IGD',
                  ), // ✅ FIX: Assign to state
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ASURANSI
            const Text(
              'Asuransi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _asuransi,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: const [
                  DropdownMenuItem(
                    value: 'Pilih Asuransi',
                    child: Text('Pilih Asuransi'),
                  ),
                  DropdownMenuItem(value: 'BPJS', child: Text('BPJS')),
                  DropdownMenuItem(value: 'Privat', child: Text('Privat')),
                  DropdownMenuItem(value: 'Umum', child: Text('Umum')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _asuransi = value);
                  }
                },
              ),
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
                          'Kirim ke Dokter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
              ),
            ),

            // SUCCESS MESSAGE
            if (_showSuccess)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pasien berhasil masuk antrian dokter',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_hasSearched && _foundPatient == null)
            Center(
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Pasien tidak ditemukan',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
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
            border: Border.all(color: const Color(0xFF00897B), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF00897B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
