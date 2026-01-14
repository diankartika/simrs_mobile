// lib/screens/home/admin/registrasi_pasien.dart

import 'package:flutter/material.dart';

class RegistrasiPasien extends StatefulWidget {
  const RegistrasiPasien({super.key});

  @override
  State<RegistrasiPasien> createState() => _RegistrasiPasienState();
}

class _RegistrasiPasienState extends State<RegistrasiPasien>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  String _jenisKelamin = 'Pilih';
  String _asuransi = 'Pilih Asuransi';
  DateTime _tanggalLahir = DateTime.now();

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
            ],
          ),
          const SizedBox(height: 24),

          // PATIENT DATA CARD
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
                _buildDataRow('No. RM', ': RM-2025-001'),
                _buildDataRow('Nama', ': Daniella Simamurung'),
                _buildDataRow('Usia', ': 21 Tahun 8 Bulan'),
                _buildDataRow('Jenis Kelamin', ': Perempuan'),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
              _buildServiceButton('Rawat Jalan', true),
              const SizedBox(width: 12),
              _buildServiceButton('Rawat Inap', false),
              const SizedBox(width: 12),
              _buildServiceButton('IGD', false),
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
                  (val) => setState(() => _asuransi = val ?? 'Pilih Asuransi'),
            ),
          ),
          const SizedBox(height: 32),

          // KIRIM KE DOKTER BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kirim ke Dokter',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
                Icon(Icons.check_circle, color: Colors.teal[700], size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Data pasien berhasil dikirimkan dan dalam antrian dokter',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ PASIEN BARU TAB ============
  Widget _buildPasienBaru(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REGISTRASI BARU BUTTON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              border: Border.all(color: const Color(0xFF00897B), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: const Color(0xFF00897B),
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
          TextField(
            controller: _namaCtrl,
            decoration: InputDecoration(
              hintText: 'Masukkan nama sesuai KTP',
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
          TextField(
            controller: _nikCtrl,
            decoration: InputDecoration(
              hintText: 'Masukkan NIK 16 digit sesuai KTP',
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
                            (val) =>
                                setState(() => _jenisKelamin = val ?? 'Pilih'),
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
          TextField(
            controller: _alamatCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Masukkan alamat lengkap sesuai domisili',
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
          TextField(
            controller: _telpCtrl,
            decoration: InputDecoration(
              hintText: 'Masukkan no. hp pasien',
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
                  (val) => setState(() => _asuransi = val ?? 'Pilih Asuransi'),
            ),
          ),
          const SizedBox(height: 32),

          // KIRIM KE DOKTER BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kirim ke Dokter',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
                Icon(Icons.check_circle, color: Colors.teal[700], size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Data pasien berhasil dikirimkan dan dalam antrian dokter',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
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

  Widget _buildServiceButton(String label, bool isSelected) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF00897B) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF00897B),
          side: BorderSide(color: const Color(0xFF00897B), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
