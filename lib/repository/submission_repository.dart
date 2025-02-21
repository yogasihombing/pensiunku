import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pensiunku/data/api/submission_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class SubmissionRepository extends BaseRepository {
  static String tag = 'SubmissionRepository';
  SubmissionApi api = SubmissionApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<SubmissionModel>> uploadSelfie(
    String token,
    SubmissionModel submissionModel,
    String selfieFile,
  ) async {
    assert(() {
      log('uploadSelfie', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mengirimkan foto selfie. Tolong periksa Internet Anda.';

    try {
      Response response = await api.uploadWajah(token, selfieFile);

      // Debugging: Periksa response dari server
      if (kDebugMode) {
        print('Response: ${response.data}');
      }

      var responseJson = response.data;

      if (responseJson != null && responseJson['status'] == 'success') {
        log(responseJson['data'].toString());
        return ResultModel(
          isSuccess: true,
          data: SubmissionModel.fromJson(responseJson['data']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson?['msg'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);

      if (e is DioError) {
        if (e.type == DioErrorType.connectTimeout ||
            e.type == DioErrorType.receiveTimeout ||
            e.type == DioErrorType.other) {
          return ResultModel(
            isSuccess: false,
            error: 'Koneksi internet bermasalah. Coba lagi nanti.',
          );
        }

        int? statusCode = e.response?.statusCode;
        var errorMessage = e.response?.data?['msg'] ?? 'Terjadi kesalahan, coba lagi.';

        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            return ResultModel(
              isSuccess: false,
              error: errorMessage,
            );
          } else if (statusCode >= 500) {
            return ResultModel(
              isSuccess: false,
              error: 'Server mengalami gangguan. Silakan coba lagi nanti.',
            );
          }
        }
      }

      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
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
