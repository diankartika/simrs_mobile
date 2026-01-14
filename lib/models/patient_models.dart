// lib/models/patient_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceType { rajal, ranap, igd }

class Patient {
  final String id;
  final String rmNumber;
  final String name;
  final String nik;
  final DateTime birthDate;
  final String gender; // Laki-laki, Perempuan
  final String address;
  final String phone;
  final String education; // Pendidikan
  final String insurance; // BPJS, Umum, dll
  final ServiceType serviceType;
  final DateTime registrationDate;
  final String status; // active, completed, archived

  Patient({
    required this.id,
    required this.rmNumber,
    required this.name,
    required this.nik,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.phone,
    required this.education,
    required this.insurance,
    required this.serviceType,
    required this.registrationDate,
    this.status = 'active',
  });

  // Calculate age
  int get age {
    return DateTime.now().year - birthDate.year;
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'rmNumber': rmNumber,
      'name': name,
      'nik': nik,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'address': address,
      'phone': phone,
      'education': education,
      'insurance': insurance,
      'serviceType': serviceType.name,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'status': status,
    };
  }

  // From Firestore
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      rmNumber: data['rmNumber'] ?? '',
      name: data['name'] ?? '',
      nik: data['nik'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      education: data['education'] ?? '',
      insurance: data['insurance'] ?? '',
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == data['serviceType'],
      ),
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
    );
  }

  Patient copyWith({
    String? id,
    String? rmNumber,
    String? name,
    String? nik,
    DateTime? birthDate,
    String? gender,
    String? address,
    String? phone,
    String? education,
    String? insurance,
    ServiceType? serviceType,
    DateTime? registrationDate,
    String? status,
  }) {
    return Patient(
      id: id ?? this.id,
      rmNumber: rmNumber ?? this.rmNumber,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      education: education ?? this.education,
      insurance: insurance ?? this.insurance,
      serviceType: serviceType ?? this.serviceType,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
    );
  }
}

// ============ RME FORM MODEL ============

class RMEModel {
  final String id;
  final String patientId;
  final String keluhanUtama;
  final String riwayatPenyakit;
  final String diagnosisDokter;
  final String terapi;
  final List<String> obat;
  final String hasilPemeriksaan;
  final String doctorName;
  final DateTime createdAt;
  final String status; // draft, completed, sent_to_coder

