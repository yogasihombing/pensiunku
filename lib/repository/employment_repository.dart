import 'package:pensiunku/model/option_model.dart';

class EmploymentRepository {
  static List<OptionModel> institutions = [
    OptionModel(id: 00136, text: 'KEMENTERIAN PERINDUSTRIAN'),
    OptionModel(id: 00291, text: 'KEMENTERIAN NEGARA BUMN'),
    OptionModel(
        id: 00292, text: 'KEMENTERIAN NEGARA PEMBANGUNAN DAERAH TERTINGGAL'),
    OptionModel(id: 00426, text: 'KEMENTERIAN HUKUM DAN HAM'),
    OptionModel(id: 00427, text: 'KEMENTERIAN SEKRETARIAT NEGARA RI'),
    OptionModel(id: 00444, text: 'BADAN KEPEGAWAIAN NEGARA/DAERAH'),
    OptionModel(id: 00447, text: 'BIRO PUSAT STATISTIK (BPS)'),
    OptionModel(id: 00449, text: 'KEMENTERIAN PARIWISATA & EKONOMI KREATIF'),
    OptionModel(
        id: 00450, text: 'KEMENTERIAN PEMBERDAYAAN PEREMPUAN & PERLINDUNGAN .'),
    OptionModel(id: 00451, text: 'KEMENTERIAN PEMUDA & OLAHRAGA'),
    OptionModel(id: 00452, text: 'KEMENTERIAN SOSIAL'),
    OptionModel(id: 00478, text: 'KEMENTERIAN AGAMA'),
    OptionModel(
        id: 00479, text: 'KEMENTERIAN PEKERJAAN UMUM & PERUMAHAN RAKYAT'),
    OptionModel(id: 00531, text: 'KEMENTERIAN DALAM NEGERI'),
    OptionModel(id: 00591, text: 'BADAN METEOROLOGI DAN GEOFISIKA (BMG)'),
    OptionModel(id: 00592, text: 'BANK INDONESIA (BI)'),
    OptionModel(id: 00598, text: 'KEMENTERIAN KOMUNIKASI & INFORMASI'),
    OptionModel(id: 00599, text: 'KEMENTERIAN PERHUBUNGAN'),
    OptionModel(id: 00600, text: 'KEMENTERIAN TENAGA KERJA & TRANSMIGRASI'),
    OptionModel(id: 00633, text: 'KEMENTERIAN KEHUTANAN DAN PERKEBUNAN'),
    OptionModel(id: 00634, text: 'KEMENTERIAN PENDIDIKAN NASIONAL'),
    OptionModel(id: 00635, text: 'KEMENTERIAN PERTANIAN'),
    OptionModel(id: 00712, text: 'BADAN PEMERIKSA KEUANGAN RI'),
    OptionModel(
        id: 00719, text: 'BADAN PENGELOLA HULU MICAS (BPH MICAS) GROUP'),
    OptionModel(id: 00813, text: 'BADAN PERTANAHAN NASIONAL (BPN)'),
    OptionModel(
        id: 00815, text: 'LEMBAGA PENDIDIKAN DAN PENGEMBANGAN PROFESI (LP3I)'),
    OptionModel(id: 00842, text: 'KEMENTERIAN KELAUTAN DAN PERIKANAN'),
    OptionModel(id: 00928, text: 'KEMENTERIAN LINGKUNGAN HIDUP DAN KEHUTANAN'),
    OptionModel(id: 00934, text: 'KEMENTERIAN PERTANIAN'),
    OptionModel(id: 00938, text: 'KEMENTERIAN LUAR NEGERI'),
    OptionModel(id: 01111, text: 'KEMENTERIAN KESEHATAN'),
    OptionModel(id: 01114, text: 'OMBUDSMAN RI'),
    OptionModel(id: 01401, text: 'KEMENTERIAN KELAUTAN & PERIKANAN'),
    OptionModel(id: 01404, text: 'KEMENTERIAN BAPENAS'),
    OptionModel(id: 01444, text: 'KEMENTERIAN KEUANGAN'),
    OptionModel(
        id: 02264, text: 'BADAN KEPENDUDUKAN DAN KELUARGA BERENCANA NASIONAL'),
    OptionModel(
        id: 02265, text: 'BADAN NASIONAL PENANGGULANGAN BENCANA (BNPB)'),
    OptionModel(id: 02266, text: 'BADAN BNP2TKI'),
    OptionModel(id: 02267, text: 'BADAN PENGELOLA DANA DAN PERKEBUNAN SAWIT'),
    OptionModel(id: 01404, text: 'KEMENTERIAN BAPENAS'),
    OptionModel(id: 01444, text: 'KEMENTERIAN KEUANGAN'),
    OptionModel(
        id: 02264, text: 'BADAN KEPENDUDUKAN DAN KELUARGA BERENCANA NASIONAL'),
    OptionModel(
        id: 02265, text: 'BADAN NASIONAL PENANGGULANGAN BENCANA (BNPB)'),
    OptionModel(id: 02266, text: 'BADAN BNP2TKI'),
    OptionModel(id: 02267, text: 'BADAN PENGELOLA DANA DAN PERKEBUNAN SAWIT'),
    OptionModel(id: 02268, text: 'BADAN URUSAN LOGISTIK (BULOG)'),
    OptionModel(id: 02301, text: 'KEMENTERIAN PERTAHANAN GROUP'),
    OptionModel(id: 02518, text: 'KEMENTERIAN DESA PDT DAN TRANSMIGRASI RI'),
    OptionModel(
        id: 02519,
        text: 'KEMENTERIAN ENERGI & SUMBER DAYA MINERAL INDONESIA (ESDM)'),
    OptionModel(id: 02520, text: 'KEMENTERIAN KOPERASI DAN UKM RI'),
    OptionModel(
        id: 02523, text: 'KEMENTERIAN RISET TEKNOLOGI DAN PENDIDIKAN TINGGI'),
    OptionModel(id: 03183, text: 'KOMITE PEMBERANTASAN KORUPSI (KPK)'),
  ];
  static List<OptionModel> groups = [
    OptionModel(id: 1, text: 'Golongan I'),
    OptionModel(id: 2, text: 'Golongan II'),
    OptionModel(id: 3, text: 'Golongan III'),
    OptionModel(id: 4, text: 'Golongan IV'),
  ];
  static List<OptionModel> retirementInstitutions = [
    OptionModel(id: 1, text: 'TASPEN'),
    OptionModel(id: 2, text: 'ASABRI'),
    OptionModel(id: 3, text: 'Dana Pensiun BUMN'),
    OptionModel(id: 4, text: 'Dana Pensiun BUMD'),
  ];

  static List<OptionModel> getInstitutions() {
    return institutions;
  }

  static OptionModel? getInstitutionByText(String text) {
    final matched = institutions.where((element) => element.text == text);
    if (matched.isNotEmpty) {
      return matched.first;
    }
    return null;
  }

  static List<OptionModel> getGroups() {
    return groups;
  }

  static OptionModel? getGroupByText(String text) {
    final matched = groups.where((element) => element.text == text);
    if (matched.isNotEmpty) {
      return matched.first;
    }
    return null;
  }

  static List<OptionModel> getRetirementInstitutions() {
    return retirementInstitutions;
  }

  static OptionModel? getRetirementInstitutionByText(String text) {
    final matched =
        retirementInstitutions.where((element) => element.text == text);
    if (matched.isNotEmpty) {
      return matched.first;
    }
    return null;
  }
}
