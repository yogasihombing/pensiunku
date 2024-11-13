import 'package:pensiunku/model/option_model.dart';

class JobRepository {
  static List<OptionModel> jobs = [
    OptionModel(id: 1, text: 'PENSIUNAN'),
    OptionModel(id: 2, text: 'PRAPENSIUN'),
    // OptionModel(id: 3, text: 'Pegawai BUMN'),
    // OptionModel(id: 4, text: 'Pegawai BUMD'),
    // OptionModel(id: 5, text: 'Anggota TNI'),
    // OptionModel(id: 6, text: 'Anggota POLRI'),
    // OptionModel(id: 7, text: 'KEPOLISIAN RI'),
    // OptionModel(id: 8, text: 'PERDAGANGAN'),
    // OptionModel(id: 9, text: 'PETANI/PEKEBUN'),
    // OptionModel(id: 10, text: 'PETERNAK'),
    // OptionModel(id: 11, text: 'NELAYAN/PERIKANAN'),
    // OptionModel(id: 12, text: 'INDUSTRI'),
    // OptionModel(id: 13, text: 'KONSTRUKSI'),
    // OptionModel(id: 14, text: 'TRANSPORTASI'),
    // OptionModel(id: 15, text: 'KARYAWAN SWASTA'),
    // OptionModel(id: 16, text: 'KARYAWAN BUMN'),
    // OptionModel(id: 17, text: 'KARYAWAN BUMD'),
    // OptionModel(id: 18, text: 'KARYAWAN HONORER'),
    // OptionModel(id: 19, text: 'BURUH HARIAN LEPAS'),
    // OptionModel(id: 20, text: 'BURUH TANI/PERKEBUNAN'),
    // OptionModel(id: 21, text: 'BURUH NELAYAN/PERIKANAN'),
    // OptionModel(id: 22, text: 'BURUH PETERNAKAN'),
    // OptionModel(id: 23, text: 'PEMBANTU RUMAH TANGGA'),
    // OptionModel(id: 24, text: 'TUKANG CUKUR'),
    // OptionModel(id: 25, text: 'TUKANG LISTRIK'),
    // OptionModel(id: 26, text: 'TUKANG BATU'),
    // OptionModel(id: 27, text: 'TUKANG KAYU'),
    // OptionModel(id: 28, text: 'TUKANG SOL SEPATU'),
    // OptionModel(id: 29, text: 'TUKANG LAS/PANDAI BESI'),
    // OptionModel(id: 30, text: 'TUKANG JAHIT'),
    // OptionModel(id: 31, text: 'TUKANG GIGI'),
    // OptionModel(id: 32, text: 'PENATA RIAS'),
    // OptionModel(id: 33, text: 'PENATA BUSANA'),
    // OptionModel(id: 34, text: 'PENATA RAMBUT'),
    // OptionModel(id: 35, text: 'MEKANIK'),
    // OptionModel(id: 36, text: 'SENIMAN'),
    // OptionModel(id: 37, text: 'TABIB'),
    // OptionModel(id: 38, text: 'PARAJI'),
    // OptionModel(id: 39, text: 'PERANCANG BUSANA'),
    // OptionModel(id: 40, text: 'PENTERJEMAH'),
    // OptionModel(id: 41, text: 'IMAM MESJID'),
    // OptionModel(id: 42, text: 'PENDETA'),
    // OptionModel(id: 43, text: 'PASTOR'),
    // OptionModel(id: 44, text: 'WARTAWAN'),
    // OptionModel(id: 45, text: 'USTADZ/MUBALIGH'),
    // OptionModel(id: 46, text: 'JURU MASAK'),
    // OptionModel(id: 47, text: 'PROMOTOR ACARA'),
    // OptionModel(id: 48, text: 'ANGGOTA DPR-RI'),
    // OptionModel(id: 49, text: 'ANGGOTA DPD'),
    // OptionModel(id: 50, text: 'ANGGOTA BPK'),
    // OptionModel(id: 51, text: 'PRESIDEN'),
    // OptionModel(id: 52, text: 'WAKIL PRESIDEN'),
    // OptionModel(id: 53, text: 'ANGGOTA MAHKAMAH KONSTITUSI'),
    // OptionModel(id: 54, text: 'ANGGOTA KABINET/KEMENTERIAN'),
    // OptionModel(id: 55, text: 'DUTA BESAR'),
    // OptionModel(id: 56, text: 'GUBERNUR'),
    // OptionModel(id: 57, text: 'WAKIL GUBERNUR'),
    // OptionModel(id: 58, text: 'BUPATI'),
    // OptionModel(id: 59, text: 'WAKIL BUPATI'),
    // OptionModel(id: 60, text: 'WALIKOTA'),
    // OptionModel(id: 61, text: 'WAKIL WALIKOTA'),
    // OptionModel(id: 62, text: 'ANGGOTA DPRD PROVINSI'),
    // OptionModel(id: 63, text: 'ANGGOTA DPRD KABUPATEN/KOTA'),
    // OptionModel(id: 64, text: 'DOSEN'),
    // OptionModel(id: 65, text: 'GURU'),
    // OptionModel(id: 66, text: 'PILOT'),
    // OptionModel(id: 67, text: 'PENGACARA'),
    // OptionModel(id: 68, text: 'NOTARIS'),
    // OptionModel(id: 69, text: 'ARSITEK'),
    // OptionModel(id: 70, text: 'AKUNTAN'),
    // OptionModel(id: 71, text: 'KONSULTAN'),
    // OptionModel(id: 72, text: 'DOKTER'),
    // OptionModel(id: 73, text: 'BIDAN'),
    // OptionModel(id: 74, text: 'PERAWAT'),
    // OptionModel(id: 75, text: 'APOTEKER'),
    // OptionModel(id: 76, text: 'PSIKIATER/PSIKOLOG'),
    // OptionModel(id: 77, text: 'PENYIAR TELEVISI'),
    // OptionModel(id: 78, text: 'PENYIAR RADIO'),
    // OptionModel(id: 79, text: 'PELAUT'),
    // OptionModel(id: 80, text: 'PENELITI'),
    // OptionModel(id: 81, text: 'SOPIR'),
    // OptionModel(id: 82, text: 'PIALANG'),
    // OptionModel(id: 83, text: 'PARANORMAL'),
    // OptionModel(id: 84, text: 'PEDAGANG'),
    // OptionModel(id: 85, text: 'PERANGKAT DESA'),
    // OptionModel(id: 86, text: 'KEPALA DESA'),
    // OptionModel(id: 87, text: 'BIARAWATI'),
    // OptionModel(id: 88, text: 'WIRASWASTA'),
    // OptionModel(id: 89, text: 'LAINNYA'),
  ];

