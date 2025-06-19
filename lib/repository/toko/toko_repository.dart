import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/toko/toko_api.dart';
import 'package:pensiunku/data/db/app_database.dart';

import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class TokoRepository extends BaseRepository {
  static String tag = 'Toko Repository';
  TokoApi api = TokoApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<ProductModel>>> getAllProduct(
      int page, String token) async {
    assert(() {
      log('getAllProduct', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list product. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAllProduct(page, token);
      var responseJson = response.data;
      log(responseJson['products'].toString());

      if (responseJson['products'] != null) {
        // transform format
        TokoModel tokoModel = TokoModel.fromJson(responseJson['products']);
        List<ProductModel> products = tokoModel.products.data.map((product) {
          return ProductModel.fromProductModel(product);
        }).toList();

        return ResultModel(
          isSuccess: true,
          data: products,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<TokoModel>> getAllProductFull(
      int page, String token) async {
    assert(() {
      log('getAllProductFull', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list product. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAllProduct(page, token);
      var responseJson = response.data;
      log(responseJson['products'].toString());

      if (responseJson['products'] != null) {
        TokoModel tokoModel = TokoModel.fromJson(responseJson);
        // List<Product> products = tokoModel.data;

        return ResultModel(
          isSuccess: true,
          data: tokoModel,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<List<Cart>>> getShoppingCart(String token) async {
    assert(() {
      log('getShoppingCart', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list shopping cart. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getShoppingCart(token);
      var responseJson = response.data;
      log(responseJson['cart'].toString());

      if (responseJson['cart'] != null) {
        List<dynamic> cartsJson = responseJson['cart'] ?? [];
        List<Cart> carts = [];

        if (cartsJson.length > 0) {
          cartsJson.forEach((value) {
            carts.add(Cart.fromJson(value));
          });
          log('cart total' + carts.length.toString());
          return ResultModel(
            isSuccess: true,
            data: carts,
          );
        } else {
          return ResultModel(
            isSuccess: true,
            data: [],
          );
        }
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<Cart>> postToShoppingCart(
      String token, PushToShoppingCart pushToShoppingCart) async {
    assert(() {
      log('postToShoppingCart Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan penambahan barang ke keranjang. Tolong periksa Internet Anda.';
    try {
      Response response =
          await api.postToShoppingCart(token, pushToShoppingCart);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        dynamic itemsJson = responseJson['item'];
        Cart cart = Cart.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: cart,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<Cart>> putToShoppingCart(
      String token, PushToShoppingCart pushToShoppingCart) async {
    assert(() {
      log('postToShoppingCart Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan perubahan jumlah barang ke keranjang. Tolong periksa Internet Anda.';
    try {
      Response response =
          await api.putToShoppingCart(token, pushToShoppingCart);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        dynamic itemsJson = responseJson['item'];
        Cart cart = Cart.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: cart,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<String>> deleteShoppingCart(
      String token, int idCart) async {
    assert(() {
      log('postToShoppingCart Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan penghapusan barang dari keranjang. Tolong periksa Internet Anda.';
    try {
      Response response = await api.deleteShoppingCart(token, idCart);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        String message = responseJson['message'];

        return ResultModel(
          isSuccess: true,
          data: message,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<List<ShippingAddress>>> getShippingAddress(
      String token) async {
    assert(() {
      log('getShippingAddress', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getShippingAddress(token);
      var responseJson = response.data;
      log(responseJson['shipping_addresses'].toString());

      if (responseJson['shipping_addresses'] != null) {
        List<dynamic> shippingAddressJson =
            responseJson['shipping_addresses'] ?? [];
        List<ShippingAddress> shippingAddress = [];

        if (shippingAddressJson.length > 0) {
          shippingAddressJson.forEach((value) {
            shippingAddress.add(ShippingAddress.fromJson(value));
          });
          log('Shipping Address total' + shippingAddress.length.toString());
          return ResultModel(
            isSuccess: true,
            data: shippingAddress,
          );
        } else {
          return ResultModel(
            isSuccess: true,
            data: [],
          );
        }
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<List<ShippingAddress>>> getShippingAddressPreview(
      String token) async {
    assert(() {
      log('getShippingAddress', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getShippingAddressPreview(token);
      var responseJson = response.data;
      log(responseJson['shipping_addresses'].toString());

      if (responseJson['shipping_addresses'] != null) {
        List<dynamic> shippingAddressJson =
            responseJson['shipping_addresses'] ?? [];
        List<ShippingAddress> shippingAddress = [];

        if (shippingAddressJson.length > 0) {
          shippingAddressJson.forEach((value) {
            shippingAddress.add(ShippingAddress.fromJson2(value));
          });
          log('Shipping Address total' + shippingAddress.length.toString());
          return ResultModel(
            isSuccess: true,
            data: shippingAddress,
          );
        } else {
          return ResultModel(
            isSuccess: true,
            data: [],
          );
        }
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<ShippingAddress>> getShippingAddressById(
      String token, int id) async {
    assert(() {
      log('getShippingAddressById', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getShippingAddressById(token, id);
      var responseJson = response.data;
      log(responseJson['shipping_address'].toString());

      if (responseJson['shipping_address'] != null) {
        dynamic shippingAddressJson = responseJson['shipping_address'];
        late ShippingAddress shippingAddress;

        if (shippingAddressJson != null) {
          shippingAddress = ShippingAddress.fromJson(shippingAddressJson);
          log('Shipping Address : ' + shippingAddressJson.toString());
          return ResultModel(
            isSuccess: true,
            data: shippingAddress,
          );
        } else {
          return ResultModel(
            isSuccess: true,
            data: ShippingAddress(
                address: '',
                mobile: '',
                province: null,
                city: null,
                subdistrict: null,
                postalCode: null,
                isPrimary: null),
          );
        }
      } else {
        return ResultModel(
          isSuccess: true,
          data: ShippingAddress(
              address: '',
              mobile: '',
              province: null,
              city: null,
              subdistrict: null,
              postalCode: null,
              isPrimary: null),
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<ShippingAddress>> getShippingAddressFromLocal() async {
    assert(() {
      log('getShippingAddressFromLocal', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan alamat pengiriman dari lokal.';
    try {
      ShippingAddress? shippingAddressDb =
          await database.shippingDao.getFirst();
      if (shippingAddressDb == null) {
        return ResultModel(isSuccess: true, data: null);
      } else {
        return ResultModel(
          isSuccess: true,
          data: shippingAddressDb,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<dynamic>> setShippingAddressFromLocal(
      ShippingAddress shippingAddress) async {
    assert(() {
      log('getShippingAddressFromLocal', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menyimpan alamat pengiriman ke lokal.';
    try {
      int shippingAddressDb =
          await database.shippingDao.insertUpdate(shippingAddress);
      if (shippingAddressDb == 1) {
        return ResultModel(isSuccess: true, data: shippingAddressDb);
      } else {
        return ResultModel(
          isSuccess: true,
          data: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<dynamic>> deleteShippingAddressFromLocal(
      int shippingAddressId) async {
    assert(() {
      log('getShippingAddressFromLocal', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menyimpan alamat pengiriman ke lokal.';
    try {
      int shippingAddressDb =
          await database.shippingDao.removeById(shippingAddressId);
      if (shippingAddressDb == 1) {
        return ResultModel(isSuccess: true, data: shippingAddressDb);
      } else {
        return ResultModel(
          isSuccess: true,
          data: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<ShippingAddress>> postShippingAddress(
      String token, ShippingAddress shippingAddress) async {
    assert(() {
      log('postShippingAddress Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan penambahan alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response = await api.postShippingAddress(token, shippingAddress);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        dynamic itemsJson = responseJson['shipping_address'];
        ShippingAddress shippingAddress = ShippingAddress.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: shippingAddress,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<ShippingAddress>> putShippingAddress(
      String token, ShippingAddress shippingAddress) async {
    assert(() {
      log('put Shipping Address Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan perubahan pengiriman alamat. Tolong periksa Internet Anda.';
    try {
      Response response = await api.putShippingAddress(token, shippingAddress);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        dynamic itemsJson = responseJson['shipping_address'];
        ShippingAddress shippingAddress = ShippingAddress.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: shippingAddress,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<String>> deleteShippingAddress(
      String token, int idShippingAddress) async {
    assert(() {
      log('delete Shipping Address Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan penghapusan alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response =
          await api.deleteShippingAddress(token, idShippingAddress);
      var responseJson = response.data;

      if (responseJson['success'] == 1) {
        String message = responseJson['message'];

        return ResultModel(
          isSuccess: true,
          data: message,
        );
      } else {
        String message = responseJson['message'] ?? finalErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
            var responseJson = e.response!.data;
            String message = responseJson['message'] ?? finalErrorMessage;
            return ResultModel(
              isSuccess: false,
              error: message,
            );
          }
        }
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<List<Category>>> getAllCategories(String token,
      {int? page = 1}) async {
    assert(() {
      log('getAllCategories', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list kategori. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAllCategories(token);
      var responseJson = response.data;
      log(responseJson['categories'].toString());

      if (responseJson['categories'] != null) {
        // transform format
        CategoryModel categoryModel = CategoryModel.fromJson(responseJson);
        List<Category> categories = categoryModel.categories.data;

        return ResultModel(
          isSuccess: true,
          data: categories,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<TokoModel>> getLatestProductByCategory(
      int page, String token, int category, searchText) async {
    assert(() {
      log('getLatestProductByCategory', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list product terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getLatestProductByCategory(
          page, token, category, searchText);
      var responseJson = response.data;
      // log(responseJson['products'].toString());

      if (responseJson['products'] != null) {
        // transform format
        TokoModel tokoModel = TokoModel.fromJson(responseJson);
        // List<ProductModel> products = tokoModel.products.data.map((product) {
        //   return ProductModel.fromProductModel(product);
        // }).toList();

        return ResultModel(
          isSuccess: true,
          data: tokoModel,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<TokoModel>> getFeaturedProductByCategory(
      int page, String token, int category, String searchText) async {
    assert(() {
      log('getFeaturedProductByCategory', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list product terlaris. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getFeaturedProductByCategory(
          page, token, category, searchText);
      var responseJson = response.data;
      // log(responseJson['products'].toString());

      if (responseJson['products'] != null) {
        // transform format
        TokoModel tokoModel = TokoModel.fromJson(responseJson);
        // List<ProductModel> products = tokoModel.products.data.map((product) {
        //   return ProductModel.fromProductModel(product);
        // }).toList();

        return ResultModel(
          isSuccess: true,
          data: tokoModel,
        );
      } else if (responseJson['products'] == []) {
        TokoModel tokoModel = TokoModel.fromJson(responseJson);
        return ResultModel(
          isSuccess: true,
          data: tokoModel,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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

  Future<ResultModel<List<Product>>> getRelatedProductById(
      String token, int productId) async {
    assert(() {
      log('getRelatedProductById', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan related product. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getRelatedProductById(token, productId);
      var responseJson = response.data;
      log(responseJson['products'].toString());

      if (responseJson['products'] != null) {
        List<dynamic> listJson = responseJson['products'];
        List<Product> products = [];
        listJson.forEach((value) {
          products.add(Product.fromJson(value));
        });

        return ResultModel(
          isSuccess: true,
          data: products,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
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
        if (e.message.contains('SocketException')) {
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
