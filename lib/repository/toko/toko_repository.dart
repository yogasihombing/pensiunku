import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/toko/toko_api.dart';
import 'package:pensiunku/data/db/app_database.dart';

import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class TokoRepository extends BaseRepository {
  static String tag = 'Toko Repository';
  TokoApi api = TokoApi();
  AppDatabase database = AppDatabase();

  // Helper method to handle HTTP exceptions
  ResultModel<T> _handleHttpError<T>(dynamic error, String fallbackMessage) {
    log(error.toString(), name: tag, error: error);
    
    if (error is SocketException) {
      return ResultModel(
        isSuccess: false,
        error: fallbackMessage,
      );
    }
    
    if (error is http.ClientException) {
      return ResultModel(
        isSuccess: false,
        error: fallbackMessage,
      );
    }
    
    if (error is HttpException) {
      return ResultModel(
        isSuccess: false,
        error: fallbackMessage,
      );
    }
    
    return ResultModel(
      isSuccess: false,
      error: fallbackMessage,
    );
  }

  // Helper method to handle HTTP response
  ResultModel<T> _handleHttpResponse<T>(http.Response response, String fallbackMessage, T Function(Map<String, dynamic>) onSuccess) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return ResultModel(
          isSuccess: true,
          data: onSuccess(responseJson),
        );
      } catch (e) {
        return ResultModel(
          isSuccess: false,
          error: fallbackMessage,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // Client error
      try {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        String message = responseJson['message'] ?? fallbackMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      } catch (e) {
        return ResultModel(
          isSuccess: false,
          error: fallbackMessage,
        );
      }
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      // Server error
      try {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        String message = responseJson['message'] ?? fallbackMessage;
        return ResultModel(
          isSuccess: false,
          error: message,
        );
      } catch (e) {
        return ResultModel(
          isSuccess: false,
          error: fallbackMessage,
        );
      }
    } else {
      return ResultModel(
        isSuccess: false,
        error: fallbackMessage,
      );
    }
  }

  Future<ResultModel<List<ProductModel>>> getAllProduct(
      int page, String token) async {
    assert(() {
      log('getAllProduct', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list product. Tolong periksa Internet Anda.';
    try {
      http.Response response = await api.getAllProduct(page, token);
      
      return _handleHttpResponse<List<ProductModel>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['products'] != null) {
            log(responseJson['products'].toString());
            // transform format
            TokoModel tokoModel = TokoModel.fromJson(responseJson['products']);
            List<ProductModel> products = tokoModel.products.data.map((product) {
              return ProductModel.fromProductModel(product);
            }).toList();
            return products;
          } else {
            throw Exception('Products is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getAllProduct(page, token);
      
      return _handleHttpResponse<TokoModel>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['products'] != null) {
            log(responseJson['products'].toString());
            TokoModel tokoModel = TokoModel.fromJson(responseJson);
            return tokoModel;
          } else {
            throw Exception('Products is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getShoppingCart(token);
      
      return _handleHttpResponse<List<Cart>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['cart'] != null) {
            log(responseJson['cart'].toString());
            List<dynamic> cartsJson = responseJson['cart'] ?? [];
            List<Cart> carts = [];

            if (cartsJson.length > 0) {
              cartsJson.forEach((value) {
                carts.add(Cart.fromJson(value));
              });
              log('cart total' + carts.length.toString());
            }
            return carts;
          } else {
            throw Exception('Cart is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response =
          await api.postToShoppingCart(token, pushToShoppingCart);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<Cart>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to post to shopping cart');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response =
          await api.putToShoppingCart(token, pushToShoppingCart);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<Cart>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to put to shopping cart');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.deleteShoppingCart(token, idCart);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<String>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to delete shopping cart');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getShippingAddress(token);
      
      return _handleHttpResponse<List<ShippingAddress>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['shipping_addresses'] != null) {
            log(responseJson['shipping_addresses'].toString());
            List<dynamic> shippingAddressJson =
                responseJson['shipping_addresses'] ?? [];
            List<ShippingAddress> shippingAddress = [];

            if (shippingAddressJson.length > 0) {
              shippingAddressJson.forEach((value) {
                shippingAddress.add(ShippingAddress.fromJson(value));
              });
              log('Shipping Address total' + shippingAddress.length.toString());
            }
            return shippingAddress;
          } else {
            throw Exception('Shipping addresses is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getShippingAddressPreview(token);
      
      return _handleHttpResponse<List<ShippingAddress>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['shipping_addresses'] != null) {
            log(responseJson['shipping_addresses'].toString());
            List<dynamic> shippingAddressJson =
                responseJson['shipping_addresses'] ?? [];
            List<ShippingAddress> shippingAddress = [];

            if (shippingAddressJson.length > 0) {
              shippingAddressJson.forEach((value) {
                shippingAddress.add(ShippingAddress.fromJson2(value));
              });
              log('Shipping Address total' + shippingAddress.length.toString());
            }
            return shippingAddress;
          } else {
            throw Exception('Shipping addresses is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getShippingAddressById(token, id);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseJson['shipping_address'] != null) {
          log(responseJson['shipping_address'].toString());
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
      } else {
        return _handleHttpResponse<ShippingAddress>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to get shipping address');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      return _handleHttpError(e, finalErrorMessage);
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
      return _handleHttpError(e, finalErrorMessage);
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
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.postShippingAddress(token, shippingAddress);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<ShippingAddress>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to post shipping address');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.putShippingAddress(token, shippingAddress);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<ShippingAddress>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to put shipping address');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response =
          await api.deleteShippingAddress(token, idShippingAddress);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
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
      } else {
        return _handleHttpResponse<String>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to delete shipping address');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getAllCategories(token);
      
      return _handleHttpResponse<List<Category>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['categories'] != null) {
            log(responseJson['categories'].toString());
            // transform format
            CategoryModel categoryModel = CategoryModel.fromJson(responseJson);
            List<Category> categories = categoryModel.categories.data;
            return categories;
          } else {
            throw Exception('Categories is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getLatestProductByCategory(
          page, token, category, searchText);
      
      return _handleHttpResponse<TokoModel>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['products'] != null) {
            // transform format
            TokoModel tokoModel = TokoModel.fromJson(responseJson);
            return tokoModel;
          } else {
            throw Exception('Products is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getFeaturedProductByCategory(
          page, token, category, searchText);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseJson['products'] != null) {
          // transform format
          TokoModel tokoModel = TokoModel.fromJson(responseJson);
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
      } else {
        return _handleHttpResponse<TokoModel>(response, finalErrorMessage, (responseJson) {
          throw Exception('Failed to get featured products');
        });
      }
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
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
      http.Response response = await api.getRelatedProductById(token, productId);
      
      return _handleHttpResponse<List<Product>>(
        response,
        finalErrorMessage,
        (responseJson) {
          if (responseJson['products'] != null) {
            log(responseJson['products'].toString());
            List<dynamic> listJson = responseJson['products'];
            List<Product> products = [];
            listJson.forEach((value) {
              products.add(Product.fromJson(value));
            });
            return products;
          } else {
            throw Exception('Products is null');
          }
        },
      );
    } catch (e) {
      return _handleHttpError(e, finalErrorMessage);
    }
  }
}