  RMEModel({
    required this.id,
    required this.patientId,
    required this.keluhanUtama,
    required this.riwayatPenyakit,
    required this.diagnosisDokter,
    required this.terapi,
    required this.obat,
    required this.hasilPemeriksaan,
    required this.doctorName,
    required this.createdAt,
    this.status = 'draft',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'keluhanUtama': keluhanUtama,
      'riwayatPenyakit': riwayatPenyakit,
      'diagnosisDokter': diagnosisDokter,
      'terapi': terapi,
      'obat': obat,
      'hasilPemeriksaan': hasilPemeriksaan,
      'doctorName': doctorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory RMEModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RMEModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      keluhanUtama: data['keluhanUtama'] ?? '',
      riwayatPenyakit: data['riwayatPenyakit'] ?? '',
      diagnosisDokter: data['diagnosisDokter'] ?? '',
      terapi: data['terapi'] ?? '',
      obat: List<String>.from(data['obat'] ?? []),
      hasilPemeriksaan: data['hasilPemeriksaan'] ?? '',
      doctorName: data['doctorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'draft',
    );
  }

  RMEModel copyWith({
    String? id,
    String? patientId,
    String? keluhanUtama,
    String? riwayatPenyakit,
    String? diagnosisDokter,
    String? terapi,
    List<String>? obat,
    String? hasilPemeriksaan,
    String? doctorName,
    DateTime? createdAt,
    String? status,
  }) {
    return RMEModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      keluhanUtama: keluhanUtama ?? this.keluhanUtama,
      riwayatPenyakit: riwayatPenyakit ?? this.riwayatPenyakit,
      diagnosisDokter: diagnosisDokter ?? this.diagnosisDokter,
      terapi: terapi ?? this.terapi,
      obat: obat ?? this.obat,
      hasilPemeriksaan: hasilPemeriksaan ?? this.hasilPemeriksaan,
      doctorName: doctorName ?? this.doctorName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

// ============ CODING FORM MODEL ============

class CodingForm {
  final String id;
  final String rmeFormId;
  final String patientId;
  final String diagnosisKlinis;
  final String icd10Code; // e.g., J11.0
  final String icd10Description; // e.g., Influenza with pneumonia
  final String icd9CMCode; // Procedure code
  final String icd9CMDescription;
  final String tindakan; // Procedure/Action
  final String coderName;
  final DateTime createdAt;
  final String status; // pending, coded, validated, sent_to_auditor

  CodingForm({
    required this.id,
    required this.rmeFormId,
    required this.patientId,
    required this.diagnosisKlinis,
    required this.icd10Code,
    required this.icd10Description,
    required this.icd9CMCode,
    required this.icd9CMDescription,
    required this.tindakan,
    required this.coderName,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'rmeFormId': rmeFormId,
      'patientId': patientId,
      'diagnosisKlinis': diagnosisKlinis,
      'icd10Code': icd10Code,
      'icd10Description': icd10Description,
      'icd9CMCode': icd9CMCode,
      'icd9CMDescription': icd9CMDescription,
      'tindakan': tindakan,
      'coderName': coderName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory CodingForm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CodingForm(
      id: doc.id,
      rmeFormId: data['rmeFormId'] ?? '',
      patientId: data['patientId'] ?? '',
      diagnosisKlinis: data['diagnosisKlinis'] ?? '',
      icd10Code: data['icd10Code'] ?? '',
      icd10Description: data['icd10Description'] ?? '',
      icd9CMCode: data['icd9CMCode'] ?? '',
      icd9CMDescription: data['icd9CMDescription'] ?? '',
      tindakan: data['tindakan'] ?? '',
      coderName: data['coderName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  CodingForm copyWith({
    String? id,
    String? rmeFormId,
    String? patientId,
    String? diagnosisKlinis,
    String? icd10Code,
    String? icd10Description,
    String? icd9CMCode,
    String? icd9CMDescription,
    String? tindakan,
    String? coderName,
    DateTime? createdAt,
    String? status,
  }) {
    return CodingForm(
      id: id ?? this.id,
      rmeFormId: rmeFormId ?? this.rmeFormId,
      patientId: patientId ?? this.patientId,
      diagnosisKlinis: diagnosisKlinis ?? this.diagnosisKlinis,
      icd10Code: icd10Code ?? this.icd10Code,
      icd10Description: icd10Description ?? this.icd10Description,
      icd9CMCode: icd9CMCode ?? this.icd9CMCode,
      icd9CMDescription: icd9CMDescription ?? this.icd9CMDescription,
      tindakan: tindakan ?? this.tindakan,
      coderName: coderName ?? this.coderName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

// ============ AUDIT FORM MODEL ============

class AuditForm {
  final String id;
  final String codingFormId;
  final String patientId;
  final List<AuditChecklist> checklist;
  final String notes;
  final String auditorName;
  final DateTime createdAt;
  final String status; // pending, completed, rejected

  AuditForm({
    required this.id,
    required this.codingFormId,
    required this.patientId,
    required this.checklist,
    required this.notes,
    required this.auditorName,
    required this.createdAt,
    this.status = 'pending',
  });

  bool get isComplete {
    return checklist.every((item) => item.isChecked);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'codingFormId': codingFormId,
      'patientId': patientId,
      'checklist': checklist.map((c) => c.toMap()).toList(),
      'notes': notes,
      'auditorName': auditorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory AuditForm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditForm(
      id: doc.id,
      codingFormId: data['codingFormId'] ?? '',
      patientId: data['patientId'] ?? '',
      checklist:
          (data['checklist'] as List)
              .map((c) => AuditChecklist.fromMap(c))
              .toList(),
      notes: data['notes'] ?? '',
      auditorName: data['auditorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}

class AuditChecklist {
  final String item; // e.g., "Form Pendaftaran", "Anamnesis & Fisik"
  bool isChecked;

  AuditChecklist({required this.item, this.isChecked = false});

  Map<String, dynamic> toMap() {
    return {'item': item, 'isChecked': isChecked};
  }

  factory AuditChecklist.fromMap(Map<String, dynamic> map) {
    return AuditChecklist(
      item: map['item'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }
}

// ============ DEFAULT AUDIT CHECKLIST ============

List<AuditChecklist> getDefaultAuditChecklist() {
  return [
    AuditChecklist(item: 'Form Pendaftaran'),
    AuditChecklist(item: 'Anamnesis & Fisik'),
    AuditChecklist(item: 'Diagnosis Klinis'),
    AuditChecklist(item: 'Kode ICD-10'),
    AuditChecklist(item: 'Kode ICD-9-CM'),
    AuditChecklist(item: 'Tanda Tangan Dokter'),
  ];
}
