import 'package:dio/dio.dart';

import 'package:pensiunku/model/result_model.dart';

class BaseRepository {
  Future<ResultModel<T>> getResultModel<T>({
    required String tag,
    required Future<T?> Function() getFromDb,
    required Future<Response> Function() getFromApi,
    required T Function(dynamic responseJson) getDataFromApiResponse,
    required Future<void> Function(T dataApi) removeFromDb,
    required Future<void> Function(T dataApi) insertToDb,
    required String errorMessage,
  }) async {
    T? dataDb = await getFromDb();
    print('$tag: getResultModel dipanggil');

    try {
      print('$tag: Mencoba ambil data dari API...');
      Response response = await getFromApi();
      
      print('$tag: Respons API diterima. Status Kode: ${response.statusCode}');
      
      // Validasi response
      if (response.statusCode != 200) {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          type: DioErrorType.badResponse,
          error: 'Invalid status code: ${response.statusCode}',
        );
      }
      
      if (response.data == null) {
        throw FormatException('Response data is null');
      }
      
      // Deteksi Cloudflare HTML response
      if (response.data is String && 
          (response.data as String).contains('One moment, please')) {
        throw FormatException('Cloudflare challenge detected');
      }
      
      if (response.data is! Map) {
        throw FormatException('Invalid response type: Expected Map');
      }
      
      final Map<String, dynamic> responseJson = response.data;
      
      if (!responseJson.containsKey('status')) {
        throw FormatException('Missing "status" field in response');
      }
      
      if (responseJson['status'] == 'success') {
        T dataApi = getDataFromApiResponse(responseJson);
        
        await removeFromDb(dataApi);
        await insertToDb(dataApi);
        
        // Ambil data terbaru dari DB
        dataDb = await getFromDb();
        
        return ResultModel(
          isSuccess: true,
          data: dataDb,
        );
      } else {
        String serverMessage = responseJson['msg'] ?? 'Unknown server error';
        return ResultModel(
          isSuccess: false,
          error: serverMessage,
          data: dataDb,
        );
      }
    } on DioError catch (e) {
      print('$tag: DioError: ${e.message}');
      return ResultModel(
        isSuccess: false,
        error: errorMessage,
        data: dataDb,
      );
    } on FormatException catch (e) {
      print('$tag: FormatException: ${e.message}');
      return ResultModel(
        isSuccess: false,
        error: 'Invalid server response: ${e.message}',
        data: dataDb,
      );
    } catch (e) {
      print('$tag: Unknown error: $e');
      return ResultModel(
        isSuccess: false,
        error: errorMessage,
        data: dataDb,
      );
    }
  }
}