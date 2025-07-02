import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/wilayah_api.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/result_model.dart';

class LocationRepository {
  static String tag = 'LocationRepository';

  static List<OptionModel> cities = [
    OptionModel(id: 1101, text: 'KAB. ACEH SELATAN'),
    OptionModel(id: 1102, text: 'KAB. ACEH TENGGARA'),
    OptionModel(id: 1103, text: 'KAB. ACEH TIMUR'),
    OptionModel(id: 1104, text: 'KAB. ACEH TENGAH'),
    OptionModel(id: 1105, text: 'KAB. ACEH BARAT'),
    OptionModel(id: 1106, text: 'KAB. ACEH BESAR'),
    OptionModel(id: 1107, text: 'KAB. PIDIE'),
    OptionModel(id: 1108, text: 'KAB. ACEH UTARA'),
    OptionModel(id: 1109, text: 'KAB. SIMEULUE'),
    OptionModel(id: 1110, text: 'KAB. ACEH SINGKIL'),
    OptionModel(id: 1111, text: 'KAB. BIREUEN'),
    OptionModel(id: 1112, text: 'KAB. ACEH BARAT DAYA'),
    OptionModel(id: 1113, text: 'KAB. GAYO LUES'),
    OptionModel(id: 1114, text: 'KAB. ACEH JAYA'),
    OptionModel(id: 1115, text: 'KAB. NAGAN RAYA'),
    OptionModel(id: 1116, text: 'KAB. ACEH TAMIANG'),
    OptionModel(id: 1117, text: 'KAB. BENER MERIAH'),
    OptionModel(id: 1118, text: 'KAB. PIDIE JAYA'),
    OptionModel(id: 1171, text: 'KOTA BANDA ACEH'),
    OptionModel(id: 1172, text: 'KOTA SABANG'),
    OptionModel(id: 1173, text: 'KOTA LHOKSEUMAWE'),
    OptionModel(id: 1174, text: 'KOTA LANGSA'),
    OptionModel(id: 1175, text: 'KOTA SUBULUSSALAM'),
    OptionModel(id: 1201, text: 'KAB. TAPANULI TENGAH'),
    OptionModel(id: 1202, text: 'KAB. TAPANULI UTARA'),
    OptionModel(id: 1203, text: 'KAB. TAPANULI SELATAN'),
    OptionModel(id: 1204, text: 'KAB. NIAS'),
    OptionModel(id: 1205, text: 'KAB. LANGKAT'),
    OptionModel(id: 1206, text: 'KAB. KARO'),
    OptionModel(id: 1207, text: 'KAB. DELI SERDANG'),
    OptionModel(id: 1208, text: 'KAB. SIMALUNGUN'),
    OptionModel(id: 1209, text: 'KAB. ASAHAN'),
    OptionModel(id: 1210, text: 'KAB. LABUHANBATU'),
    OptionModel(id: 1211, text: 'KAB. DAIRI'),
    OptionModel(id: 1212, text: 'KAB. TOBA SAMOSIR'),
    OptionModel(id: 1213, text: 'KAB. MANDAILING NATAL'),
    OptionModel(id: 1214, text: 'KAB. NIAS SELATAN'),
    OptionModel(id: 1215, text: 'KAB. PAKPAK BHARAT'),
    OptionModel(id: 1216, text: 'KAB. HUMBANG HASUNDUTAN'),
    OptionModel(id: 1217, text: 'KAB. SAMOSIR'),
    OptionModel(id: 1218, text: 'KAB. SERDANG BEDAGAI'),
    OptionModel(id: 1219, text: 'KAB. BATU BARA'),
    OptionModel(id: 1220, text: 'KAB. PADANG LAWAS UTARA'),
    OptionModel(id: 1221, text: 'KAB. PADANG LAWAS'),
    OptionModel(id: 1222, text: 'KAB. LABUHANBATU SELATAN'),
    OptionModel(id: 1223, text: 'KAB. LABUHANBATU UTARA'),
    OptionModel(id: 1224, text: 'KAB. NIAS UTARA'),
    OptionModel(id: 1225, text: 'KAB. NIAS BARAT'),
    OptionModel(id: 1271, text: 'KOTA MEDAN'),
    OptionModel(id: 1272, text: 'KOTA PEMATANGSIANTAR'),
    OptionModel(id: 1273, text: 'KOTA SIBOLGA'),
    OptionModel(id: 1274, text: 'KOTA TANJUNG BALAI'),
    OptionModel(id: 1275, text: 'KOTA BINJAI'),
    OptionModel(id: 1276, text: 'KOTA TEBING TINGGI'),
    OptionModel(id: 1277, text: 'KOTA PADANG SIDEMPUAN'),
    OptionModel(id: 1278, text: 'KOTA GUNUNGSITOLI'),
    OptionModel(id: 1301, text: 'KAB. PESISIR SELATAN'),
    OptionModel(id: 1302, text: 'KAB. SOLOK'),
    OptionModel(id: 1303, text: 'KAB. SIJUNJUNG'),
    OptionModel(id: 1304, text: 'KAB. TANAH DATAR'),
    OptionModel(id: 1305, text: 'KAB. PADANG PARIAMAN'),
    OptionModel(id: 1306, text: 'KAB. AGAM'),
    OptionModel(id: 1307, text: 'KAB. LIMA PULUH KOTA'),
    OptionModel(id: 1308, text: 'KAB. PASAMAN'),
    OptionModel(id: 1309, text: 'KAB. KEPULAUAN MENTAWAI'),
    OptionModel(id: 1310, text: 'KAB. DHARMASRAYA'),
    OptionModel(id: 1311, text: 'KAB. SOLOK SELATAN'),
    OptionModel(id: 1312, text: 'KAB. PASAMAN BARAT'),
    OptionModel(id: 1371, text: 'KOTA PADANG'),
    OptionModel(id: 1372, text: 'KOTA SOLOK'),
    OptionModel(id: 1373, text: 'KOTA SAWAHLUNTO'),
    OptionModel(id: 1374, text: 'KOTA PADANG PANJANG'),
    OptionModel(id: 1375, text: 'KOTA BUKITTINGGI'),
    OptionModel(id: 1376, text: 'KOTA PAYAKUMBUH'),
    OptionModel(id: 1377, text: 'KOTA PARIAMAN'),
    OptionModel(id: 1401, text: 'KAB. KAMPAR'),
    OptionModel(id: 1402, text: 'KAB. INDRAGIRI HULU'),
    OptionModel(id: 1403, text: 'KAB. BENGKALIS'),
    OptionModel(id: 1404, text: 'KAB. INDRAGIRI HILIR'),
    OptionModel(id: 1405, text: 'KAB. PELALAWAN'),
    OptionModel(id: 1406, text: 'KAB. ROKAN HULU'),
    OptionModel(id: 1407, text: 'KAB. ROKAN HILIR'),
    OptionModel(id: 1408, text: 'KAB. SIAK'),
    OptionModel(id: 1409, text: 'KAB. KUANTAN SINGINGI'),
    OptionModel(id: 1410, text: 'KAB. KEPULAUAN MERANTI'),
    OptionModel(id: 1471, text: 'KOTA PEKANBARU'),
    OptionModel(id: 1472, text: 'KOTA DUMAI'),
    OptionModel(id: 1501, text: 'KAB. KERINCI'),
    OptionModel(id: 1502, text: 'KAB. MERANGIN'),
    OptionModel(id: 1503, text: 'KAB. SAROLANGUN'),
    OptionModel(id: 1504, text: 'KAB. BATANGHARI'),
    OptionModel(id: 1505, text: 'KAB. MUARO JAMBI'),
    OptionModel(id: 1506, text: 'KAB. TANJUNG JABUNG BARAT'),
    OptionModel(id: 1507, text: 'KAB. TANJUNG JABUNG TIMUR'),
    OptionModel(id: 1508, text: 'KAB. BUNGO'),
    OptionModel(id: 1509, text: 'KAB. TEBO'),
    OptionModel(id: 1571, text: 'KOTA JAMBI'),
    OptionModel(id: 1572, text: 'KOTA SUNGAI PENUH'),
    OptionModel(id: 1601, text: 'KAB. OGAN KOMERING ULU'),
    OptionModel(id: 1602, text: 'KAB. OGAN KOMERING ILIR'),
    OptionModel(id: 1603, text: 'KAB. MUARA ENIM'),
    OptionModel(id: 1604, text: 'KAB. LAHAT'),
    OptionModel(id: 1605, text: 'KAB. MUSI RAWAS'),
    OptionModel(id: 1606, text: 'KAB. MUSI BANYUASIN'),
    OptionModel(id: 1607, text: 'KAB. BANYUASIN'),
    OptionModel(id: 1608, text: 'KAB. OGAN KOMERING ULU TIMUR'),
    OptionModel(id: 1609, text: 'KAB. OGAN KOMERING ULU SELATAN'),
    OptionModel(id: 1610, text: 'KAB. OGAN ILIR'),
    OptionModel(id: 1611, text: 'KAB. EMPAT LAWANG'),
    OptionModel(id: 1612, text: 'KAB. PENUKAL ABAB LEMATANG ILIR'),
    OptionModel(id: 1613, text: 'KAB. MUSI RAWAS UTARA'),
    OptionModel(id: 1671, text: 'KOTA PALEMBANG'),
    OptionModel(id: 1672, text: 'KOTA PAGAR ALAM'),
    OptionModel(id: 1673, text: 'KOTA LUBUK LINGGAU'),
    OptionModel(id: 1674, text: 'KOTA PRABUMULIH'),
    OptionModel(id: 1701, text: 'KAB. BENGKULU SELATAN'),
    OptionModel(id: 1702, text: 'KAB. REJANG LEBONG'),
    OptionModel(id: 1703, text: 'KAB. BENGKULU UTARA'),
    OptionModel(id: 1704, text: 'KAB. KAUR'),
    OptionModel(id: 1705, text: 'KAB. SELUMA'),
    OptionModel(id: 1706, text: 'KAB. MUKO MUKO'),
    OptionModel(id: 1707, text: 'KAB. LEBONG'),
    OptionModel(id: 1708, text: 'KAB. KEPAHIANG'),
    OptionModel(id: 1709, text: 'KAB. BENGKULU TENGAH'),
    OptionModel(id: 1771, text: 'KOTA BENGKULU'),
    OptionModel(id: 1801, text: 'KAB. LAMPUNG SELATAN'),
    OptionModel(id: 1802, text: 'KAB. LAMPUNG TENGAH'),
    OptionModel(id: 1803, text: 'KAB. LAMPUNG UTARA'),
    OptionModel(id: 1804, text: 'KAB. LAMPUNG BARAT'),
    OptionModel(id: 1805, text: 'KAB. TULANG BAWANG'),
    OptionModel(id: 1806, text: 'KAB. TANGGAMUS'),
    OptionModel(id: 1807, text: 'KAB. LAMPUNG TIMUR'),
    OptionModel(id: 1808, text: 'KAB. WAY KANAN'),
    OptionModel(id: 1809, text: 'KAB. PESAWARAN'),
    OptionModel(id: 1810, text: 'KAB. PRINGSEWU'),
    OptionModel(id: 1811, text: 'KAB. MESUJI'),
    OptionModel(id: 1812, text: 'KAB. TULANG BAWANG BARAT'),
    OptionModel(id: 1813, text: 'KAB. PESISIR BARAT'),
    OptionModel(id: 1871, text: 'KOTA BANDAR LAMPUNG'),
    OptionModel(id: 1872, text: 'KOTA METRO'),
    OptionModel(id: 1901, text: 'KAB. BANGKA'),
    OptionModel(id: 1902, text: 'KAB. BELITUNG'),
    OptionModel(id: 1903, text: 'KAB. BANGKA SELATAN'),
    OptionModel(id: 1904, text: 'KAB. BANGKA TENGAH'),
    OptionModel(id: 1905, text: 'KAB. BANGKA BARAT'),
    OptionModel(id: 1906, text: 'KAB. BELITUNG TIMUR'),
    OptionModel(id: 1971, text: 'KOTA PANGKAL PINANG'),
    OptionModel(id: 2101, text: 'KAB. BINTAN'),
    OptionModel(id: 2102, text: 'KAB. KARIMUN'),
    OptionModel(id: 2103, text: 'KAB. NATUNA'),
    OptionModel(id: 2104, text: 'KAB. LINGGA'),
    OptionModel(id: 2105, text: 'KAB. KEPULAUAN ANAMBAS'),
    OptionModel(id: 2171, text: 'KOTA BATAM'),
    OptionModel(id: 2172, text: 'KOTA TANJUNG PINANG'),
    OptionModel(id: 3101, text: 'KAB. ADM. KEP. SERIBU'),
    OptionModel(id: 3171, text: 'KOTA ADM. JAKARTA PUSAT'),
    OptionModel(id: 3172, text: 'KOTA ADM. JAKARTA UTARA'),
    OptionModel(id: 3173, text: 'KOTA ADM. JAKARTA BARAT'),
    OptionModel(id: 3174, text: 'KOTA ADM. JAKARTA SELATAN'),
    OptionModel(id: 3175, text: 'KOTA ADM. JAKARTA TIMUR'),
    OptionModel(id: 3201, text: 'KAB. BOGOR'),
    OptionModel(id: 3202, text: 'KAB. SUKABUMI'),
    OptionModel(id: 3203, text: 'KAB. CIANJUR'),
    OptionModel(id: 3204, text: 'KAB. BANDUNG'),
    OptionModel(id: 3205, text: 'KAB. GARUT'),
    OptionModel(id: 3206, text: 'KAB. TASIKMALAYA'),
    OptionModel(id: 3207, text: 'KAB. CIAMIS'),
    OptionModel(id: 3208, text: 'KAB. KUNINGAN'),
    OptionModel(id: 3209, text: 'KAB. CIREBON'),
    OptionModel(id: 3210, text: 'KAB. MAJALENGKA'),
    OptionModel(id: 3211, text: 'KAB. SUMEDANG'),
    OptionModel(id: 3212, text: 'KAB. INDRAMAYU'),
    OptionModel(id: 3213, text: 'KAB. SUBANG'),
    OptionModel(id: 3214, text: 'KAB. PURWAKARTA'),
    OptionModel(id: 3215, text: 'KAB. KARAWANG'),
    OptionModel(id: 3216, text: 'KAB. BEKASI'),
    OptionModel(id: 3217, text: 'KAB. BANDUNG BARAT'),
    OptionModel(id: 3218, text: 'KAB. PANGANDARAN'),
    OptionModel(id: 3271, text: 'KOTA BOGOR'),
    OptionModel(id: 3272, text: 'KOTA SUKABUMI'),
    OptionModel(id: 3273, text: 'KOTA BANDUNG'),
    OptionModel(id: 3274, text: 'KOTA CIREBON'),
    OptionModel(id: 3275, text: 'KOTA BEKASI'),
    OptionModel(id: 3276, text: 'KOTA DEPOK'),
    OptionModel(id: 3277, text: 'KOTA CIMAHI'),
    OptionModel(id: 3278, text: 'KOTA TASIKMALAYA'),
    OptionModel(id: 3279, text: 'KOTA BANJAR'),
    OptionModel(id: 3301, text: 'KAB. CILACAP'),
    OptionModel(id: 3302, text: 'KAB. BANYUMAS'),
    OptionModel(id: 3303, text: 'KAB. PURBALINGGA'),
    OptionModel(id: 3304, text: 'KAB. BANJARNEGARA'),
    OptionModel(id: 3305, text: 'KAB. KEBUMEN'),
    OptionModel(id: 3306, text: 'KAB. PURWOREJO'),
    OptionModel(id: 3307, text: 'KAB. WONOSOBO'),
    OptionModel(id: 3308, text: 'KAB. MAGELANG'),
    OptionModel(id: 3309, text: 'KAB. BOYOLALI'),
    OptionModel(id: 3310, text: 'KAB. KLATEN'),
    OptionModel(id: 3311, text: 'KAB. SUKOHARJO'),
    OptionModel(id: 3312, text: 'KAB. WONOGIRI'),
    OptionModel(id: 3313, text: 'KAB. KARANGANYAR'),
    OptionModel(id: 3314, text: 'KAB. SRAGEN'),
    OptionModel(id: 3315, text: 'KAB. GROBOGAN'),
    OptionModel(id: 3316, text: 'KAB. BLORA'),
    OptionModel(id: 3317, text: 'KAB. REMBANG'),
    OptionModel(id: 3318, text: 'KAB. PATI'),
    OptionModel(id: 3319, text: 'KAB. KUDUS'),
    OptionModel(id: 3320, text: 'KAB. JEPARA'),
    OptionModel(id: 3321, text: 'KAB. DEMAK'),
    OptionModel(id: 3322, text: 'KAB. SEMARANG'),
    OptionModel(id: 3323, text: 'KAB. TEMANGGUNG'),
    OptionModel(id: 3324, text: 'KAB. KENDAL'),
    OptionModel(id: 3325, text: 'KAB. BATANG'),
    OptionModel(id: 3326, text: 'KAB. PEKALONGAN'),
    OptionModel(id: 3327, text: 'KAB. PEMALANG'),
    OptionModel(id: 3328, text: 'KAB. TEGAL'),
    OptionModel(id: 3329, text: 'KAB. BREBES'),
    OptionModel(id: 3371, text: 'KOTA MAGELANG'),
    OptionModel(id: 3372, text: 'KOTA SURAKARTA'),
    OptionModel(id: 3373, text: 'KOTA SALATIGA'),
    OptionModel(id: 3374, text: 'KOTA SEMARANG'),
    OptionModel(id: 3375, text: 'KOTA PEKALONGAN'),
    OptionModel(id: 3376, text: 'KOTA TEGAL'),
    OptionModel(id: 3401, text: 'KAB. KULON PROGO'),
    OptionModel(id: 3402, text: 'KAB. BANTUL'),
    OptionModel(id: 3403, text: 'KAB. GUNUNGKIDUL'),
    OptionModel(id: 3404, text: 'KAB. SLEMAN'),
    OptionModel(id: 3471, text: 'KOTA YOGYAKARTA'),
    OptionModel(id: 3501, text: 'KAB. PACITAN'),
    OptionModel(id: 3502, text: 'KAB. PONOROGO'),
    OptionModel(id: 3503, text: 'KAB. TRENGGALEK'),
    OptionModel(id: 3504, text: 'KAB. TULUNGAGUNG'),
    OptionModel(id: 3505, text: 'KAB. BLITAR'),
    OptionModel(id: 3506, text: 'KAB. KEDIRI'),
    OptionModel(id: 3507, text: 'KAB. MALANG'),
    OptionModel(id: 3508, text: 'KAB. LUMAJANG'),
    OptionModel(id: 3509, text: 'KAB. JEMBER'),
    OptionModel(id: 3510, text: 'KAB. BANYUWANGI'),
    OptionModel(id: 3511, text: 'KAB. BONDOWOSO'),
    OptionModel(id: 3512, text: 'KAB. SITUBONDO'),
    OptionModel(id: 3513, text: 'KAB. PROBOLINGGO'),
    OptionModel(id: 3514, text: 'KAB. PASURUAN'),
    OptionModel(id: 3515, text: 'KAB. SIDOARJO'),
    OptionModel(id: 3516, text: 'KAB. MOJOKERTO'),
    OptionModel(id: 3517, text: 'KAB. JOMBANG'),
    OptionModel(id: 3518, text: 'KAB. NGANJUK'),
    OptionModel(id: 3519, text: 'KAB. MADIUN'),
    OptionModel(id: 3520, text: 'KAB. MAGETAN'),
    OptionModel(id: 3521, text: 'KAB. NGAWI'),
    OptionModel(id: 3522, text: 'KAB. BOJONEGORO'),
    OptionModel(id: 3523, text: 'KAB. TUBAN'),
    OptionModel(id: 3524, text: 'KAB. LAMONGAN'),
    OptionModel(id: 3525, text: 'KAB. GRESIK'),
    OptionModel(id: 3526, text: 'KAB. BANGKALAN'),
    OptionModel(id: 3527, text: 'KAB. SAMPANG'),
    OptionModel(id: 3528, text: 'KAB. PAMEKASAN'),
    OptionModel(id: 3529, text: 'KAB. SUMENEP'),
    OptionModel(id: 3571, text: 'KOTA KEDIRI'),
    OptionModel(id: 3572, text: 'KOTA BLITAR'),
    OptionModel(id: 3573, text: 'KOTA MALANG'),
    OptionModel(id: 3574, text: 'KOTA PROBOLINGGO'),
    OptionModel(id: 3575, text: 'KOTA PASURUAN'),
    OptionModel(id: 3576, text: 'KOTA MOJOKERTO'),
    OptionModel(id: 3577, text: 'KOTA MADIUN'),
    OptionModel(id: 3578, text: 'KOTA SURABAYA'),
    OptionModel(id: 3579, text: 'KOTA BATU'),
    OptionModel(id: 3601, text: 'KAB. PANDEGLANG'),
    OptionModel(id: 3602, text: 'KAB. LEBAK'),
    OptionModel(id: 3603, text: 'KAB. TANGERANG'),
    OptionModel(id: 3604, text: 'KAB. SERANG'),
    OptionModel(id: 3671, text: 'KOTA TANGERANG'),
    OptionModel(id: 3672, text: 'KOTA CILEGON'),
    OptionModel(id: 3673, text: 'KOTA SERANG'),
    OptionModel(id: 3674, text: 'KOTA TANGERANG SELATAN'),
    OptionModel(id: 5101, text: 'KAB. JEMBRANA'),
    OptionModel(id: 5102, text: 'KAB. TABANAN'),
    OptionModel(id: 5103, text: 'KAB. BADUNG'),
    OptionModel(id: 5104, text: 'KAB. GIANYAR'),
    OptionModel(id: 5105, text: 'KAB. KLUNGKUNG'),
    OptionModel(id: 5106, text: 'KAB. BANGLI'),
    OptionModel(id: 5107, text: 'KAB. KARANGASEM'),
    OptionModel(id: 5108, text: 'KAB. BULELENG'),
    OptionModel(id: 5171, text: 'KOTA DENPASAR'),
    OptionModel(id: 5201, text: 'KAB. LOMBOK BARAT'),
    OptionModel(id: 5202, text: 'KAB. LOMBOK TENGAH'),
    OptionModel(id: 5203, text: 'KAB. LOMBOK TIMUR'),
    OptionModel(id: 5204, text: 'KAB. SUMBAWA'),
    OptionModel(id: 5205, text: 'KAB. DOMPU'),
    OptionModel(id: 5206, text: 'KAB. BIMA'),
    OptionModel(id: 5207, text: 'KAB. SUMBAWA BARAT'),
    OptionModel(id: 5208, text: 'KAB. LOMBOK UTARA'),
    OptionModel(id: 5271, text: 'KOTA MATARAM'),
    OptionModel(id: 5272, text: 'KOTA BIMA'),
    OptionModel(id: 5301, text: 'KAB. KUPANG'),
    OptionModel(id: 5302, text: 'KAB TIMOR TENGAH SELATAN'),
    OptionModel(id: 5303, text: 'KAB. TIMOR TENGAH UTARA'),
    OptionModel(id: 5304, text: 'KAB. BELU'),
    OptionModel(id: 5305, text: 'KAB. ALOR'),
    OptionModel(id: 5306, text: 'KAB. FLORES TIMUR'),
    OptionModel(id: 5307, text: 'KAB. SIKKA'),
    OptionModel(id: 5308, text: 'KAB. ENDE'),
    OptionModel(id: 5309, text: 'KAB. NGADA'),
    OptionModel(id: 5310, text: 'KAB. MANGGARAI'),
    OptionModel(id: 5311, text: 'KAB. SUMBA TIMUR'),
    OptionModel(id: 5312, text: 'KAB. SUMBA BARAT'),
    OptionModel(id: 5313, text: 'KAB. LEMBATA'),
    OptionModel(id: 5314, text: 'KAB. ROTE NDAO'),
    OptionModel(id: 5315, text: 'KAB. MANGGARAI BARAT'),
    OptionModel(id: 5316, text: 'KAB. NAGEKEO'),
    OptionModel(id: 5317, text: 'KAB. SUMBA TENGAH'),
    OptionModel(id: 5318, text: 'KAB. SUMBA BARAT DAYA'),
    OptionModel(id: 5319, text: 'KAB. MANGGARAI TIMUR'),
    OptionModel(id: 5320, text: 'KAB. SABU RAIJUA'),
    OptionModel(id: 5321, text: 'KAB. MALAKA'),
    OptionModel(id: 5371, text: 'KOTA KUPANG'),
    OptionModel(id: 6101, text: 'KAB. SAMBAS'),
    OptionModel(id: 6102, text: 'KAB. MEMPAWAH'),
    OptionModel(id: 6103, text: 'KAB. SANGGAU'),
    OptionModel(id: 6104, text: 'KAB. KETAPANG'),
    OptionModel(id: 6105, text: 'KAB. SINTANG'),
    OptionModel(id: 6106, text: 'KAB. KAPUAS HULU'),
    OptionModel(id: 6107, text: 'KAB. BENGKAYANG'),
    OptionModel(id: 6108, text: 'KAB. LANDAK'),
    OptionModel(id: 6109, text: 'KAB. SEKADAU'),
    OptionModel(id: 6110, text: 'KAB. MELAWI'),
    OptionModel(id: 6111, text: 'KAB. KAYONG UTARA'),
    OptionModel(id: 6112, text: 'KAB. KUBU RAYA'),
    OptionModel(id: 6171, text: 'KOTA PONTIANAK'),
    OptionModel(id: 6172, text: 'KOTA SINGKAWANG'),
    OptionModel(id: 6201, text: 'KAB. KOTAWARINGIN BARAT'),
    OptionModel(id: 6202, text: 'KAB. KOTAWARINGIN TIMUR'),
    OptionModel(id: 6203, text: 'KAB. KAPUAS'),
    OptionModel(id: 6204, text: 'KAB. BARITO SELATAN'),
    OptionModel(id: 6205, text: 'KAB. BARITO UTARA'),
    OptionModel(id: 6206, text: 'KAB. KATINGAN'),
    OptionModel(id: 6207, text: 'KAB. SERUYAN'),
    OptionModel(id: 6208, text: 'KAB. SUKAMARA'),
    OptionModel(id: 6209, text: 'KAB. LAMANDAU'),
    OptionModel(id: 6210, text: 'KAB. GUNUNG MAS'),
    OptionModel(id: 6211, text: 'KAB. PULANG PISAU'),
    OptionModel(id: 6212, text: 'KAB. MURUNG RAYA'),
    OptionModel(id: 6213, text: 'KAB. BARITO TIMUR'),
    OptionModel(id: 6271, text: 'KOTA PALANGKARAYA'),
    OptionModel(id: 6301, text: 'KAB. TANAH LAUT'),
    OptionModel(id: 6302, text: 'KAB. KOTABARU'),
    OptionModel(id: 6303, text: 'KAB. BANJAR'),
    OptionModel(id: 6304, text: 'KAB. BARITO KUALA'),
    OptionModel(id: 6305, text: 'KAB. TAPIN'),
    OptionModel(id: 6306, text: 'KAB. HULU SUNGAI SELATAN'),
    OptionModel(id: 6307, text: 'KAB. HULU SUNGAI TENGAH'),
    OptionModel(id: 6308, text: 'KAB. HULU SUNGAI UTARA'),
    OptionModel(id: 6309, text: 'KAB. TABALONG'),
    OptionModel(id: 6310, text: 'KAB. TANAH BUMBU'),
    OptionModel(id: 6311, text: 'KAB. BALANGAN'),
    OptionModel(id: 6371, text: 'KOTA BANJARMASIN'),
    OptionModel(id: 6372, text: 'KOTA BANJARBARU'),
    OptionModel(id: 6401, text: 'KAB. PASER'),
    OptionModel(id: 6402, text: 'KAB. KUTAI KARTANEGARA'),
    OptionModel(id: 6403, text: 'KAB. BERAU'),
    OptionModel(id: 6407, text: 'KAB. KUTAI BARAT'),
    OptionModel(id: 6408, text: 'KAB. KUTAI TIMUR'),
    OptionModel(id: 6409, text: 'KAB. PENAJAM PASER UTARA'),
    OptionModel(id: 6411, text: 'KAB. MAHAKAM ULU'),
    OptionModel(id: 6471, text: 'KOTA BALIKPAPAN'),
    OptionModel(id: 6472, text: 'KOTA SAMARINDA'),
    OptionModel(id: 6474, text: 'KOTA BONTANG'),
    OptionModel(id: 6501, text: 'KAB. BULUNGAN'),
    OptionModel(id: 6502, text: 'KAB. MALINAU'),
    OptionModel(id: 6503, text: 'KAB. NUNUKAN'),
    OptionModel(id: 6504, text: 'KAB. TANA TIDUNG'),
    OptionModel(id: 6571, text: 'KOTA TARAKAN'),
    OptionModel(id: 7101, text: 'KAB. BOLAANG MONGONDOW'),
    OptionModel(id: 7102, text: 'KAB. MINAHASA'),
    OptionModel(id: 7103, text: 'KAB. KEPULAUAN SANGIHE'),
    OptionModel(id: 7104, text: 'KAB. KEPULAUAN TALAUD'),
    OptionModel(id: 7105, text: 'KAB. MINAHASA SELATAN'),
    OptionModel(id: 7106, text: 'KAB. MINAHASA UTARA'),
    OptionModel(id: 7107, text: 'KAB. MINAHASA TENGGARA'),
    OptionModel(id: 7108, text: 'KAB. BOLAANG MONGONDOW UTARA'),
    OptionModel(id: 7109, text: 'KAB. KEP. SIAU TAGULANDANG BIARO'),
    OptionModel(id: 7110, text: 'KAB. BOLAANG MONGONDOW TIMUR'),
    OptionModel(id: 7111, text: 'KAB. BOLAANG MONGONDOW SELATAN'),
    OptionModel(id: 7171, text: 'KOTA MANADO'),
    OptionModel(id: 7172, text: 'KOTA BITUNG'),
    OptionModel(id: 7173, text: 'KOTA TOMOHON'),
    OptionModel(id: 7174, text: 'KOTA KOTAMOBAGU'),
    OptionModel(id: 7201, text: 'KAB. BANGGAI'),
    OptionModel(id: 7202, text: 'KAB. POSO'),
    OptionModel(id: 7203, text: 'KAB. DONGGALA'),
    OptionModel(id: 7204, text: 'KAB. TOLI TOLI'),
    OptionModel(id: 7205, text: 'KAB. BUOL'),
    OptionModel(id: 7206, text: 'KAB. MOROWALI'),
    OptionModel(id: 7207, text: 'KAB. BANGGAI KEPULAUAN'),
    OptionModel(id: 7208, text: 'KAB. PARIGI MOUTONG'),
    OptionModel(id: 7209, text: 'KAB. TOJO UNA UNA'),
    OptionModel(id: 7210, text: 'KAB. SIGI'),
    OptionModel(id: 7211, text: 'KAB. BANGGAI LAUT'),
    OptionModel(id: 7212, text: 'KAB. MOROWALI UTARA'),
    OptionModel(id: 7271, text: 'KOTA PALU'),
    OptionModel(id: 7301, text: 'KAB. KEPULAUAN SELAYAR'),
    OptionModel(id: 7302, text: 'KAB. BULUKUMBA'),
    OptionModel(id: 7303, text: 'KAB. BANTAENG'),
    OptionModel(id: 7304, text: 'KAB. JENEPONTO'),
    OptionModel(id: 7305, text: 'KAB. TAKALAR'),
    OptionModel(id: 7306, text: 'KAB. GOWA'),
    OptionModel(id: 7307, text: 'KAB. SINJAI'),
    OptionModel(id: 7308, text: 'KAB. BONE'),
    OptionModel(id: 7309, text: 'KAB. MAROS'),
    OptionModel(id: 7310, text: 'KAB. PANGKAJENE KEPULAUAN'),
    OptionModel(id: 7311, text: 'KAB. BARRU'),
    OptionModel(id: 7312, text: 'KAB. SOPPENG'),
    OptionModel(id: 7313, text: 'KAB. WAJO'),
    OptionModel(id: 7314, text: 'KAB. SIDENRENG RAPPANG'),
    OptionModel(id: 7315, text: 'KAB. PINRANG'),
    OptionModel(id: 7316, text: 'KAB. ENREKANG'),
    OptionModel(id: 7317, text: 'KAB. LUWU'),
    OptionModel(id: 7318, text: 'KAB. TANA TORAJA'),
    OptionModel(id: 7322, text: 'KAB. LUWU UTARA'),
    OptionModel(id: 7324, text: 'KAB. LUWU TIMUR'),
    OptionModel(id: 7326, text: 'KAB. TORAJA UTARA'),
    OptionModel(id: 7371, text: 'KOTA MAKASSAR'),
    OptionModel(id: 7372, text: 'KOTA PARE PARE'),
    OptionModel(id: 7373, text: 'KOTA PALOPO'),
    OptionModel(id: 7401, text: 'KAB. KOLAKA'),
    OptionModel(id: 7402, text: 'KAB. KONAWE'),
    OptionModel(id: 7403, text: 'KAB. MUNA'),
    OptionModel(id: 7404, text: 'KAB. BUTON'),
    OptionModel(id: 7405, text: 'KAB. KONAWE SELATAN'),
    OptionModel(id: 7406, text: 'KAB. BOMBANA'),
    OptionModel(id: 7407, text: 'KAB. WAKATOBI'),
    OptionModel(id: 7408, text: 'KAB. KOLAKA UTARA'),
    OptionModel(id: 7409, text: 'KAB. KONAWE UTARA'),
    OptionModel(id: 7410, text: 'KAB. BUTON UTARA'),
    OptionModel(id: 7411, text: 'KAB. KOLAKA TIMUR'),
    OptionModel(id: 7412, text: 'KAB. KONAWE KEPULAUAN'),
    OptionModel(id: 7413, text: 'KAB. MUNA BARAT'),
    OptionModel(id: 7414, text: 'KAB. BUTON TENGAH'),
    OptionModel(id: 7415, text: 'KAB. BUTON SELATAN'),
    OptionModel(id: 7471, text: 'KOTA KENDARI'),
    OptionModel(id: 7472, text: 'KOTA BAU BAU'),
    OptionModel(id: 7501, text: 'KAB. GORONTALO'),
    OptionModel(id: 7502, text: 'KAB. BOALEMO'),
    OptionModel(id: 7503, text: 'KAB. BONE BOLANGO'),
    OptionModel(id: 7504, text: 'KAB. PAHUWATO'),
    OptionModel(id: 7505, text: 'KAB. GORONTALO UTARA'),
    OptionModel(id: 7571, text: 'KOTA GORONTALO'),
    OptionModel(id: 7601, text: 'KAB. PASANGKAYU'),
    OptionModel(id: 7602, text: 'KAB. MAMUJU'),
    OptionModel(id: 7603, text: 'KAB. MAMASA'),
    OptionModel(id: 7604, text: 'KAB. POLEWALI MANDAR'),
    OptionModel(id: 7605, text: 'KAB. MAJENE'),
    OptionModel(id: 7606, text: 'KAB. MAMUJU TENGAH'),
    OptionModel(id: 8101, text: 'KAB. MALUKU TENGAH'),
    OptionModel(id: 8102, text: 'KAB. MALUKU TENGGARA'),
    OptionModel(id: 8103, text: 'KAB. KEPULAUAN TANIMBAR'),
    OptionModel(id: 8104, text: 'KAB. BURU'),
    OptionModel(id: 8105, text: 'KAB. SERAM BAGIAN TIMUR'),
    OptionModel(id: 8106, text: 'KAB. SERAM BAGIAN BARAT'),
    OptionModel(id: 8107, text: 'KAB. KEPULAUAN ARU'),
    OptionModel(id: 8108, text: 'KAB. MALUKU BARAT DAYA'),
    OptionModel(id: 8109, text: 'KAB. BURU SELATAN'),
    OptionModel(id: 8171, text: 'KOTA AMBON'),
    OptionModel(id: 8172, text: 'KOTA TUAL'),
    OptionModel(id: 8201, text: 'KAB. HALMAHERA BARAT'),
    OptionModel(id: 8202, text: 'KAB. HALMAHERA TENGAH'),
    OptionModel(id: 8203, text: 'KAB. HALMAHERA UTARA'),
    OptionModel(id: 8204, text: 'KAB. HALMAHERA SELATAN'),
    OptionModel(id: 8205, text: 'KAB. KEPULAUAN SULA'),
    OptionModel(id: 8206, text: 'KAB. HALMAHERA TIMUR'),
    OptionModel(id: 8207, text: 'KAB. PULAU MOROTAI'),
    OptionModel(id: 8208, text: 'KAB. PULAU TALIABU'),
    OptionModel(id: 8271, text: 'KOTA TERNATE'),
    OptionModel(id: 8272, text: 'KOTA TIDORE KEPULAUAN'),
    OptionModel(id: 9101, text: 'KAB. MERAUKE'),
    OptionModel(id: 9102, text: 'KAB. JAYAWIJAYA'),
    OptionModel(id: 9103, text: 'KAB. JAYAPURA'),
    OptionModel(id: 9104, text: 'KAB. NABIRE'),
    OptionModel(id: 9105, text: 'KAB. KEPULAUAN YAPEN'),
    OptionModel(id: 9106, text: 'KAB. BIAK NUMFOR'),
    OptionModel(id: 9107, text: 'KAB. PUNCAK JAYA'),
    OptionModel(id: 9108, text: 'KAB. PANIAI'),
    OptionModel(id: 9109, text: 'KAB. MIMIKA'),
    OptionModel(id: 9110, text: 'KAB. SARMI'),
    OptionModel(id: 9111, text: 'KAB. KEEROM'),
    OptionModel(id: 9112, text: 'KAB PEGUNUNGAN BINTANG'),
    OptionModel(id: 9113, text: 'KAB. YAHUKIMO'),
    OptionModel(id: 9114, text: 'KAB. TOLIKARA'),
    OptionModel(id: 9115, text: 'KAB. WAROPEN'),
    OptionModel(id: 9116, text: 'KAB. BOVEN DIGOEL'),
    OptionModel(id: 9117, text: 'KAB. MAPPI'),
    OptionModel(id: 9118, text: 'KAB. ASMAT'),
    OptionModel(id: 9119, text: 'KAB. SUPIORI'),
    OptionModel(id: 9120, text: 'KAB. MAMBERAMO RAYA'),
    OptionModel(id: 9121, text: 'KAB. MAMBERAMO TENGAH'),
    OptionModel(id: 9122, text: 'KAB. YALIMO'),
    OptionModel(id: 9123, text: 'KAB. LANNY JAYA'),
    OptionModel(id: 9124, text: 'KAB. NDUGA'),
    OptionModel(id: 9125, text: 'KAB. PUNCAK'),
    OptionModel(id: 9126, text: 'KAB. DOGIYAI'),
    OptionModel(id: 9127, text: 'KAB. INTAN JAYA'),
    OptionModel(id: 9128, text: 'KAB. DEIYAI'),
    OptionModel(id: 9171, text: 'KOTA JAYAPURA'),
    OptionModel(id: 9201, text: 'KAB. SORONG'),
    OptionModel(id: 9202, text: 'KAB. MANOKWARI'),
    OptionModel(id: 9203, text: 'KAB. FAK FAK'),
    OptionModel(id: 9204, text: 'KAB. SORONG SELATAN'),
    OptionModel(id: 9205, text: 'KAB. RAJA AMPAT'),
    OptionModel(id: 9206, text: 'KAB. TELUK BINTUNI'),
    OptionModel(id: 9207, text: 'KAB. TELUK WONDAMA'),
    OptionModel(id: 9208, text: 'KAB. KAIMANA'),
    OptionModel(id: 9209, text: 'KAB. TAMBRAUW'),
    OptionModel(id: 9210, text: 'KAB. MAYBRAT'),
    OptionModel(id: 9211, text: 'KAB. MANOKWARI SELATAN'),
    OptionModel(id: 9212, text: 'KAB. PEGUNUNGAN ARFAK'),
    OptionModel(id: 9271, text: 'KOTA SORONG'),
  ];

