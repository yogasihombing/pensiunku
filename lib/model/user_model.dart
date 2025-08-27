import 'package:age_calculator/age_calculator.dart';

enum SimulationFormType {
  PegawaiAktif,
  Platinum,
  PraPensiun,
  Pensiun,
  Pengajuan,
}

class UserModel {
  final int id;
  final String phone;
  final String? username;
  final String? email;
  final String? address;
  final String? city;
  final String? birthDate;
  final String? job;
  final String? gender;
  final String? religion;
  final String? provinsi;
  final String? kecamatan;
  final String? kelurahan;
  final String? kodepos;
  final String? profilePictureUrl; // Ditambahkan untuk menyimpan URL foto profil
  final bool isPensiunkuPlus; // Ditambahkan untuk status Pensiunku+
  final bool isWalletActive; // Ditambahkan untuk status dompet

  UserModel({
    required this.id,
    required this.phone,
    this.username,
    this.email,
    this.address,
    this.city,
    this.birthDate,
    this.job,
    this.gender,
    this.religion,
    this.provinsi,
    this.kecamatan,
    this.kelurahan,
    this.kodepos,
    this.profilePictureUrl,
    this.isPensiunkuPlus = false,
    this.isWalletActive = false,
  });

  bool isRegistrationComplete() {
    return username != null && birthDate != null && job != null;
  }

  int? getAgeInMonths() {
    if (birthDate == null) {
      return null;
    } else {
      DateTime? birthDateObj = DateTime.tryParse(birthDate!);
      if (birthDateObj == null) {
        return null;
      } else {
        DateDuration duration = AgeCalculator.age(birthDateObj);
        return (duration.years * 12) + duration.months;
      }
    }
  }

  SimulationFormType? getSimulationFormType() {
    int? ageInMonths = getAgeInMonths();

    if (ageInMonths == null) {
      return null;
    } else {
      if (ageInMonths >= 50 * 12 && ageInMonths <= 60 * 12) {
        if (job == 'PRAPENSIUN') {
          return SimulationFormType.PraPensiun;
        } else {
          return SimulationFormType.Pensiun;
        }
      } else if (ageInMonths > 60 * 12 && ageInMonths <= 73 * 12) {
        return SimulationFormType.Pensiun;
      } else {
        return SimulationFormType.Platinum;
      }
    }
  }

  String? getSimulationFormTypeTitle() {
    switch (getSimulationFormType()) {
      case SimulationFormType.PegawaiAktif:
        return 'Pegawai Aktif';
      case SimulationFormType.Platinum:
        return 'Platinum';
      case SimulationFormType.PraPensiun:
        return 'Pra Pensiun';
      case SimulationFormType.Pensiun:
        return 'Pensiun';
      default:
        return null;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['telepon'],
      username: json['username'],
      email: json['email'],
      address: json['alamat'],
      city: json['kota'],
      birthDate: json['tanggal_lahir'],
      job: json['pekerjaan'],
      gender: json['jenis_kelamin'],
      religion: json['agama'],
      provinsi: json['provinsi'],
      kecamatan: json['kecamatan'],
      kelurahan: json['kelurahan'],
      kodepos: json['kodepos'],
      profilePictureUrl: json['profile_picture_url'], // Menambahkan field baru
      isPensiunkuPlus: json['is_pensiunku_plus'] ?? false, // Menambahkan field baru dengan nilai default
      isWalletActive: json['is_wallet_active'] ?? false, // Menambahkan field baru dengan nilai default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telepon': phone,
      'username': username,
      'email': email,
      'alamat': address,
      'kota': city,
      'tanggal_lahir': birthDate,
      'pekerjaan': job,
      'jenis_kelamin': gender,
      'agama': religion,
      'provinsi': provinsi,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'kodepos': kodepos,
      'profile_picture_url': profilePictureUrl,
      'is_pensiunku_plus': isPensiunkuPlus,
      'is_wallet_active': isWalletActive,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}