  static List<OptionModel> getJobs() {
    return jobs;
  }

  static List<OptionModel> platinumTenors = [
    OptionModel(id: 12, text: '12 bulan'),
    OptionModel(id: 18, text: '18 bulan'),
    OptionModel(id: 24, text: '24 bulan'),
    OptionModel(id: 30, text: '30 bulan'),
  ];

  static List<OptionModel> getPlatinumTenors() {
    return platinumTenors;
  }

  static List<OptionModel> salaryPlaces = [
    OptionModel(id: 1, text: 'Bank BJB'),
    OptionModel(id: 2, text: 'Bank BTPN'),
  ];

  static List<OptionModel> getSalaryPlacesPlatinum() {
    return salaryPlaces;
  }

  static List<OptionModel> platinumProvinces = [
    OptionModel(id: 1, text: 'SULAWESI UTARA'),
    OptionModel(id: 2, text: 'GORONTALO'),
    OptionModel(id: 3, text: 'SULAWESI SELATAN'),
    OptionModel(id: 4, text: 'SULAWESI BARAT'),
    OptionModel(id: 5, text: 'SULAWESI TENGAH'),
    OptionModel(id: 6, text: 'SULAWESI TENGGARA'),
    OptionModel(id: 7, text: 'KEP. MALUKU'),
    OptionModel(id: 8, text: 'NTT'),
    OptionModel(id: 9, text: 'JAYAPURA'),
    OptionModel(id: 10, text: 'JABODETABEK'),
    OptionModel(id: 11, text: 'JAWA TENGAH'),
    OptionModel(id: 12, text: 'JAWA BARAT'),
    OptionModel(id: 13, text: 'JAWA TIMUR'),
  ];

  static List<OptionModel> getPlatinumProvinces() {
    return platinumProvinces;
  }

  static OptionModel getJobByName(String jobName) {
    final matchedJobs = jobs.where((element) => element.text == jobName);
    if (matchedJobs.isNotEmpty) {
      return matchedJobs.first;
    }
    return OptionModel(id: 0, text: '');
  }

  static OptionModel getPlatinumTenorByName(String tenorName) {
    final matchedTenors =
        platinumTenors.where((element) => element.text == tenorName);
    if (matchedTenors.isNotEmpty) {
      return matchedTenors.first;
    }
    return OptionModel(id: 0, text: '');
  }
}
