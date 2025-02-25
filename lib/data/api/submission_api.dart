import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class SubmissionApi extends BaseApi {
  bool bypassPengajuan = false; // TODO: Set to true to bypass pengajuan
  Dio dio = Dio();

  Future<Response> uploadSelfie(String token, String selfieFilePath) async {
    print('=== Start uploadWajah di API ===');
    print('URL: https://api.pensiunku.id/new.php/uploadWajah');

    final file = File(selfieFilePath);
    if (!await file.exists()) {
      print('❌ File tidak ditemukan: $selfieFilePath');
      throw Exception('File selfie tidak ditemukan');
    }

    print('✅ File ditemukan: $selfieFilePath');
    print('📏 Ukuran file: ${await file.length()} bytes');

    // Ubah gambar menjadi base64
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Kirim sebagai JSON
    final data = {
      "foto_selfie": base64Image, // Kirim file dalam base64
      "nama_foto_selfie": "selfie.jpg"
    };

    print('📤 Mengirim JSON ke API: $data');

    return await dio.post(
      'https://api.pensiunku.id/new.php/uploadWajah',
      data: jsonEncode(data), // Ubah ke JSON
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        responseType:
            ResponseType.json, // Pastikan response di-parse sebagai JSON
      ),
    );
  }
}



// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
// import 'package:pensiunku/data/api/base_api.dart';
// import 'package:pensiunku/data/api/simulation_api.dart';
// import 'package:pensiunku/model/bank_model.dart';
// import 'package:pensiunku/model/employment_info_form_model.dart';
// import 'package:pensiunku/model/simulation_form_model.dart';
// import 'package:pensiunku/model/submission_model.dart';
// import 'package:pensiunku/util/api_util.dart';

// class SubmissionApi extends BaseApi {
//   bool bypassPengajuan = false; // TODO: Set to true to bypass pengajuan

//   Future<Response> getAll(String token) {
//     return httpGet(
//       '/pengajuan',
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> createPegawaiAktif(
//     String token,
//     PegawaiAktifFormModel formModel,
//     BankModel bankModel,
//   ) {
//     var data = SimulationApi().preparePegawaiAktifForm(formModel);
//     data['nama_bank'] = bankModel.logo;
//     if (bypassPengajuan) {
//       data['bypass_pengajuan'] = true;
//     }
//     log(data.toString());
//     return httpPost(
//       '/pengajuan',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> createPensiun(
//     String token,
//     PensiunFormModel formModel,
//     BankModel bankModel,
//   ) {
//     var data = SimulationApi().preparePensiunForm(formModel);
//     data['nama_bank'] = bankModel.logo;
//     if (bypassPengajuan) {
//       data['bypass_pengajuan'] = true;
//     }
//     log(data.toString());
//     return httpPost(
//       '/pengajuan',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> createPraPensiun(
//     String token,
//     PraPensiunFormModel formModel,
//     BankModel bankModel,
//   ) {
//     var data = SimulationApi().preparePraPensiunForm(formModel);
//     data['nama_bank'] = bankModel.logo;
//     if (bypassPengajuan) {
//       data['bypass_pengajuan'] = true;
//     }
//     log(data.toString());
//     return httpPost(
//       '/pengajuan',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> createPlatinum(
//     String token,
//     PlatinumFormModel formModel,
//     BankModel bankModel,
//   ) {
//     var data = SimulationApi().preparePlatinumForm(formModel);
//     data['nama_bank'] = bankModel.logo;
//     if (bypassPengajuan) {
//       data['bypass_pengajuan'] = true;
//     }
//     log(data.toString());
//     return httpPost(
//       '/pengajuan',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> uploadKtp(
//     String token,
//     SubmissionModel submissionModel,
//     String ktpFile,
//   ) async {
//     final dataMap = {
//       "id": submissionModel.id,
//       "foto_ktp": await MultipartFile.fromFile(ktpFile, filename: "ktp.jpg"),
//       'nama_ktp': submissionModel.nameKtp,
//       'nik_ktp': submissionModel.nikKtp,
//       'alamat_ktp': submissionModel.addressKtp,
//       'pekerjaan_ktp': submissionModel.jobKtp,
//       'tanggal_lahir_ktp': submissionModel.birthDateKtp != null
//           ? DateFormat('yyyy-MM-dd').format(submissionModel.birthDateKtp!)
//           : null,
//     };
//     log(dataMap.toString());
//     FormData data = FormData.fromMap(dataMap);
//     return httpPost(
//       '/pengajuan/update',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> uploadSelfie(
//     String token,
//     SubmissionModel submissionModel,
//     String selfieFile,
//   ) async {
//     FormData data = FormData.fromMap({
//       "id": submissionModel.id,
//       "foto_selfie":
//           await MultipartFile.fromFile(selfieFile, filename: "selfie.jpg"),
//     });
//     log(data.toString());
//     return httpPost(
//       '/pengajuan/update',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> uploadEmploymentInfo(
//     String token,
//     SubmissionModel submissionModel,
//     EmploymentInfoFormModel employmentInfoFormModel,
//   ) async {
//     var dataMap = {
//       "id": submissionModel.id,
//       "instansi": employmentInfoFormModel.institution?.text,
//       "nama_instansi":
//           employmentInfoFormModel.institutionName?.isNotEmpty == true
//               ? employmentInfoFormModel.institutionName
//               : "",
//       "nip": employmentInfoFormModel.nip?.isNotEmpty == true
//           ? employmentInfoFormModel.nip
//           : "",
//       "golongan": employmentInfoFormModel.group?.text,
//       "estimasi_gaji": employmentInfoFormModel.salary ?? 0,
//       "instansi_pensiun": employmentInfoFormModel.retirementInstitution?.text,
//       "tmt_pensiun": employmentInfoFormModel.tmtRetirement != null
//           ? DateFormat('yyyy-MM-dd')
//               .format(employmentInfoFormModel.tmtRetirement!)
//           : null,
//     };
//     FormData data = FormData.fromMap(dataMap);
//     log(dataMap.toString());
//     return httpPost(
//       '/pengajuan/update',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> submitSubmission(
//     String token,
//     SubmissionModel submissionModel,
//   ) async {
//     var dataMap = {
//       "id": submissionModel.id,
//     };
//     FormData data = FormData.fromMap(dataMap);
//     log(dataMap.toString());
//     return httpPost(
//       '/pengajuan/submit',
//       data: data,
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }

//   Future<Response> getSubmissionCheck(String token) {
//     return httpGet(
//       '/pengajuan/chek',
//       options: ApiUtil.getTokenOptions(token),
//     );
//   }
// }
