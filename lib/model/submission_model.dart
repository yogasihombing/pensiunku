import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';

class SubmissionModel {
  final int id;
  final String produk;
  final String name;
  final String phone;
  final DateTime birthDate;
  final int salary;
  final int tenor;
  final int plafond;
  final String bankName;
  final String? fotoKtp;
  final String? nameKtp;
  final String? nikKtp;
  final String? addressKtp;
  final String? jobKtp;
  final DateTime? birthDateKtp;
  final String? fotoSelfie;
  final String? institutionText;
  final String? institutionName;
  final String? nip;
  final String? groupText;
  final int? employmentInfoSalary;
  final DateTime? tmtRetirement;
  final String? retirementInstitutionText;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final int? bersih;
  final int? angsuran;

  SubmissionModel({
    required this.id,
    required this.produk,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.salary,
    required this.tenor,
    required this.plafond,
    required this.bankName,
    this.fotoKtp,
    this.nameKtp,
    this.nikKtp,
    this.addressKtp,
    this.jobKtp,
    this.birthDateKtp,
    this.fotoSelfie,
    this.institutionText,
    this.institutionName,
    this.nip,
    this.groupText,
    this.employmentInfoSalary,
    this.tmtRetirement,
    this.retirementInstitutionText,
    this.submittedAt,
    this.createdAt,
    this.bersih,
    this.angsuran,
  });

  SubmissionModel copyWith({
    int? id,
    String? produk,
    String? name,
    String? phone,
    DateTime? birthDate,
    int? salary,
    int? tenor,
    int? plafond,
    String? bankName,
    String? fotoKtp,
    String? nameKtp,
    String? nikKtp,
    String? addressKtp,
    String? jobKtp,
    DateTime? birthDateKtp,
    String? fotoSelfie,
    String? institutionText,
    String? institutionName,
    String? nip,
    String? groupText,
    int? employmentInfoSalary,
    DateTime? tmtRetirement,
    String? retirementInstitutionText,
    DateTime? submittedAt,
    DateTime? createdAt,
    int? bersih,
    int? angsuran,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      produk: produk ?? this.produk,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      salary: salary ?? this.salary,
      tenor: tenor ?? this.tenor,
      plafond: plafond ?? this.plafond,
      bankName: bankName ?? this.bankName,
      fotoKtp: fotoKtp ?? this.fotoKtp,
      nameKtp: nameKtp ?? this.nameKtp,
      nikKtp: nikKtp ?? this.nikKtp,
      addressKtp: addressKtp ?? this.addressKtp,
      jobKtp: jobKtp ?? this.jobKtp,
      birthDateKtp: birthDateKtp ?? this.birthDateKtp,
      fotoSelfie: fotoSelfie ?? this.fotoSelfie,
      institutionText: institutionText ?? this.institutionText,
      institutionName: institutionName ?? this.institutionName,
      nip: nip ?? this.nip,
      groupText: groupText ?? this.groupText,
      employmentInfoSalary: employmentInfoSalary ?? this.employmentInfoSalary,
      tmtRetirement: tmtRetirement ?? this.tmtRetirement,
      retirementInstitutionText:
          retirementInstitutionText ?? this.retirementInstitutionText,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      bersih: bersih ?? this.bersih,
      angsuran: angsuran ?? this.angsuran,
    );
  }

  String? getAssetName() {
    String? assetName;
    switch (bankName.toLowerCase()) {
      case 'bjb':
        assetName = 'assets/bank/bjb_logo.png';
        break;
      case 'bni':
        assetName = 'assets/bank/bni_logo.png';
        break;
      case 'bws':
        assetName = 'assets/bank/bws_logo.png';
        break;
      case 'btpn':
        assetName = 'assets/bank/btpn_logo.png';
        break;
      case 'bba':
        assetName = 'assets/bank/bba_logo.png';
        break;
      case 'kbb':
        assetName = 'assets/bank/kbb_logo.png';
        break;
      case 'mantap':
        assetName = 'assets/bank/mantap_logo.png';
        break;
      default:
        break;
    }
    return assetName;
  }

  String getProductNameFormatted() {
    switch (produk) {
      case 'pegawaiAktif':
        return 'Pegawai Aktif';
      case 'prapensiun':
        return 'Pra-Pensiun';
      case 'pensiun':
        return 'Pensiun';
      case 'platinum':
        return 'Platinum';
      default:
        return '';
    }
  }

