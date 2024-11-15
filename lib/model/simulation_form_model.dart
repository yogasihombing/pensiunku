abstract class SimulationFormModel {}

class PengajuanFormModel extends SimulationFormModel {
  final String usia;
  final String domisili;
  final String instansi;
  final String nip;
  final String ktp;
  final String npwp;

  PengajuanFormModel({
    required this.usia,
    required this.domisili,
    required this.instansi,
    required this.nip,
    required this.ktp,
    required this.npwp,
  });
}

// ini harusnya sudah beres

// class PegawaiAktifFormModel extends SimulationFormModel {
//   final String name;
//   final String phone;
//   final DateTime birthDate;
//   final int salary;
//   final int tenor;
//   final int plafond;

//   PegawaiAktifFormModel({
//     required this.name,
//     required this.phone,
//     required this.birthDate,
//     required this.salary,
//     required this.tenor,
//     required this.plafond,
//   });
// }

// class PraPensiunFormModel extends SimulationFormModel {
//   final String name;
//   final String phone;
//   final DateTime birthDate;
//   final int age;
//   final int salary;
//   final OptionModel salaryPlace;
//   final int tenor;
//   final int plafond;
//   final int bup;
//   final int sisaHutang;
//   final OptionModel bankHutang;


//   PraPensiunFormModel({
//     required this.name,
//     required this.phone,
//     required this.birthDate,
//     required this.age,
//     required this.salary,
//     required this.salaryPlace,
//     required this.tenor,
//     required this.plafond,
//     required this.bup,
//     required this.sisaHutang,
//     required this.bankHutang,
//   });
// }

// class PensiunFormModel extends SimulationFormModel {
//   final String name;
//   final String phone;
//   final OptionModel statusPensiun;
//   final DateTime birthDate;
//   final int salary;
//   final OptionModel salaryPlace;
//   final int tenor;
//   final int plafond;
//   final int sisaHutang;
//   final OptionModel bankHutang;

//   PensiunFormModel({
//     required this.name,
//     required this.phone,
//     required this.statusPensiun,
//     required this.birthDate,
//     required this.salary,
//     required this.salaryPlace,
//     required this.tenor,
//     required this.plafond,
//     required this.sisaHutang,
//     required this.bankHutang,
//   });
// }

// class PlatinumFormModel extends SimulationFormModel {
//   final String name;
//   final String phone;
//   final DateTime birthDate;
//   final int salary;
//   final int angsuran;
//   final OptionModel tenor;
//   final OptionModel province;
//   final OptionModel salaryPlace;

//   PlatinumFormModel({
//     required this.name,
//     required this.phone,
//     required this.birthDate,
//     required this.salary,
//     required this.angsuran,
//     required this.tenor,
//     required this.province,
//     required this.salaryPlace,
//   });
// }