  static List<OptionModel> provinces = [
    OptionModel(id: 11, text: 'ACEH'),
    OptionModel(id: 12, text: 'SUMATERA UTARA'),
    OptionModel(id: 13, text: 'SUMATERA BARAT'),
    OptionModel(id: 14, text: 'RIAU'),
    OptionModel(id: 15, text: 'JAMBI'),
    OptionModel(id: 16, text: 'SUMATERA SELATAN'),
    OptionModel(id: 17, text: 'BENGKULU'),
    OptionModel(id: 18, text: 'LAMPUNG'),
    OptionModel(id: 19, text: 'KEPULAUAN BANGKA BELITUNG'),
    OptionModel(id: 21, text: 'KEPULAUAN RIAU'),
    OptionModel(id: 31, text: 'DKI JAKARTA'),
    OptionModel(id: 32, text: 'JAWA BARAT'),
    OptionModel(id: 33, text: 'JAWA TENGAH'),
    OptionModel(id: 34, text: 'DAERAH ISTIMEWA YOGYAKARTA'),
    OptionModel(id: 35, text: 'JAWA TIMUR'),
    OptionModel(id: 36, text: 'BANTEN'),
    OptionModel(id: 51, text: 'BALI'),
    OptionModel(id: 52, text: 'NUSA TENGGARA BARAT'),
    OptionModel(id: 53, text: 'NUSA TENGGARA TIMUR'),
    OptionModel(id: 61, text: 'KALIMANTAN BARAT'),
    OptionModel(id: 62, text: 'KALIMANTAN TENGAH'),
    OptionModel(id: 63, text: 'KALIMANTAN SELATAN'),
    OptionModel(id: 64, text: 'KALIMANTAN TIMUR'),
    OptionModel(id: 65, text: 'KALIMANTAN UTARA'),
    OptionModel(id: 71, text: 'SULAWESI UTARA'),
    OptionModel(id: 72, text: 'SULAWESI TENGAH'),
    OptionModel(id: 73, text: 'SULAWESI SELATAN'),
    OptionModel(id: 74, text: 'SULAWESI TENGGARA'),
    OptionModel(id: 75, text: 'GORONTALO'),
    OptionModel(id: 76, text: 'SULAWESI BARAT'),
    OptionModel(id: 81, text: 'MALUKU'),
    OptionModel(id: 82, text: 'MALUKU UTARA'),
    OptionModel(id: 91, text: 'PAPUA'),
    OptionModel(id: 92, text: 'PAPUA BARAT'),
  ];