  String getPlafondFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: '',
    ).format(plafond.toString());
  }

  String getBersihFormatted() {
    int bersihFinal = bersih ?? 0;
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: '',
    ).format(bersihFinal.toString());
  }

  String getAngsuranFormatted() {
    int angsuranFinal = angsuran ?? 0;
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: '',
    ).format(angsuranFinal.toString());
  }

  bool isKtpComplete() {
    return fotoKtp?.isNotEmpty == true &&
        nameKtp?.isNotEmpty == true &&
        nikKtp?.isNotEmpty == true &&
        addressKtp?.isNotEmpty == true &&
        jobKtp != null;
  }

  bool isEmploymentInfoComplete() {
    if (employmentInfoSalary != null) {
    } else {
    }
    return institutionText?.isNotEmpty == true &&
        // institutionName?.isNotEmpty == true &&
        nip?.isNotEmpty == true &&
        groupText?.isNotEmpty == true &&
        // employmentInfoSalaryValid &&
        tmtRetirement != null &&
        retirementInstitutionText?.isNotEmpty == true;
  }

  bool isReadyForSubmit() {
    return isKtpComplete() &&
        fotoSelfie?.isNotEmpty == true &&
        isEmploymentInfoComplete() &&
        !isSubmitted();
  }

  bool isSubmitted() {
    return submittedAt != null;
  }

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    int? employmentInfoSalary;
    if (json['estimasi_gaji'] != null) {
      employmentInfoSalary = json['estimasi_gaji'] is String
          ? int.tryParse(json['estimasi_gaji'])
          : json['estimasi_gaji'];
    }
    int? bersih;
    if (json['bersih'] != null) {
      bersih = json['bersih'] is String
          ? int.tryParse(json['bersih'])
          : json['bersih'];
    }
    int? angsuran;
    if (json['angsuran'] != null) {
      angsuran = json['angsuran'] is String
          ? int.tryParse(json['angsuran'])
          : json['angsuran'];
    }
    return SubmissionModel(
      id: json['id'],
      fotoKtp: json['foto_ktp'],
      nameKtp: json['nama_ktp'],
      nikKtp: json['nik_ktp'],
      addressKtp: json['alamat_ktp'],
      jobKtp: json['pekerjaan_ktp'],
      birthDateKtp: json['tanggal_lahir_ktp'] != null
          ? DateTime.tryParse(json['tanggal_lahir_ktp'])
          : null,
      fotoSelfie: json['foto_selfie'],
      produk: json['produk'],
      name: json['name'],
      phone: json['phone'],
      birthDate: DateTime.parse(json['tanggal_lahir']),
      salary:
          json['gaji'] is String ? int.tryParse(json['gaji']) : json['gaji'],
      tenor: json['tenorbulan'] is String
          ? int.tryParse(json['tenorbulan'])
          : json['tenorbulan'],
      plafond: json['plafond'] is String
          ? int.tryParse(json['plafond'])
          : json['plafond'],
      bankName: json['nama_bank'],
      institutionText: json['instansi'],
      institutionName: json['nama_instansi'],
      nip: json['nip'],
      groupText: json['golongan'],
      employmentInfoSalary: employmentInfoSalary,
      tmtRetirement: json['tmt_pensiun'] != null
          ? DateTime.tryParse(json['tmt_pensiun'])
          : null,
      retirementInstitutionText: json['instansi_pensiun'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      bersih: bersih,
      angsuran: angsuran,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto_ktp': fotoKtp,
      'nama_ktp': nameKtp,
      'nik_ktp': nikKtp,
      'alamat_ktp': addressKtp,
      'pekerjaan_ktp': jobKtp,
      'tanggal_lahir_ktp': birthDateKtp != null
          ? DateFormat('y-MM-dd').format(birthDateKtp!)
          : null,
      'foto_selfie': fotoSelfie,
      'produk': produk,
      'name': name,
      'phone': phone,
      'tanggal_lahir': DateFormat('y-MM-dd').format(birthDate),
      'gaji': salary,
      'tenorbulan': tenor,
      'plafond': plafond,
      'nama_bank': bankName,
      'instansi': institutionText,
      'nama_instansi': institutionName,
      'nip': nip,
      'golongan': groupText,
      'estimasi_gaji': employmentInfoSalary,
      'tmt_pensiun': tmtRetirement != null
          ? DateFormat('y-MM-dd').format(tmtRetirement!)
          : null,
      'instansi_pensiun': retirementInstitutionText,
      'submitted_at': submittedAt != null
          ? DateFormat('y-MM-dd HH:mm:ss').format(submittedAt!)
          : null,
      'created_at': submittedAt != null
          ? DateFormat('y-MM-dd HH:mm:ss').format(submittedAt!)
          : null,
      'bersih': bersih,
      'angsuran': angsuran,
    };
  }
}

class SubmissionCheck{
  final int jumlahPengajuan;
  DateTime? tanggalLahir;

  SubmissionCheck({
    required this.jumlahPengajuan,
    this.tanggalLahir
  });

  factory SubmissionCheck.fromJson(Map<String, dynamic> json){
    return SubmissionCheck(
      jumlahPengajuan: json['jumlah_pengajuan'],
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'])
          : null,
    );
  }
}
