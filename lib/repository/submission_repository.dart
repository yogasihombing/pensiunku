import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:pensiunku/data/api/submission_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class SubmissionRepository extends BaseRepository {
  static String tag = 'SubmissionRepository';
  SubmissionApi api = SubmissionApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<SubmissionModel>> uploadSelfie(
      String token, SubmissionModel submissionModel, String selfieFile,
      {required String idUser}
      ) async {
    print('=== Repository.uploadSelfie started ===');

    try {
      // Mengambil userId dari submissionModel dan mengonversinya ke String
      Response response = await api.uploadSelfie(
        token,
        selfieFile,
        idUser, // menempelkan User ID
      );
      print('Raw response: ${response.data}');

      if (response.statusCode != 200) {
        return ResultModel(
          isSuccess: false,
          error: 'Server error: ${response.statusCode}',
        );
      }

      var responseData = response.data;
      print('Response type: ${responseData.runtimeType}');
      print('Response content: $responseData');

      // Jika response masih berupa String, coba parse ke JSON
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
          print('Parsed JSON response: $responseData');
        } catch (e) {
          print('Failed to parse response as JSON: $e');
        }
      }

      // Tangani berbagai format response
      if (responseData is Map) {
        if (responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text']['message'] == 'success') {
          print('Response success ditemukan');
          return ResultModel(
            isSuccess: true,
            data: submissionModel,
          );
        }

        if (responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text']['message'] != null &&
            responseData['text']['message'] != 'success') {
          final errorMessage = responseData['text']['message'].toString();
          print('Error message from server: $errorMessage');
          return ResultModel(
            isSuccess: false,
            error: errorMessage,
          );
        }

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return ResultModel(
            isSuccess: true,
            data: SubmissionModel.fromJson(responseData['data']),
          );
        }
      }

      if (responseData is String && responseData.contains('success')) {
        print('String response contains "success"');
        return ResultModel(
          isSuccess: true,
          data: submissionModel,
        );
      }

      return ResultModel(
        isSuccess: false,
        error: 'Format response tidak valid: $responseData',
      );
    } catch (e) {
      print('Error di repository: $e');
      return ResultModel(
        isSuccess: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}




// import 'dart:developer';

// import 'package:dio/dio.dart';
// // import 'package:pensiunku/data/api/submission_api.dart';
// import 'package:pensiunku/data/db/app_database.dart';
// // import 'package:pensiunku/model/bank_model.dart';
// import 'package:pensiunku/model/employment_info_form_model.dart';
// import 'package:pensiunku/model/simulation_form_model.dart';
// import 'package:pensiunku/model/submission_model.dart';
// import 'package:pensiunku/model/user_model.dart';
// import 'package:pensiunku/repository/base_repository.dart';
// import 'package:pensiunku/repository/result_model.dart';

// class SubmissionRepository extends BaseRepository {
//   static String tag = 'SubmissionRepository';
//   // SubmissionApi api = SubmissionApi();
//   AppDatabase database = AppDatabase();

//   // Future<ResultModel<List<SubmissionModel>>> getAll(String token) {
//   //   assert(() {
//   //     log('getAll', name: tag);
//   //     return true;
//   //   }());
//   //   return getResultModel(
//   //     tag: tag,
//   //     getFromDb: () async {
//   //       return await database.submissionDao.getAll();
//   //     },
//   //     getFromApi: () => api.getAll(token),
//   //     getDataFromApiResponse: (responseJson) {
//   //       log(responseJson['data'].toString());
//   //       List<dynamic> itemsJson = responseJson['data'];
//   //       List<SubmissionModel> items = [];
//   //       itemsJson.forEach((value) {
//   //         items.add(
//   //           SubmissionModel.fromJson(value),
//   //         );
//   //       });
//   //       return items;
//   //     },
//   //     removeFromDb: (_) async {
//   //       await database.submissionDao.removeAll();
//   //     },
//   //     insertToDb: (items) async {
//   //       await database.submissionDao.insert(items);
//   //     },
//   //     errorMessage:
//   //         'Gagal mengambil data pengajuan. Tolong periksa Internet Anda.',
//   //   );
//   // }

//   // Future<ResultModel<SubmissionModel>> createPengajuan(
//   //   String token,
//   //   SimulationFormType simulationFormType,
//   //   SimulationFormModel formModel,
//   //   // BankModel bankModel,
//   // ) async {
//   //   assert(() {
//   //     log('createPegawaiAktif', name: tag);
//   //     return true;
//   //   }());
//   //   String finalErrorMessage =
//   //       'Tidak dapat mengajukan form. Tolong periksa Internet Anda.';
//   //   try {
//   //     var responseJson;
//   //     switch (simulationFormType) {
//         // case SimulationFormType.PegawaiAktif:
//         //   Response response = await api.createPegawaiAktif(
//         //       token, formModel as PegawaiAktifFormModel, bankModel);
//         //   responseJson = response.data;
//         //   break;
//         // case SimulationFormType.Platinum:
//         //   Response response = await api.createPlatinum(
//         //       token, formModel as PlatinumFormModel, bankModel);
//         //   responseJson = response.data;
//         //   break;
//         // case SimulationFormType.PraPensiun:
//         //   Response response = await api.createPraPensiun(
//         //       token, formModel as PraPensiunFormModel, bankModel);
//         //   responseJson = response.data;
//         //   break;
//         // case SimulationFormType.Pensiun:
//         //   Response response = await api.createPensiun(
//         //       token, formModel as PensiunFormModel, bankModel);
//         //   responseJson = response.data;
//         //   break;
//       // }

//   //     if (responseJson['status'] == 'success') {
//   //       log(responseJson['data'].toString());
//   //       return ResultModel(
//   //         isSuccess: true,
//   //         data: SubmissionModel.fromJson(responseJson['data']),
//   //       );
//   //     } else {
//   //       return ResultModel(
//   //         isSuccess: false,
//   //         error: responseJson['msg'] ?? finalErrorMessage,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     log(e.toString(), name: tag, error: e);
//   //     if (e is DioError) {
//   //       int? statusCode = e.response?.statusCode;
//   //       if (statusCode != null) {
//   //         if (statusCode >= 400 && statusCode < 500) {
//   //           // Client error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         } else if (statusCode >= 500 && statusCode < 600) {
//   //           // Server error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         }
//   //       }
//   //       if (e.message.contains('SocketException')) {
//   //         return ResultModel(
//   //           isSuccess: false,
//   //           error: finalErrorMessage,
//   //         );
//   //       }
//   //     }
//   //     return ResultModel(
//   //       isSuccess: false,
//   //       error: finalErrorMessage,
//   //     );
//   //   }
//   // }

//   // Future<ResultModel<SubmissionModel>> uploadKtp(
//   //   String token,
//   //   SubmissionModel submissionModel,
//   //   String ktpFile,
//   // ) async {
//   //   assert(() {
//   //     log('uploadKtp', name: tag);
//   //     return true;
//   //   }());
//   //   String finalErrorMessage =
//   //       'Tidak dapat mengirimkan info data pribadi. Tolong periksa Internet Anda.';
//   //   try {
//   //     Response response = await api.uploadKtp(token, submissionModel, ktpFile);
//   //     var responseJson = response.data;

//   //     if (responseJson['status'] == 'success') {
//   //       log(responseJson['data'].toString());
//   //       return ResultModel(
//   //         isSuccess: true,
//   //         data: SubmissionModel.fromJson(responseJson['data']),
//   //       );
//   //     } else {
//   //       return ResultModel(
//   //         isSuccess: false,
//   //         error: responseJson['msg'] ?? finalErrorMessage,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     log(e.toString(), name: tag, error: e);
//   //     if (e is DioError) {
//   //       int? statusCode = e.response?.statusCode;
//   //       if (statusCode != null) {
//   //         if (statusCode >= 400 && statusCode < 500) {
//   //           // Client error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         } else if (statusCode >= 500 && statusCode < 600) {
//   //           // Server error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         }
//   //       }
//   //       if (e.message.contains('SocketException')) {
//   //         return ResultModel(
//   //           isSuccess: false,
//   //           error: finalErrorMessage,
//   //         );
//   //       }
//   //     }
//   //     return ResultModel(
//   //       isSuccess: false,
//   //       error: finalErrorMessage,
//   //     );
//   //   }
//   // }

//   Future<ResultModel<SubmissionModel>> uploadSelfie(
//     String token,
//     SubmissionModel submissionModel,
//     String selfieFile,
//   ) async {
//     assert(() {
//       log('uploadSelfie', name: tag);
//       return true;
//     }());
//     String finalErrorMessage =
//         'Tidak dapat mengirimkan foto selfie. Tolong periksa Internet Anda.';
//     try {
//       Response response =
//           await api.uploadSelfie(token, submissionModel, selfieFile);
//       var responseJson = response.data;

//       if (responseJson['status'] == 'success') {
//         log(responseJson['data'].toString());
//         return ResultModel(
//           isSuccess: true,
//           data: SubmissionModel.fromJson(responseJson['data']),
//         );
//       } else {
//         return ResultModel(
//           isSuccess: false,
//           error: responseJson['msg'] ?? finalErrorMessage,
//         );
//       }
//     } catch (e) {
//       log(e.toString(), name: tag, error: e);
//       if (e is DioError) {
//         int? statusCode = e.response?.statusCode;
//         if (statusCode != null) {
//           if (statusCode >= 400 && statusCode < 500) {
//             // Client error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           } else if (statusCode >= 500 && statusCode < 600) {
//             // Server error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           }
//         }
//         if (e.message.contains('SocketException')) {
//           return ResultModel(
//             isSuccess: false,
//             error: finalErrorMessage,
//           );
//         }
//       }
//       return ResultModel(
//         isSuccess: false,
//         error: finalErrorMessage,
//       );
//     }
//   }

//   // Future<ResultModel<SubmissionModel>> uploadEmploymentInfo(
//   //   String token,
//   //   SubmissionModel submissionModel,
//   //   EmploymentInfoFormModel employmentInfoFormModel,
//   // ) async {
//   //   assert(() {
//   //     log('uploadEmploymentInfo', name: tag);
//   //     return true;
//   //   }());
//   //   String finalErrorMessage =
//   //       'Tidak dapat mengirimkan info kepegawaian. Tolong periksa Internet Anda.';
//   //   try {
//   //     Response response = await api.uploadEmploymentInfo(
//   //         token, submissionModel, employmentInfoFormModel);
//   //     var responseJson = response.data;

//   //     if (responseJson['status'] == 'success') {
//   //       log(responseJson['data'].toString());
//   //       SubmissionModel item = SubmissionModel.fromJson(responseJson['data']);
//   //       await database.submissionDao.insert([item]);
//   //       return ResultModel(
//   //         isSuccess: true,
//   //         data: item,
//   //       );
//   //     } else {
//   //       return ResultModel(
//   //         isSuccess: false,
//   //         error: responseJson['msg'] ?? finalErrorMessage,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     log(e.toString(), name: tag, error: e);
//   //     if (e is DioError) {
//   //       int? statusCode = e.response?.statusCode;
//   //       if (statusCode != null) {
//   //         if (statusCode >= 400 && statusCode < 500) {
//   //           // Client error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         } else if (statusCode >= 500 && statusCode < 600) {
//   //           // Server error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         }
//   //       }
//   //       if (e.message.contains('SocketException')) {
//   //         return ResultModel(
//   //           isSuccess: false,
//   //           error: finalErrorMessage,
//   //         );
//   //       }
//   //     }
//   //     return ResultModel(
//   //       isSuccess: false,
//   //       error: finalErrorMessage,
//   //     );
//   //   }
//   // }

//   // Future<ResultModel<SubmissionModel>> submitSubmission(
//   //   String token,
//   //   SubmissionModel submissionModel,
//   // ) async {
//   //   assert(() {
//   //     log('submitSubmission', name: tag);
//   //     return true;
//   //   }());
//   //   String finalErrorMessage =
//   //       'Tidak dapat submit pengajuan. Tolong periksa Internet Anda.';
//   //   try {
//   //     Response response = await api.submitSubmission(token, submissionModel);
//   //     var responseJson = response.data;

//   //     if (responseJson['status'] == 'success') {
//   //       log(responseJson['data'].toString());
//   //       SubmissionModel item = SubmissionModel.fromJson(responseJson['data']);
//   //       await database.submissionDao.insert([item]);
//   //       return ResultModel(
//   //         isSuccess: true,
//   //         data: item,
//   //       );
//   //     } else {
//   //       return ResultModel(
//   //         isSuccess: false,
//   //         error: responseJson['msg'] ?? finalErrorMessage,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     log(e.toString(), name: tag, error: e);
//   //     if (e is DioError) {
//   //       int? statusCode = e.response?.statusCode;
//   //       if (statusCode != null) {
//   //         if (statusCode >= 400 && statusCode < 500) {
//   //           // Client error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         } else if (statusCode >= 500 && statusCode < 600) {
//   //           // Server error
//   //           return ResultModel(
//   //             isSuccess: false,
//   //             error: finalErrorMessage,
//   //           );
//   //         }
//   //       }
//   //       if (e.message.contains('SocketException')) {
//   //         return ResultModel(
//   //           isSuccess: false,
//   //           error: finalErrorMessage,
//   //         );
//   //       }
//   //     }
//   //     return ResultModel(
//   //       isSuccess: false,
//   //       error: finalErrorMessage,
//   //     );
//   //   }
//   // }

// //   Future<ResultModel<SubmissionCheck>> getSubmissionCheck(String token) async {
// //     assert(() {
// //       log('getSubmissionCheck', name: tag);
// //       return true;
// //     }());
// //     String finalErrorMessage =
// //         'Tidak dapat mendapatkan SubmissionCheck. Tolong periksa Internet Anda.';
// //     try {
// //       Response response = await api.getSubmissionCheck(token);
// //       var responseJson = response.data;

// //       if (responseJson['status'] == 'success') {
// //         log(responseJson['data'].toString());
// //         SubmissionCheck item = SubmissionCheck.fromJson(responseJson['data']);

// //         return ResultModel(
// //           isSuccess: true,
// //           data: item,
// //         );
// //       } else {
// //         return ResultModel(
// //           isSuccess: false,
// //           error: responseJson['msg'] ?? finalErrorMessage,
// //         );
// //       }
// //     } catch (e) {
// //       log(e.toString(), name: tag, error: e);
// //       if (e is DioError) {
// //         int? statusCode = e.response?.statusCode;
// //         if (statusCode != null) {
// //           if (statusCode >= 400 && statusCode < 500) {
// //             // Client error
// //             return ResultModel(
// //               isSuccess: false,
// //               error: finalErrorMessage,
// //             );
// //           } else if (statusCode >= 500 && statusCode < 600) {
// //             // Server error
// //             return ResultModel(
// //               isSuccess: false,
// //               error: finalErrorMessage,
// //             );
// //           }
// //         }
// //         if (e.message.contains('SocketException')) {
// //           return ResultModel(
// //             isSuccess: false,
// //             error: finalErrorMessage,
// //           );
// //         }
// //       }
// //       return ResultModel(
// //         isSuccess: false,
// //         error: finalErrorMessage,
// //       );
// //     }
// //   }
// }