  static List<OptionModel> getProvinces() {
    return provinces;
  }

  static List<OptionModel> getCity(int? provinceId) {
    switch (provinceId) {
      case 11:
        return [
          OptionModel(id: 1101, text: 'KAB. ACEH SELATAN'),
          OptionModel(id: 1102, text: 'KAB. ACEH TENGGARA'),
          OptionModel(id: 1103, text: 'KAB. ACEH TIMUR'),
          OptionModel(id: 1104, text: 'KAB. ACEH TENGAH'),
          OptionModel(id: 1105, text: 'KAB. ACEH BARAT'),
          OptionModel(id: 1106, text: 'KAB. ACEH BESAR'),
          OptionModel(id: 1107, text: 'KAB. PIDIE'),
          OptionModel(id: 1108, text: 'KAB. ACEH UTARA'),
          OptionModel(id: 1109, text: 'KAB. SIMEULUE'),
          OptionModel(id: 1110, text: 'KAB. ACEH SINGKIL'),
          OptionModel(id: 1111, text: 'KAB. BIREUEN'),
          OptionModel(id: 1112, text: 'KAB. ACEH BARAT DAYA'),
          OptionModel(id: 1113, text: 'KAB. GAYO LUES'),
          OptionModel(id: 1114, text: 'KAB. ACEH JAYA'),
          OptionModel(id: 1115, text: 'KAB. NAGAN RAYA'),
          OptionModel(id: 1116, text: 'KAB. ACEH TAMIANG'),
          OptionModel(id: 1117, text: 'KAB. BENER MERIAH'),
          OptionModel(id: 1118, text: 'KAB. PIDIE JAYA'),
          OptionModel(id: 1171, text: 'KOTA BANDA ACEH'),
          OptionModel(id: 1172, text: 'KOTA SABANG'),
          OptionModel(id: 1173, text: 'KOTA LHOKSEUMAWE'),
          OptionModel(id: 1174, text: 'KOTA LANGSA'),
          OptionModel(id: 1175, text: 'KOTA SUBULUSSALAM'),
        ];
      case 12:
        return [
          OptionModel(id: 1201, text: 'KAB. TAPANULI TENGAH'),
          OptionModel(id: 1202, text: 'KAB. TAPANULI UTARA'),
          OptionModel(id: 1203, text: 'KAB. TAPANULI SELATAN'),
          OptionModel(id: 1204, text: 'KAB. NIAS'),
          OptionModel(id: 1205, text: 'KAB. LANGKAT'),
          OptionModel(id: 1206, text: 'KAB. KARO'),
          OptionModel(id: 1207, text: 'KAB. DELI SERDANG'),
          OptionModel(id: 1208, text: 'KAB. SIMALUNGUN'),
          OptionModel(id: 1209, text: 'KAB. ASAHAN'),
          OptionModel(id: 1210, text: 'KAB. LABUHANBATU'),
          OptionModel(id: 1211, text: 'KAB. DAIRI'),
          OptionModel(id: 1212, text: 'KAB. TOBA SAMOSIR'),
          OptionModel(id: 1213, text: 'KAB. MANDAILING NATAL'),
          OptionModel(id: 1214, text: 'KAB. NIAS SELATAN'),
          OptionModel(id: 1215, text: 'KAB. PAKPAK BHARAT'),
          OptionModel(id: 1216, text: 'KAB. HUMBANG HASUNDUTAN'),
          OptionModel(id: 1217, text: 'KAB. SAMOSIR'),
          OptionModel(id: 1218, text: 'KAB. SERDANG BEDAGAI'),
          OptionModel(id: 1219, text: 'KAB. BATU BARA'),
          OptionModel(id: 1220, text: 'KAB. PADANG LAWAS UTARA'),
          OptionModel(id: 1221, text: 'KAB. PADANG LAWAS'),
          OptionModel(id: 1222, text: 'KAB. LABUHANBATU SELATAN'),
          OptionModel(id: 1223, text: 'KAB. LABUHANBATU UTARA'),
          OptionModel(id: 1224, text: 'KAB. NIAS UTARA'),
          OptionModel(id: 1225, text: 'KAB. NIAS BARAT'),
          OptionModel(id: 1271, text: 'KOTA MEDAN'),
          OptionModel(id: 1272, text: 'KOTA PEMATANGSIANTAR'),
          OptionModel(id: 1273, text: 'KOTA SIBOLGA'),
          OptionModel(id: 1274, text: 'KOTA TANJUNG BALAI'),
          OptionModel(id: 1275, text: 'KOTA BINJAI'),
          OptionModel(id: 1276, text: 'KOTA TEBING TINGGI'),
          OptionModel(id: 1277, text: 'KOTA PADANG SIDEMPUAN'),
          OptionModel(id: 1278, text: 'KOTA GUNUNGSITOLI'),
        ];
      case 13:
        return [
          OptionModel(id: 1301, text: 'KAB. PESISIR SELATAN'),
          OptionModel(id: 1302, text: 'KAB. SOLOK'),
          OptionModel(id: 1303, text: 'KAB. SIJUNJUNG'),
          OptionModel(id: 1304, text: 'KAB. TANAH DATAR'),
          OptionModel(id: 1305, text: 'KAB. PADANG PARIAMAN'),
          OptionModel(id: 1306, text: 'KAB. AGAM'),
          OptionModel(id: 1307, text: 'KAB. LIMA PULUH KOTA'),
          OptionModel(id: 1308, text: 'KAB. PASAMAN'),
          OptionModel(id: 1309, text: 'KAB. KEPULAUAN MENTAWAI'),
          OptionModel(id: 1310, text: 'KAB. DHARMASRAYA'),
          OptionModel(id: 1311, text: 'KAB. SOLOK SELATAN'),
          OptionModel(id: 1312, text: 'KAB. PASAMAN BARAT'),
          OptionModel(id: 1371, text: 'KOTA PADANG'),
          OptionModel(id: 1372, text: 'KOTA SOLOK'),
          OptionModel(id: 1373, text: 'KOTA SAWAHLUNTO'),
          OptionModel(id: 1374, text: 'KOTA PADANG PANJANG'),
          OptionModel(id: 1375, text: 'KOTA BUKITTINGGI'),
          OptionModel(id: 1376, text: 'KOTA PAYAKUMBUH'),
          OptionModel(id: 1377, text: 'KOTA PARIAMAN'),
        ];
      case 14:
        return [
          OptionModel(id: 1401, text: 'KAB. KAMPAR'),
          OptionModel(id: 1402, text: 'KAB. INDRAGIRI HULU'),
          OptionModel(id: 1403, text: 'KAB. BENGKALIS'),
          OptionModel(id: 1404, text: 'KAB. INDRAGIRI HILIR'),
          OptionModel(id: 1405, text: 'KAB. PELALAWAN'),
          OptionModel(id: 1406, text: 'KAB. ROKAN HULU'),
          OptionModel(id: 1407, text: 'KAB. ROKAN HILIR'),
          OptionModel(id: 1408, text: 'KAB. SIAK'),
          OptionModel(id: 1409, text: 'KAB. KUANTAN SINGINGI'),
          OptionModel(id: 1410, text: 'KAB. KEPULAUAN MERANTI'),
          OptionModel(id: 1471, text: 'KOTA PEKANBARU'),
          OptionModel(id: 1472, text: 'KOTA DUMAI'),
        ];
      case 15:
        return [
          OptionModel(id: 1501, text: 'KAB. KERINCI'),
          OptionModel(id: 1502, text: 'KAB. MERANGIN'),
          OptionModel(id: 1503, text: 'KAB. SAROLANGUN'),
          OptionModel(id: 1504, text: 'KAB. BATANGHARI'),
          OptionModel(id: 1505, text: 'KAB. MUARO JAMBI'),
          OptionModel(id: 1506, text: 'KAB. TANJUNG JABUNG BARAT'),
          OptionModel(id: 1507, text: 'KAB. TANJUNG JABUNG TIMUR'),
          OptionModel(id: 1508, text: 'KAB. BUNGO'),
          OptionModel(id: 1509, text: 'KAB. TEBO'),
          OptionModel(id: 1571, text: 'KOTA JAMBI'),
          OptionModel(id: 1572, text: 'KOTA SUNGAI PENUH'),
        ];
      case 16:
        return [
          OptionModel(id: 1601, text: 'KAB. OGAN KOMERING ULU'),
          OptionModel(id: 1602, text: 'KAB. OGAN KOMERING ILIR'),
          OptionModel(id: 1603, text: 'KAB. MUARA ENIM'),
          OptionModel(id: 1604, text: 'KAB. LAHAT'),
          OptionModel(id: 1605, text: 'KAB. MUSI RAWAS'),
          OptionModel(id: 1606, text: 'KAB. MUSI BANYUASIN'),
          OptionModel(id: 1607, text: 'KAB. BANYUASIN'),
          OptionModel(id: 1608, text: 'KAB. OGAN KOMERING ULU TIMUR'),
          OptionModel(id: 1609, text: 'KAB. OGAN KOMERING ULU SELATAN'),
          OptionModel(id: 1610, text: 'KAB. OGAN ILIR'),
          OptionModel(id: 1611, text: 'KAB. EMPAT LAWANG'),
          OptionModel(id: 1612, text: 'KAB. PENUKAL ABAB LEMATANG ILIR'),
          OptionModel(id: 1613, text: 'KAB. MUSI RAWAS UTARA'),
          OptionModel(id: 1671, text: 'KOTA PALEMBANG'),
          OptionModel(id: 1672, text: 'KOTA PAGAR ALAM'),
          OptionModel(id: 1673, text: 'KOTA LUBUK LINGGAU'),
          OptionModel(id: 1674, text: 'KOTA PRABUMULIH'),
        ];
      case 17:
        return [
          OptionModel(id: 1701, text: 'KAB. BENGKULU SELATAN'),
          OptionModel(id: 1702, text: 'KAB. REJANG LEBONG'),
          OptionModel(id: 1703, text: 'KAB. BENGKULU UTARA'),
          OptionModel(id: 1704, text: 'KAB. KAUR'),
          OptionModel(id: 1705, text: 'KAB. SELUMA'),
          OptionModel(id: 1706, text: 'KAB. MUKO MUKO'),
          OptionModel(id: 1707, text: 'KAB. LEBONG'),
          OptionModel(id: 1708, text: 'KAB. KEPAHIANG'),
          OptionModel(id: 1709, text: 'KAB. BENGKULU TENGAH'),
          OptionModel(id: 1771, text: 'KOTA BENGKULU'),
        ];
      case 18:
        return [
          OptionModel(id: 1801, text: 'KAB. LAMPUNG SELATAN'),
          OptionModel(id: 1802, text: 'KAB. LAMPUNG TENGAH'),
          OptionModel(id: 1803, text: 'KAB. LAMPUNG UTARA'),
          OptionModel(id: 1804, text: 'KAB. LAMPUNG BARAT'),
          OptionModel(id: 1805, text: 'KAB. TULANG BAWANG'),
          OptionModel(id: 1806, text: 'KAB. TANGGAMUS'),
          OptionModel(id: 1807, text: 'KAB. LAMPUNG TIMUR'),
          OptionModel(id: 1808, text: 'KAB. WAY KANAN'),
          OptionModel(id: 1809, text: 'KAB. PESAWARAN'),
          OptionModel(id: 1810, text: 'KAB. PRINGSEWU'),
          OptionModel(id: 1811, text: 'KAB. MESUJI'),
          OptionModel(id: 1812, text: 'KAB. TULANG BAWANG BARAT'),
          OptionModel(id: 1813, text: 'KAB. PESISIR BARAT'),
          OptionModel(id: 1871, text: 'KOTA BANDAR LAMPUNG'),
          OptionModel(id: 1872, text: 'KOTA METRO'),
        ];
      case 19:
        return [
          OptionModel(id: 1901, text: 'KAB. BANGKA'),
          OptionModel(id: 1902, text: 'KAB. BELITUNG'),
          OptionModel(id: 1903, text: 'KAB. BANGKA SELATAN'),
          OptionModel(id: 1904, text: 'KAB. BANGKA TENGAH'),
          OptionModel(id: 1905, text: 'KAB. BANGKA BARAT'),
          OptionModel(id: 1906, text: 'KAB. BELITUNG TIMUR'),
          OptionModel(id: 1971, text: 'KOTA PANGKAL PINANG'),
        ];
      case 21:
        return [
          OptionModel(id: 2101, text: 'KAB. BINTAN'),
          OptionModel(id: 2102, text: 'KAB. KARIMUN'),
          OptionModel(id: 2103, text: 'KAB. NATUNA'),
          OptionModel(id: 2104, text: 'KAB. LINGGA'),
          OptionModel(id: 2105, text: 'KAB. KEPULAUAN ANAMBAS'),
          OptionModel(id: 2171, text: 'KOTA BATAM'),
          OptionModel(id: 2172, text: 'KOTA TANJUNG PINANG'),
        ];
      case 31:
        return [
          OptionModel(id: 3101, text: 'KAB. ADM. KEP. SERIBU'),
          OptionModel(id: 3171, text: 'KOTA ADM. JAKARTA PUSAT'),
          OptionModel(id: 3172, text: 'KOTA ADM. JAKARTA UTARA'),
          OptionModel(id: 3173, text: 'KOTA ADM. JAKARTA BARAT'),
          OptionModel(id: 3174, text: 'KOTA ADM. JAKARTA SELATAN'),
          OptionModel(id: 3175, text: 'KOTA ADM. JAKARTA TIMUR'),
        ];
      case 32:
        return [
          OptionModel(id: 3201, text: 'KAB. BOGOR'),
          OptionModel(id: 3202, text: 'KAB. SUKABUMI'),
          OptionModel(id: 3203, text: 'KAB. CIANJUR'),
          OptionModel(id: 3204, text: 'KAB. BANDUNG'),
          OptionModel(id: 3205, text: 'KAB. GARUT'),
          OptionModel(id: 3206, text: 'KAB. TASIKMALAYA'),
          OptionModel(id: 3207, text: 'KAB. CIAMIS'),
          OptionModel(id: 3208, text: 'KAB. KUNINGAN'),
          OptionModel(id: 3209, text: 'KAB. CIREBON'),
          OptionModel(id: 3210, text: 'KAB. MAJALENGKA'),
          OptionModel(id: 3211, text: 'KAB. SUMEDANG'),
          OptionModel(id: 3212, text: 'KAB. INDRAMAYU'),
          OptionModel(id: 3213, text: 'KAB. SUBANG'),
          OptionModel(id: 3214, text: 'KAB. PURWAKARTA'),
          OptionModel(id: 3215, text: 'KAB. KARAWANG'),
          OptionModel(id: 3216, text: 'KAB. BEKASI'),
          OptionModel(id: 3217, text: 'KAB. BANDUNG BARAT'),
          OptionModel(id: 3218, text: 'KAB. PANGANDARAN'),
          OptionModel(id: 3271, text: 'KOTA BOGOR'),
          OptionModel(id: 3272, text: 'KOTA SUKABUMI'),
          OptionModel(id: 3273, text: 'KOTA BANDUNG'),
          OptionModel(id: 3274, text: 'KOTA CIREBON'),
          OptionModel(id: 3275, text: 'KOTA BEKASI'),
          OptionModel(id: 3276, text: 'KOTA DEPOK'),
          OptionModel(id: 3277, text: 'KOTA CIMAHI'),
          OptionModel(id: 3278, text: 'KOTA TASIKMALAYA'),
          OptionModel(id: 3279, text: 'KOTA BANJAR'),
        ];
      case 33:
        return [
          OptionModel(id: 3301, text: 'KAB. CILACAP'),
          OptionModel(id: 3302, text: 'KAB. BANYUMAS'),
          OptionModel(id: 3303, text: 'KAB. PURBALINGGA'),
          OptionModel(id: 3304, text: 'KAB. BANJARNEGARA'),
          OptionModel(id: 3305, text: 'KAB. KEBUMEN'),
          OptionModel(id: 3306, text: 'KAB. PURWOREJO'),
          OptionModel(id: 3307, text: 'KAB. WONOSOBO'),
          OptionModel(id: 3308, text: 'KAB. MAGELANG'),
          OptionModel(id: 3309, text: 'KAB. BOYOLALI'),
          OptionModel(id: 3310, text: 'KAB. KLATEN'),
          OptionModel(id: 3311, text: 'KAB. SUKOHARJO'),
          OptionModel(id: 3312, text: 'KAB. WONOGIRI'),
          OptionModel(id: 3313, text: 'KAB. KARANGANYAR'),
          OptionModel(id: 3314, text: 'KAB. SRAGEN'),
          OptionModel(id: 3315, text: 'KAB. GROBOGAN'),
          OptionModel(id: 3316, text: 'KAB. BLORA'),
          OptionModel(id: 3317, text: 'KAB. REMBANG'),
          OptionModel(id: 3318, text: 'KAB. PATI'),
          OptionModel(id: 3319, text: 'KAB. KUDUS'),
          OptionModel(id: 3320, text: 'KAB. JEPARA'),
          OptionModel(id: 3321, text: 'KAB. DEMAK'),
          OptionModel(id: 3322, text: 'KAB. SEMARANG'),
          OptionModel(id: 3323, text: 'KAB. TEMANGGUNG'),
          OptionModel(id: 3324, text: 'KAB. KENDAL'),
          OptionModel(id: 3325, text: 'KAB. BATANG'),
          OptionModel(id: 3326, text: 'KAB. PEKALONGAN'),
          OptionModel(id: 3327, text: 'KAB. PEMALANG'),
          OptionModel(id: 3328, text: 'KAB. TEGAL'),
          OptionModel(id: 3329, text: 'KAB. BREBES'),
          OptionModel(id: 3371, text: 'KOTA MAGELANG'),
          OptionModel(id: 3372, text: 'KOTA SURAKARTA'),
          OptionModel(id: 3373, text: 'KOTA SALATIGA'),
          OptionModel(id: 3374, text: 'KOTA SEMARANG'),
          OptionModel(id: 3375, text: 'KOTA PEKALONGAN'),
          OptionModel(id: 3376, text: 'KOTA TEGAL'),
        ];
      case 34:
        return [
          OptionModel(id: 3401, text: 'KAB. KULON PROGO'),
          OptionModel(id: 3402, text: 'KAB. BANTUL'),
          OptionModel(id: 3403, text: 'KAB. GUNUNGKIDUL'),
          OptionModel(id: 3404, text: 'KAB. SLEMAN'),
          OptionModel(id: 3471, text: 'KOTA YOGYAKARTA'),
        ];
      case 35:
        return [
          OptionModel(id: 3501, text: 'KAB. PACITAN'),
          OptionModel(id: 3502, text: 'KAB. PONOROGO'),
          OptionModel(id: 3503, text: 'KAB. TRENGGALEK'),
          OptionModel(id: 3504, text: 'KAB. TULUNGAGUNG'),
          OptionModel(id: 3505, text: 'KAB. BLITAR'),
          OptionModel(id: 3506, text: 'KAB. KEDIRI'),
          OptionModel(id: 3507, text: 'KAB. MALANG'),
          OptionModel(id: 3508, text: 'KAB. LUMAJANG'),
          OptionModel(id: 3509, text: 'KAB. JEMBER'),
          OptionModel(id: 3510, text: 'KAB. BANYUWANGI'),
          OptionModel(id: 3511, text: 'KAB. BONDOWOSO'),
          OptionModel(id: 3512, text: 'KAB. SITUBONDO'),
          OptionModel(id: 3513, text: 'KAB. PROBOLINGGO'),
          OptionModel(id: 3514, text: 'KAB. PASURUAN'),
          OptionModel(id: 3515, text: 'KAB. SIDOARJO'),
          OptionModel(id: 3516, text: 'KAB. MOJOKERTO'),
          OptionModel(id: 3517, text: 'KAB. JOMBANG'),
          OptionModel(id: 3518, text: 'KAB. NGANJUK'),
          OptionModel(id: 3519, text: 'KAB. MADIUN'),
          OptionModel(id: 3520, text: 'KAB. MAGETAN'),
          OptionModel(id: 3521, text: 'KAB. NGAWI'),
          OptionModel(id: 3522, text: 'KAB. BOJONEGORO'),
          OptionModel(id: 3523, text: 'KAB. TUBAN'),
          OptionModel(id: 3524, text: 'KAB. LAMONGAN'),
          OptionModel(id: 3525, text: 'KAB. GRESIK'),
          OptionModel(id: 3526, text: 'KAB. BANGKALAN'),
          OptionModel(id: 3527, text: 'KAB. SAMPANG'),
          OptionModel(id: 3528, text: 'KAB. PAMEKASAN'),
          OptionModel(id: 3529, text: 'KAB. SUMENEP'),
          OptionModel(id: 3571, text: 'KOTA KEDIRI'),
          OptionModel(id: 3572, text: 'KOTA BLITAR'),
          OptionModel(id: 3573, text: 'KOTA MALANG'),
          OptionModel(id: 3574, text: 'KOTA PROBOLINGGO'),
          OptionModel(id: 3575, text: 'KOTA PASURUAN'),
          OptionModel(id: 3576, text: 'KOTA MOJOKERTO'),
          OptionModel(id: 3577, text: 'KOTA MADIUN'),
          OptionModel(id: 3578, text: 'KOTA SURABAYA'),
          OptionModel(id: 3579, text: 'KOTA BATU'),
        ];
      case 36:
        return [
          OptionModel(id: 3601, text: 'KAB. PANDEGLANG'),
          OptionModel(id: 3602, text: 'KAB. LEBAK'),
          OptionModel(id: 3603, text: 'KAB. TANGERANG'),
          OptionModel(id: 3604, text: 'KAB. SERANG'),
          OptionModel(id: 3671, text: 'KOTA TANGERANG'),
          OptionModel(id: 3672, text: 'KOTA CILEGON'),
          OptionModel(id: 3673, text: 'KOTA SERANG'),
          OptionModel(id: 3674, text: 'KOTA TANGERANG SELATAN'),
        ];
      case 51:
        return [
          OptionModel(id: 5101, text: 'KAB. JEMBRANA'),
          OptionModel(id: 5102, text: 'KAB. TABANAN'),
          OptionModel(id: 5103, text: 'KAB. BADUNG'),
          OptionModel(id: 5104, text: 'KAB. GIANYAR'),
          OptionModel(id: 5105, text: 'KAB. KLUNGKUNG'),
          OptionModel(id: 5106, text: 'KAB. BANGLI'),
          OptionModel(id: 5107, text: 'KAB. KARANGASEM'),
          OptionModel(id: 5108, text: 'KAB. BULELENG'),
          OptionModel(id: 5171, text: 'KOTA DENPASAR'),
        ];
      case 52:
        return [
          OptionModel(id: 5201, text: 'KAB. LOMBOK BARAT'),
          OptionModel(id: 5202, text: 'KAB. LOMBOK TENGAH'),
          OptionModel(id: 5203, text: 'KAB. LOMBOK TIMUR'),
          OptionModel(id: 5204, text: 'KAB. SUMBAWA'),
          OptionModel(id: 5205, text: 'KAB. DOMPU'),
          OptionModel(id: 5206, text: 'KAB. BIMA'),
          OptionModel(id: 5207, text: 'KAB. SUMBAWA BARAT'),
          OptionModel(id: 5208, text: 'KAB. LOMBOK UTARA'),
          OptionModel(id: 5271, text: 'KOTA MATARAM'),
          OptionModel(id: 5272, text: 'KOTA BIMA'),
        ];
      case 53:
        return [
          OptionModel(id: 5301, text: 'KAB. KUPANG'),
          OptionModel(id: 5302, text: 'KAB TIMOR TENGAH SELATAN'),
          OptionModel(id: 5303, text: 'KAB. TIMOR TENGAH UTARA'),
          OptionModel(id: 5304, text: 'KAB. BELU'),
          OptionModel(id: 5305, text: 'KAB. ALOR'),
          OptionModel(id: 5306, text: 'KAB. FLORES TIMUR'),
          OptionModel(id: 5307, text: 'KAB. SIKKA'),
          OptionModel(id: 5308, text: 'KAB. ENDE'),
          OptionModel(id: 5309, text: 'KAB. NGADA'),
          OptionModel(id: 5310, text: 'KAB. MANGGARAI'),
          OptionModel(id: 5311, text: 'KAB. SUMBA TIMUR'),
          OptionModel(id: 5312, text: 'KAB. SUMBA BARAT'),
          OptionModel(id: 5313, text: 'KAB. LEMBATA'),
          OptionModel(id: 5314, text: 'KAB. ROTE NDAO'),
          OptionModel(id: 5315, text: 'KAB. MANGGARAI BARAT'),
          OptionModel(id: 5316, text: 'KAB. NAGEKEO'),
          OptionModel(id: 5317, text: 'KAB. SUMBA TENGAH'),
          OptionModel(id: 5318, text: 'KAB. SUMBA BARAT DAYA'),
          OptionModel(id: 5319, text: 'KAB. MANGGARAI TIMUR'),
          OptionModel(id: 5320, text: 'KAB. SABU RAIJUA'),
          OptionModel(id: 5321, text: 'KAB. MALAKA'),
          OptionModel(id: 5371, text: 'KOTA KUPANG'),
        ];
      case 61:
        return [
          OptionModel(id: 6101, text: 'KAB. SAMBAS'),
          OptionModel(id: 6102, text: 'KAB. MEMPAWAH'),
          OptionModel(id: 6103, text: 'KAB. SANGGAU'),
          OptionModel(id: 6104, text: 'KAB. KETAPANG'),
          OptionModel(id: 6105, text: 'KAB. SINTANG'),
          OptionModel(id: 6106, text: 'KAB. KAPUAS HULU'),
          OptionModel(id: 6107, text: 'KAB. BENGKAYANG'),
          OptionModel(id: 6108, text: 'KAB. LANDAK'),
          OptionModel(id: 6109, text: 'KAB. SEKADAU'),
          OptionModel(id: 6110, text: 'KAB. MELAWI'),
          OptionModel(id: 6111, text: 'KAB. KAYONG UTARA'),
          OptionModel(id: 6112, text: 'KAB. KUBU RAYA'),
          OptionModel(id: 6171, text: 'KOTA PONTIANAK'),
          OptionModel(id: 6172, text: 'KOTA SINGKAWANG'),
        ];
      case 62:
        return [
          OptionModel(id: 6201, text: 'KAB. KOTAWARINGIN BARAT'),
          OptionModel(id: 6202, text: 'KAB. KOTAWARINGIN TIMUR'),
          OptionModel(id: 6203, text: 'KAB. KAPUAS'),
          OptionModel(id: 6204, text: 'KAB. BARITO SELATAN'),
          OptionModel(id: 6205, text: 'KAB. BARITO UTARA'),
          OptionModel(id: 6206, text: 'KAB. KATINGAN'),
          OptionModel(id: 6207, text: 'KAB. SERUYAN'),
          OptionModel(id: 6208, text: 'KAB. SUKAMARA'),
          OptionModel(id: 6209, text: 'KAB. LAMANDAU'),
          OptionModel(id: 6210, text: 'KAB. GUNUNG MAS'),
          OptionModel(id: 6211, text: 'KAB. PULANG PISAU'),
          OptionModel(id: 6212, text: 'KAB. MURUNG RAYA'),
          OptionModel(id: 6213, text: 'KAB. BARITO TIMUR'),
          OptionModel(id: 6271, text: 'KOTA PALANGKARAYA'),
        ];
      case 63:
        return [
          OptionModel(id: 6301, text: 'KAB. TANAH LAUT'),
          OptionModel(id: 6302, text: 'KAB. KOTABARU'),
          OptionModel(id: 6303, text: 'KAB. BANJAR'),
          OptionModel(id: 6304, text: 'KAB. BARITO KUALA'),
          OptionModel(id: 6305, text: 'KAB. TAPIN'),
          OptionModel(id: 6306, text: 'KAB. HULU SUNGAI SELATAN'),
          OptionModel(id: 6307, text: 'KAB. HULU SUNGAI TENGAH'),
          OptionModel(id: 6308, text: 'KAB. HULU SUNGAI UTARA'),
          OptionModel(id: 6309, text: 'KAB. TABALONG'),
          OptionModel(id: 6310, text: 'KAB. TANAH BUMBU'),
          OptionModel(id: 6311, text: 'KAB. BALANGAN'),
          OptionModel(id: 6371, text: 'KOTA BANJARMASIN'),
          OptionModel(id: 6372, text: 'KOTA BANJARBARU'),
        ];
      case 64:
        return [
          OptionModel(id: 6401, text: 'KAB. PASER'),
          OptionModel(id: 6402, text: 'KAB. KUTAI KARTANEGARA'),
          OptionModel(id: 6403, text: 'KAB. BERAU'),
          OptionModel(id: 6407, text: 'KAB. KUTAI BARAT'),
          OptionModel(id: 6408, text: 'KAB. KUTAI TIMUR'),
          OptionModel(id: 6409, text: 'KAB. PENAJAM PASER UTARA'),
          OptionModel(id: 6411, text: 'KAB. MAHAKAM ULU'),
          OptionModel(id: 6471, text: 'KOTA BALIKPAPAN'),
          OptionModel(id: 6472, text: 'KOTA SAMARINDA'),
          OptionModel(id: 6474, text: 'KOTA BONTANG'),
        ];
      case 65:
        return [
          OptionModel(id: 6501, text: 'KAB. BULUNGAN'),
          OptionModel(id: 6502, text: 'KAB. MALINAU'),
          OptionModel(id: 6503, text: 'KAB. NUNUKAN'),
          OptionModel(id: 6504, text: 'KAB. TANA TIDUNG'),
          OptionModel(id: 6571, text: 'KOTA TARAKAN'),
        ];
      case 71:
        return [
          OptionModel(id: 7101, text: 'KAB. BOLAANG MONGONDOW'),
          OptionModel(id: 7102, text: 'KAB. MINAHASA'),
          OptionModel(id: 7103, text: 'KAB. KEPULAUAN SANGIHE'),
          OptionModel(id: 7104, text: 'KAB. KEPULAUAN TALAUD'),
          OptionModel(id: 7105, text: 'KAB. MINAHASA SELATAN'),
          OptionModel(id: 7106, text: 'KAB. MINAHASA UTARA'),
          OptionModel(id: 7107, text: 'KAB. MINAHASA TENGGARA'),
          OptionModel(id: 7108, text: 'KAB. BOLAANG MONGONDOW UTARA'),
          OptionModel(id: 7109, text: 'KAB. KEP. SIAU TAGULANDANG BIARO'),
          OptionModel(id: 7110, text: 'KAB. BOLAANG MONGONDOW TIMUR'),
          OptionModel(id: 7111, text: 'KAB. BOLAANG MONGONDOW SELATAN'),
          OptionModel(id: 7171, text: 'KOTA MANADO'),
          OptionModel(id: 7172, text: 'KOTA BITUNG'),
          OptionModel(id: 7173, text: 'KOTA TOMOHON'),
          OptionModel(id: 7174, text: 'KOTA KOTAMOBAGU'),
        ];
      case 72:
        return [
          OptionModel(id: 7201, text: 'KAB. BANGGAI'),
          OptionModel(id: 7202, text: 'KAB. POSO'),
          OptionModel(id: 7203, text: 'KAB. DONGGALA'),
          OptionModel(id: 7204, text: 'KAB. TOLI TOLI'),
          OptionModel(id: 7205, text: 'KAB. BUOL'),
          OptionModel(id: 7206, text: 'KAB. MOROWALI'),
          OptionModel(id: 7207, text: 'KAB. BANGGAI KEPULAUAN'),
          OptionModel(id: 7208, text: 'KAB. PARIGI MOUTONG'),
          OptionModel(id: 7209, text: 'KAB. TOJO UNA UNA'),
          OptionModel(id: 7210, text: 'KAB. SIGI'),
          OptionModel(id: 7211, text: 'KAB. BANGGAI LAUT'),
          OptionModel(id: 7212, text: 'KAB. MOROWALI UTARA'),
          OptionModel(id: 7271, text: 'KOTA PALU'),
        ];
      case 37:
        return [
          OptionModel(id: 7301, text: 'KAB. KEPULAUAN SELAYAR'),
          OptionModel(id: 7302, text: 'KAB. BULUKUMBA'),
          OptionModel(id: 7303, text: 'KAB. BANTAENG'),
          OptionModel(id: 7304, text: 'KAB. JENEPONTO'),
          OptionModel(id: 7305, text: 'KAB. TAKALAR'),
          OptionModel(id: 7306, text: 'KAB. GOWA'),
          OptionModel(id: 7307, text: 'KAB. SINJAI'),
          OptionModel(id: 7308, text: 'KAB. BONE'),
          OptionModel(id: 7309, text: 'KAB. MAROS'),
          OptionModel(id: 7310, text: 'KAB. PANGKAJENE KEPULAUAN'),
          OptionModel(id: 7311, text: 'KAB. BARRU'),
          OptionModel(id: 7312, text: 'KAB. SOPPENG'),
          OptionModel(id: 7313, text: 'KAB. WAJO'),
          OptionModel(id: 7314, text: 'KAB. SIDENRENG RAPPANG'),
          OptionModel(id: 7315, text: 'KAB. PINRANG'),
          OptionModel(id: 7316, text: 'KAB. ENREKANG'),
          OptionModel(id: 7317, text: 'KAB. LUWU'),
          OptionModel(id: 7318, text: 'KAB. TANA TORAJA'),
          OptionModel(id: 7322, text: 'KAB. LUWU UTARA'),
          OptionModel(id: 7324, text: 'KAB. LUWU TIMUR'),
          OptionModel(id: 7326, text: 'KAB. TORAJA UTARA'),
          OptionModel(id: 7371, text: 'KOTA MAKASSAR'),
          OptionModel(id: 7372, text: 'KOTA PARE PARE'),
          OptionModel(id: 7373, text: 'KOTA PALOPO'),
        ];
      case 74:
        return [
          OptionModel(id: 7401, text: 'KAB. KOLAKA'),
          OptionModel(id: 7402, text: 'KAB. KONAWE'),
          OptionModel(id: 7403, text: 'KAB. MUNA'),
          OptionModel(id: 7404, text: 'KAB. BUTON'),
          OptionModel(id: 7405, text: 'KAB. KONAWE SELATAN'),
          OptionModel(id: 7406, text: 'KAB. BOMBANA'),
          OptionModel(id: 7407, text: 'KAB. WAKATOBI'),
          OptionModel(id: 7408, text: 'KAB. KOLAKA UTARA'),
          OptionModel(id: 7409, text: 'KAB. KONAWE UTARA'),
          OptionModel(id: 7410, text: 'KAB. BUTON UTARA'),
          OptionModel(id: 7411, text: 'KAB. KOLAKA TIMUR'),
          OptionModel(id: 7412, text: 'KAB. KONAWE KEPULAUAN'),
          OptionModel(id: 7413, text: 'KAB. MUNA BARAT'),
          OptionModel(id: 7414, text: 'KAB. BUTON TENGAH'),
          OptionModel(id: 7415, text: 'KAB. BUTON SELATAN'),
          OptionModel(id: 7471, text: 'KOTA KENDARI'),
          OptionModel(id: 7472, text: 'KOTA BAU BAU'),
        ];
      case 75:
        return [
          OptionModel(id: 7501, text: 'KAB. GORONTALO'),
          OptionModel(id: 7502, text: 'KAB. BOALEMO'),
          OptionModel(id: 7503, text: 'KAB. BONE BOLANGO'),
          OptionModel(id: 7504, text: 'KAB. PAHUWATO'),
          OptionModel(id: 7505, text: 'KAB. GORONTALO UTARA'),
          OptionModel(id: 7571, text: 'KOTA GORONTALO'),
        ];
      case 76:
        return [
          OptionModel(id: 7601, text: 'KAB. PASANGKAYU'),
          OptionModel(id: 7602, text: 'KAB. MAMUJU'),
          OptionModel(id: 7603, text: 'KAB. MAMASA'),
          OptionModel(id: 7604, text: 'KAB. POLEWALI MANDAR'),
          OptionModel(id: 7605, text: 'KAB. MAJENE'),
          OptionModel(id: 7606, text: 'KAB. MAMUJU TENGAH'),
        ];
      case 81:
        return [
          OptionModel(id: 8101, text: 'KAB. MALUKU TENGAH'),
          OptionModel(id: 8102, text: 'KAB. MALUKU TENGGARA'),
          OptionModel(id: 8103, text: 'KAB. KEPULAUAN TANIMBAR'),
          OptionModel(id: 8104, text: 'KAB. BURU'),
          OptionModel(id: 8105, text: 'KAB. SERAM BAGIAN TIMUR'),
          OptionModel(id: 8106, text: 'KAB. SERAM BAGIAN BARAT'),
          OptionModel(id: 8107, text: 'KAB. KEPULAUAN ARU'),
          OptionModel(id: 8108, text: 'KAB. MALUKU BARAT DAYA'),
          OptionModel(id: 8109, text: 'KAB. BURU SELATAN'),
          OptionModel(id: 8171, text: 'KOTA AMBON'),
          OptionModel(id: 8172, text: 'KOTA TUAL'),
        ];
      case 82:
        return [
          OptionModel(id: 8201, text: 'KAB. HALMAHERA BARAT'),
          OptionModel(id: 8202, text: 'KAB. HALMAHERA TENGAH'),
          OptionModel(id: 8203, text: 'KAB. HALMAHERA UTARA'),
          OptionModel(id: 8204, text: 'KAB. HALMAHERA SELATAN'),
          OptionModel(id: 8205, text: 'KAB. KEPULAUAN SULA'),
          OptionModel(id: 8206, text: 'KAB. HALMAHERA TIMUR'),
          OptionModel(id: 8207, text: 'KAB. PULAU MOROTAI'),
          OptionModel(id: 8208, text: 'KAB. PULAU TALIABU'),
          OptionModel(id: 8271, text: 'KOTA TERNATE'),
          OptionModel(id: 8272, text: 'KOTA TIDORE KEPULAUAN'),
        ];
      case 91:
        return [
          OptionModel(id: 9101, text: 'KAB. MERAUKE'),
          OptionModel(id: 9102, text: 'KAB. JAYAWIJAYA'),
          OptionModel(id: 9103, text: 'KAB. JAYAPURA'),
          OptionModel(id: 9104, text: 'KAB. NABIRE'),
          OptionModel(id: 9105, text: 'KAB. KEPULAUAN YAPEN'),
          OptionModel(id: 9106, text: 'KAB. BIAK NUMFOR'),
          OptionModel(id: 9107, text: 'KAB. PUNCAK JAYA'),
          OptionModel(id: 9108, text: 'KAB. PANIAI'),
          OptionModel(id: 9109, text: 'KAB. MIMIKA'),
          OptionModel(id: 9110, text: 'KAB. SARMI'),
          OptionModel(id: 9111, text: 'KAB. KEEROM'),
          OptionModel(id: 9112, text: 'KAB PEGUNUNGAN BINTANG'),
          OptionModel(id: 9113, text: 'KAB. YAHUKIMO'),
          OptionModel(id: 9114, text: 'KAB. TOLIKARA'),
          OptionModel(id: 9115, text: 'KAB. WAROPEN'),
          OptionModel(id: 9116, text: 'KAB. BOVEN DIGOEL'),
          OptionModel(id: 9117, text: 'KAB. MAPPI'),
          OptionModel(id: 9118, text: 'KAB. ASMAT'),
          OptionModel(id: 9119, text: 'KAB. SUPIORI'),
          OptionModel(id: 9120, text: 'KAB. MAMBERAMO RAYA'),
          OptionModel(id: 9121, text: 'KAB. MAMBERAMO TENGAH'),
          OptionModel(id: 9122, text: 'KAB. YALIMO'),
          OptionModel(id: 9123, text: 'KAB. LANNY JAYA'),
          OptionModel(id: 9124, text: 'KAB. NDUGA'),
          OptionModel(id: 9125, text: 'KAB. PUNCAK'),
          OptionModel(id: 9126, text: 'KAB. DOGIYAI'),
          OptionModel(id: 9127, text: 'KAB. INTAN JAYA'),
          OptionModel(id: 9128, text: 'KAB. DEIYAI'),
          OptionModel(id: 9171, text: 'KOTA JAYAPURA'),
        ];
      case 92:
        return [
          OptionModel(id: 9201, text: 'KAB. SORONG'),
          OptionModel(id: 9202, text: 'KAB. MANOKWARI'),
          OptionModel(id: 9203, text: 'KAB. FAK FAK'),
          OptionModel(id: 9204, text: 'KAB. SORONG SELATAN'),
          OptionModel(id: 9205, text: 'KAB. RAJA AMPAT'),
          OptionModel(id: 9206, text: 'KAB. TELUK BINTUNI'),
          OptionModel(id: 9207, text: 'KAB. TELUK WONDAMA'),
          OptionModel(id: 9208, text: 'KAB. KAIMANA'),
          OptionModel(id: 9209, text: 'KAB. TAMBRAUW'),
          OptionModel(id: 9210, text: 'KAB. MAYBRAT'),
          OptionModel(id: 9211, text: 'KAB. MANOKWARI SELATAN'),
          OptionModel(id: 9212, text: 'KAB. PEGUNUNGAN ARFAK'),
          OptionModel(id: 9271, text: 'KOTA SORONG'),
        ];
      default:
        return [];
    }
  }

  static OptionModel getCityByName(String cityName) {
    final matchedCities = cities.where((element) => element.text == cityName);
    if (matchedCities.isNotEmpty) {
      return matchedCities.first;
    }
    return OptionModel(id: 0, text: '');
  }

  static OptionModel getProvinceById(int provinceId) {
    final matchedProvinces =
        provinces.where((element) => element.id == provinceId);
    if (matchedProvinces.isNotEmpty) {
      return matchedProvinces.first;
    }
    return OptionModel(id: 0, text: '');
  }

  static Future<ResultModel<List<OptionModel>>> getWilayah(String id) async {
    assert(() {
      log('getWilayahById', name: tag);
      return true;
    }());
    String finalErrorMessage = 'Tidak dapat mengambil data nama wilayah';
    try {
      Response response = await WilayahApi().getWilayah(id);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        List<dynamic> dataJson = responseJson['data'];

        late List<OptionModel> result;
        switch (id.length) {
          case 2:
            result = dataJson
                .map((json) => OptionModel.fromKabupatenJson(json))
                .toList();
            break;
          case 4:
            result = dataJson
                .map((json) => OptionModel.fromKecamatanJson(json))
                .toList();
            break;
          case 6:
            result = dataJson
                .map((json) => OptionModel.fromKelurahanJson(json))
                .toList();
            break;
          case 10:
            result = dataJson
                .map((json) => OptionModel.fromKelurahanJson(json))
                .toList();
            break;
        }
        // log(result.toString(), name: 'reslut get wilayah');
        return ResultModel(isSuccess: true, data: result);
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  static Future<ResultModel<List<OptionModel>>> getKodePos(
      String idKecamatan, String idKelurahan) async {
    assert(() {
      log('getWilayahById', name: tag);
      return true;
    }());
    String finalErrorMessage = 'Tidak dapat mengambil data nama wilayah';
    try {
      Response response =
          await WilayahApi().getKodePos(idKecamatan, idKelurahan);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        List<dynamic> dataJson = responseJson['data'];

        late List<OptionModel> result;
        result = dataJson.map((json) => OptionModel.fromJson(json)).toList();
        log(result.toString(), name: 'getKodePos');

        return ResultModel(isSuccess: true, data: result);
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  static Future<ResultModel<OptionModel>> getNamaWilayah(String id) async {
    assert(() {
      log('getNamaWilayah', name: tag);
      return true;
    }());
    String finalErrorMessage = 'Tidak dapat mengambil data nama wilayah';
    try {
      Response response = await WilayahApi().getNamaWilayah(id);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        dynamic dataJson = responseJson['data'];

        late OptionModel result;
        switch (id.length) {
          case 2:
            result = OptionModel.fromProvinsiJson(dataJson);
            break;
          case 4:
            result = OptionModel.fromKabupatenJson(dataJson);
            break;
          case 6:
            result = OptionModel.fromKecamatanJson(dataJson);
            break;
          case 10:
            result = OptionModel.fromKelurahanJson(dataJson);
            break;
        }
        // log(result.toString(), name: 'reslut get wilayah');
        return ResultModel(isSuccess: true, data: result);
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
