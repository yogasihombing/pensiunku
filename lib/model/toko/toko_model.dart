import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:pensiunku/model/user_model.dart';

// Helper functions for safe parsing
// Perubahan yang kamu buat: Fungsi helper untuk parsing tipe data yang aman
int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ??
        0; // Coba parse string ke int, default 0 jika gagal
  }
  return 0; // Default jika bukan int atau String
}

// Perubahan yang kamu buat: Fungsi helper untuk parsing int nullable yang aman
int? _parseIntNullable(dynamic value) {
  if (value == null) {
    return null;
  } else if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value); // Akan mengembalikan null jika gagal parse
  }
  return null; // Default jika bukan int, String, atau null
}

// Perubahan yang kamu buat: Fungsi helper untuk parsing double yang aman
double _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  } else if (value is String) {
    return double.tryParse(value) ??
        0.0; // Coba parse string ke double, default 0.0 jika gagal
  }
  return 0.0; // Default jika bukan double, int, atau String
}

// Perubahan yang kamu buat: Fungsi helper untuk parsing DateTime yang aman (non-nullable)
DateTime _parseDateTime(dynamic value) {
  if (value is String) {
    // Default ke DateTime(0) (epoch) jika string tidak valid untuk menghindari null
    return DateTime.tryParse(value) ?? DateTime(0);
  }
  return DateTime(0); // Default jika bukan string
}

// Perubahan yang kamu buat: Fungsi helper untuk parsing DateTime nullable yang aman
DateTime? _parseDateTimeNullable(dynamic value) {
  if (value == null) {
    return null;
  } else if (value is String) {
    return DateTime.tryParse(value); // Akan mengembalikan null jika gagal parse
  }
  return null; // Default jika bukan string atau null
}

class TokoModel {
  final Pagination products;

  TokoModel({required this.products});

  factory TokoModel.fromJson(Map<String, dynamic> json) {
    return TokoModel(
      // Perubahan yang kamu buat: Memastikan 'products' diurai dengan aman
      products: Pagination.fromJson(
          json['products'] ?? {}), // Memberikan map kosong jika null
    );
  }
}

class ProductModel {
  final int id;
  final String nama;
  final String logo;
  final int harga;
  final double review;

  ProductModel(
      {required this.id,
      required this.nama,
      required this.logo,
      required this.harga,
      required this.review});

  factory ProductModel.fromProductModel(Product product) {
    int sumReview = 0;
    // Perubahan yang kamu buat: Pengecekan null-safety pada product.review
    if (product.review != null && product.review!.isNotEmpty) {
      product.review!.map((rev) {
        sumReview = sumReview + rev.star;
      });
    }

    return ProductModel(
      id: product.id,
      nama: product.nama,
      logo: product.gallery.isNotEmpty
          ? product.gallery[0].path
          : '', // Perubahan yang kamu buat: Pengecekan gallery tidak kosong
      harga: product.harga,
      review: product.review != null && product.review!.isNotEmpty
          ? (sumReview / product.review!.length)
          : 0, // Perubahan yang kamu buat: Pengecekan review tidak null/kosong
    );
  }

  String getTotalPriceFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp. ',
    ).format(harga.toString());
  }
}

class Pagination {
  final int currentPage;
  final List<Product> data;
  final String firstPageUrl;
  final String lastPageUrl;
  String? nextPageUrl;
  String? prevPageUrl;
  int? from;
  int? to;
  final int total;
  final int lastPage;
  final int perPage;

  Pagination({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    required this.total,
    required this.lastPage,
    required this.perPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'data' adalah List, jika tidak, default ke list kosong
    List<dynamic> productJson = json['data'] is List ? json['data'] : [];

    return Pagination(
      currentPage: _parseInt(json['current_page']), // Perubahan yang kamu buat
      data: productJson.map((product) => Product.fromJson(product)).toList(),
      firstPageUrl:
          json['first_page_url']?.toString() ?? '', // Perubahan yang kamu buat
      lastPageUrl:
          json['last_page_url']?.toString() ?? '', // Perubahan yang kamu buat
      nextPageUrl:
          json['next_page_url']?.toString(), // Perubahan yang kamu buat
      prevPageUrl:
          json['prev_page_url']?.toString(), // Perubahan yang kamu buat
      from: _parseIntNullable(json['from']), // Perubahan yang kamu buat
      to: _parseIntNullable(json['to']), // Perubahan yang kamu buat
      total: _parseInt(json['total']), // Perubahan yang kamu buat
      lastPage: _parseInt(json['last_page']), // Perubahan yang kamu buat
      perPage: _parseInt(json['per_page']), // Perubahan yang kamu buat
    );
  }
}

class Product {
  final int id;
  final String kodeProduct;
  final int idKategori;
  final String nama;
  final String deskripsi;
  final int harga;
  final int stok;
  final DateTime createdAt;
  DateTime? updateAt;
  Category? category;
  final List<Gallery> gallery;
  List<Review>? review;
  // int? jumlahReview; // Dikomentari di kode asli
  double? averageRating;
  final int berat;
  String? terjual;

  Product(
      {required this.id,
      required this.kodeProduct,
      required this.idKategori,
      required this.nama,
      required this.deskripsi,
      required this.harga,
      required this.stok,
      required this.createdAt,
      this.updateAt,
      this.category,
      required this.gallery,
      this.review,
      // this.jumlahReview, // Dikomentari di kode asli
      this.averageRating,
      required this.berat,
      this.terjual});

  factory Product.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'gallery' dan 'review' adalah List
    List<dynamic> galleryJson = json['gallery'] is List ? json['gallery'] : [];
    List<dynamic> reviewJson = json['review'] is List ? json['review'] : [];

    return Product(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      kodeProduct:
          json['kode_produk']?.toString() ?? '', // Perubahan yang kamu buat
      idKategori: _parseInt(json['id_kategori']), // Perubahan yang kamu buat
      nama: json['nama']?.toString() ?? '', // Perubahan yang kamu buat
      deskripsi:
          json['deskripsi']?.toString() ?? '', // Perubahan yang kamu buat
      harga: _parseInt(json['harga']), // Perubahan yang kamu buat
      stok: _parseInt(json['stok']), // Perubahan yang kamu buat
      createdAt: _parseDateTime(json['created_at']), // Perubahan yang kamu buat
      updateAt: _parseDateTimeNullable(
          json['updated_at']), // Perubahan yang kamu buat
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      gallery: galleryJson.map((gallery) => Gallery.fromJson(gallery)).toList(),
      // Perubahan yang kamu buat: Menghandle review kosong/null
      review: reviewJson.isNotEmpty
          ? reviewJson.map((review) => Review.fromJson(review)).toList()
          : null,
      // jumlahReview: json['jumlah_review'], // Dikomentari di kode asli
      averageRating: _parseDouble(
          json['average_rating'] ?? 0.0), // Perubahan yang kamu buat
      berat: _parseInt(json['berat']), // Perubahan yang kamu buat
      terjual: json['terjual']?.toString(), // Perubahan yang kamu buat
    );
  }

  String getTotalPriceFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp. ',
    ).format(harga.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_produk': kodeProduct,
      'id_kategori': idKategori,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'created_at': createdAt.toIso8601String(), // Perubahan yang kamu buat
      'updated_at': updateAt?.toIso8601String(), // Perubahan yang kamu buat
      'category': category?.toJson(), // Perubahan yang kamu buat
      'gallery': gallery.map((gal) => gal.toJson()).toList(),
      'review':
          review?.map((e) => e.toJson()).toList(), // Perubahan yang kamu buat
      'average_rating': averageRating,
      'berat': berat,
      'terjual': terjual,
    };
  }
}

class Review {
  final int id;
  final int idBarang;
  final int idUser;
  String? userName;
  final int star;
  final String ulasan;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.idBarang,
    required this.idUser,
    this.userName,
    required this.star,
    required this.ulasan,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      idBarang: _parseInt(json['id_barang']), // Perubahan yang kamu buat
      idUser: _parseInt(json['id_user']), // Perubahan yang kamu buat
      userName: json['nama']?.toString(), // Perubahan yang kamu buat
      star: _parseInt(json['star']), // Perubahan yang kamu buat
      ulasan: json['ulasan']?.toString() ?? '', // Perubahan yang kamu buat
      createdAt: _parseDateTime(json['created_at']), // Perubahan yang kamu buat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_barang': idBarang,
      'id_user': idUser,
      'userName': userName,
      'star': star,
      'ulasan': ulasan,
      'created_at': createdAt.toIso8601String() // Perubahan yang kamu buat
    };
  }
}

class BarangKeranjang {
  final Product barang;
  int jumlah = 0;

  BarangKeranjang({
    required this.barang,
    required this.jumlah,
  });

  int add() {
    return this.jumlah++;
  }

  int remove() {
    return this.jumlah--; // Perubahan yang kamu buat: jumlah--
  }
}

class Category {
  final int id;
  final String nama;
  int? parentId;

  Category({required this.id, required this.nama, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      nama: json['nama']?.toString() ?? '', // Perubahan yang kamu buat
      parentId:
          _parseIntNullable(json['parent_id']), // Perubahan yang kamu buat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'parent_id': parentId,
    };
  }
}

class Gallery {
  final int id;
  final int idProduct;
  final String path;
  final DateTime createdAt;
  DateTime? updatedAt;

  Gallery(
      {required this.id,
      required this.idProduct,
      required this.path,
      required this.createdAt,
      this.updatedAt});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      idProduct: _parseInt(json['id_barang']), // Perubahan yang kamu buat
      path: json['path']?.toString() ?? '', // Perubahan yang kamu buat
      createdAt: _parseDateTime(json['created_at']), // Perubahan yang kamu buat
      updatedAt: _parseDateTimeNullable(
          json['updated_at']), // Perubahan yang kamu buat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_barang': idProduct,
      'path': path,
      'created_at': createdAt.toIso8601String(), // Perubahan yang kamu buat
      'updated_at': updatedAt?.toIso8601String(), // Perubahan yang kamu buat
    };
  }
}

class Barang {
  final int id;
  final String nama;
  final String logo;
  final int review; // Ini mungkin seharusnya double atau int, tergantung API
  final int price;
  int? jumlahReview;
  String? description;

  Barang(
      {required this.id,
      required this.nama,
      required this.logo,
      required this.review,
      required this.price,
      this.jumlahReview,
      this.description});

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
        id: _parseInt(json['id']), // Perubahan yang kamu buat
        nama: json['nama']?.toString() ?? '', // Perubahan yang kamu buat
        logo: json['logo']?.toString() ?? '', // Perubahan yang kamu buat
        review: _parseInt(json[
            'kategori']), // Perubahan yang kamu buat: review dari 'kategori' field
        price: _parseInt(json['price']), // Perubahan yang kamu buat
        jumlahReview: _parseIntNullable(
            json['jumlah_review']), // Perubahan yang kamu buat
        description:
            json['description']?.toString()); // Perubahan yang kamu buat
  }

  String getTotalPriceFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp. ',
    ).format(price.toString());
  }
}

class Cart {
  final int id;
  final int idUser;
  final int idBarang;
  final int jumlahBarang;
  final int totalPrice;
  final String totalPriceFormatted;
  final int amount;
  final Product product;

  Cart(
      {required this.id,
      required this.idUser,
      required this.idBarang,
      required this.jumlahBarang,
      required this.totalPrice,
      required this.totalPriceFormatted,
      required this.amount,
      required this.product});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      idUser: _parseInt(json['id_user']), // Perubahan yang kamu buat
      idBarang: _parseInt(json['id_barang']), // Perubahan yang kamu buat
      jumlahBarang:
          _parseInt(json['jumlah_barang']), // Perubahan yang kamu buat
      totalPrice:
          _parseInt(json['total_price_numeric']), // Perubahan yang kamu buat
      totalPriceFormatted: json['total_price_formatted']?.toString() ??
          '', // Perubahan yang kamu buat
      amount: _parseInt(json['amount_temp']), // Perubahan yang kamu buat
      product: Product.fromJson(
          json['product']), // Product.fromJson akan handle parsing internal
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_barang': idBarang,
      'jumlah_barang': jumlahBarang,
      'total_price_numeric': totalPrice,
      'total_price_formatted': totalPriceFormatted,
      'amount_temp': amount,
      'product': product.toJson(),
    };
  }
}

class PushToShoppingCart {
  final int id;
  final int stok;

  PushToShoppingCart({required this.id, required this.stok});

  factory PushToShoppingCart.fromJson(Map<String, dynamic> json) {
    return PushToShoppingCart(
      id: _parseInt(json['id']), // Perubahan yang kamu buat
      stok: _parseInt(json['stok']), // Perubahan yang kamu buat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stok': stok,
    };
  }
}

class MessageSuccessModel {
  final int success;
  final String message;
  final Cart item;

  MessageSuccessModel(
      {required this.success, required this.message, required this.item});

  factory MessageSuccessModel.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Pastikan 'success' diurai dengan aman sebagai int
    final successValue = json['success'];
    int parsedSuccess;
    if (successValue is int) {
      parsedSuccess = successValue;
    } else if (successValue is String) {
      // Cek saja String, tidak perlu isNotEmpty karena int.tryParse akan null
      parsedSuccess = int.tryParse(successValue) ?? 0;
    } else {
      parsedSuccess = 0;
    }

    return MessageSuccessModel(
        success: parsedSuccess, // Perubahan yang kamu buat
        message: json['message']?.toString() ?? '', // Perubahan yang kamu buat
        item: Cart.fromJson(
            json['item']) // Cart.fromJson akan handle parsing internal
        );
  }
}

class ShippingAddress {
  String? address;
  String? province;
  String? city;
  String? subdistrict;
  String? postalCode;
  String? mobile;
  int? idUser;
  int? isPrimary;
  int? id;
  int? kodeongkir;

  ShippingAddress(
      {this.address,
      this.province,
      this.city,
      this.subdistrict,
      this.postalCode,
      this.mobile,
      this.idUser,
      this.isPrimary,
      this.id,
      this.kodeongkir});

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address']?.toString(), // Perubahan yang kamu buat
      province: json['province']?.toString(), // Perubahan yang kamu buat
      city: json['city']?.toString(), // Perubahan yang kamu buat
      subdistrict: json['subdistrict']?.toString(), // Perubahan yang kamu buat
      postalCode: json['postal_code']?.toString(), // Perubahan yang kamu buat
      mobile: json['mobile']?.toString(), // Perubahan yang kamu buat
      idUser: _parseIntNullable(json['id_user']), // Perubahan yang kamu buat
      isPrimary:
          _parseIntNullable(json['is_primary']), // Perubahan yang kamu buat
      id: _parseIntNullable(json['id']), // Perubahan yang kamu buat
      kodeongkir:
          _parseIntNullable(json['kodeongkir']), // Perubahan yang kamu buat
    );
  }

  factory ShippingAddress.fromJson2(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memparsing kodeongkir dengan aman jika itu Map atau nilai langsung
    int? parsedKodeOngkir;
    if (json['kodeongkir'] is Map && json['kodeongkir'].containsKey('code')) {
      parsedKodeOngkir = _parseIntNullable(json['kodeongkir']['code']);
    } else {
      parsedKodeOngkir = _parseIntNullable(json['kodeongkir']);
    }

    return ShippingAddress(
      address: json['address']?.toString(), // Perubahan yang kamu buat
      province: json['province']?.toString(), // Perubahan yang kamu buat
      city: json['city']?.toString(), // Perubahan yang kamu buat
      subdistrict: json['subdistrict']?.toString(), // Perubahan yang kamu buat
      postalCode: json['postal_code']?.toString(), // Perubahan yang kamu buat
      mobile: json['mobile']?.toString(), // Perubahan yang kamu buat
      idUser: _parseIntNullable(json['id_user']), // Perubahan yang kamu buat
      isPrimary:
          _parseIntNullable(json['is_primary']), // Perubahan yang kamu buat
      id: _parseIntNullable(json['id']), // Perubahan yang kamu buat
      kodeongkir: parsedKodeOngkir, // Perubahan yang kamu buat
    );
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      address: map['address']?.toString(), // Perubahan yang kamu buat
      province: map['province']?.toString(), // Perubahan yang kamu buat
      city: map['city']?.toString(), // Perubahan yang kamu buat
      subdistrict: map['subdistrict']?.toString(), // Perubahan yang kamu buat
      postalCode: map['postal_code']?.toString(), // Perubahan yang kamu buat
      mobile: map['mobile']?.toString(), // Perubahan yang kamu buat
      idUser: _parseIntNullable(map['id_user']), // Perubahan yang kamu buat
      isPrimary:
          _parseIntNullable(map['is_primary']), // Perubahan yang kamu buat
      id: _parseIntNullable(map['id']), // Perubahan yang kamu buat
      kodeongkir:
          _parseIntNullable(map['kodeongkir']), // Perubahan yang kamu buat
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'province': province,
      'city': city,
      'subdistrict': subdistrict,
      'postal_code': postalCode,
      'mobile': mobile,
      'id_user': idUser,
      'is_primary': isPrimary,
      'id': id,
      'kodeongkir': kodeongkir
    };
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'province': province,
      'city': city,
      'subdistrict': subdistrict,
      'postal_code': postalCode,
      'mobile': mobile,
      'id_user': idUser,
      'is_primary': isPrimary,
      'id': id,
      'kodeongkir': kodeongkir
    };
  }

  Map<String, dynamic> newAddressToJson() {
    return {
      'address': address,
      'province': province,
      'city': city,
      'subdistrict': subdistrict,
      'postal_code': postalCode,
      'mobile': mobile,
    };
  }
}

class CheckoutModel {
  final int idAlamat;
  final String metodePembayaran;
  final String statusMessage;
  final int ongkir;
  final int destination;
  final String kurir;

  CheckoutModel(
      {required this.idAlamat,
      this.metodePembayaran = 'midtrans',
      this.statusMessage = 'Menunggu konfirmasi pembayaran',
      required this.ongkir,
      required this.destination,
      required this.kurir});

  Map<String, dynamic> toJson() {
    return {
      'id_alamat': idAlamat,
      'metode_pembayaran': metodePembayaran,
      'status_message': statusMessage,
      'ongkos_kirim': ongkir,
      'destination': destination,
      'kurir': kurir
    };
  }
}

class OrderCheckoutModel {
  int? id;
  String? idTransaksi;
  int? idUser;
  int? idAlamat;
  String? metodePembayaran;
  int? hargaTotal;
  int? ongkosKirim;
  String? nomorResiPengiriman;
  String? kurir;
  DateTime? tanggalPenyelesaianTransaksi;
  DateTime? tanggalCheckOut;
  DateTime? tanggalDiproses;
  DateTime? tanggalDikirim;
  DateTime? tanggalDiterima;
  String? status;
  String? statusMessage;
  String? paymentStatus;
  String? snapToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdAtFormatted;
  String? updatedAtFormatted;
  UserModel? user;

  OrderCheckoutModel({
    required this.id,
    required this.idTransaksi,
    required this.idUser,
    required this.idAlamat,
    required this.metodePembayaran,
    required this.hargaTotal,
    this.ongkosKirim,
    this.nomorResiPengiriman,
    this.kurir,
    this.tanggalPenyelesaianTransaksi,
    this.tanggalCheckOut,
    this.tanggalDiproses,
    this.tanggalDikirim,
    this.tanggalDiterima,
    required this.status,
    this.statusMessage,
    this.paymentStatus,
    this.snapToken,
    this.createdAt,
    this.updatedAt,
    this.createdAtFormatted,
    this.updatedAtFormatted,
    required this.user,
  });

  factory OrderCheckoutModel.fromJson(Map<String, dynamic> json) {
    return OrderCheckoutModel(
      id: _parseIntNullable(json["id"]), // Perubahan yang kamu buat
      idTransaksi: json["id_transaksi"]?.toString(), // Perubahan yang kamu buat
      idUser: _parseIntNullable(json["id_user"]), // Perubahan yang kamu buat
      idAlamat:
          _parseIntNullable(json["id_alamat"]), // Perubahan yang kamu buat
      metodePembayaran:
          json["metode_pembayaran"]?.toString(), // Perubahan yang kamu buat
      hargaTotal:
          _parseIntNullable(json["harga_total"]), // Perubahan yang kamu buat
      ongkosKirim:
          _parseIntNullable(json["ongkos_kirim"]), // Perubahan yang kamu buat
      nomorResiPengiriman:
          json["nomor_resi_pengiriman"]?.toString(), // Perubahan yang kamu buat
      kurir: json["kurir"]?.toString(), // Perubahan yang kamu buat
      tanggalPenyelesaianTransaksi: _parseDateTimeNullable(
          json["tanggal_penyelesaian_transaksi"]), // Perubahan yang kamu buat
      tanggalCheckOut: _parseDateTimeNullable(
          json["tanggal_check_out"]), // Perubahan yang kamu buat
      tanggalDiproses: _parseDateTimeNullable(
          json["tanggal_diproses"]), // Perubahan yang kamu buat
      tanggalDikirim: _parseDateTimeNullable(
          json["tanggal_dikirim"]), // Perubahan yang kamu buat
      tanggalDiterima: _parseDateTimeNullable(
          json["tanggal_diterima"]), // Perubahan yang kamu buat
      status: json["status"]?.toString(), // Perubahan yang kamu buat
      statusMessage:
          json["status_message"]?.toString(), // Perubahan yang kamu buat
      paymentStatus:
          json["payment_status"]?.toString(), // Perubahan yang kamu buat
      snapToken: json["snap_token"]?.toString(), // Perubahan yang kamu buat
      createdAt: _parseDateTime(json['created_at']), // Perubahan yang kamu buat
      updatedAt: _parseDateTime(json['updated_at']), // Perubahan yang kamu buat
      createdAtFormatted:
          json["created_at_formatted"]?.toString(), // Perubahan yang kamu buat
      updatedAtFormatted:
          json['updated_at_formatted']?.toString(), // Perubahan yang kamu buat
      user:
          UserModel.fromJson(json["user"]), // Asumsi UserModel.fromJson tangguh
    );
  }
}

class CategoryModel {
  final PaginationCategory categories;

  CategoryModel({required this.categories});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // Perubahan yang kamu buat: Memastikan 'categories' diurai dengan aman
      categories: PaginationCategory.fromJson(
          json['categories'] ?? {}), // Memberikan map kosong jika null
    );
  }
}

class PaginationCategory {
  final int currentPage;
  final List<Category> data;
  final String firstPageUrl;
  final String lastPageUrl;
  String? nextPageUrl;
  String? prevPageUrl;
  final int from;
  final int to;
  final int total;
  final int lastPage;
  final int perPage;

  PaginationCategory({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.from,
    required this.to,
    required this.total,
    required this.lastPage,
    required this.perPage,
  });

  factory PaginationCategory.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'data' adalah List, jika tidak, default ke list kosong
    List<dynamic> dataJson = json['data'] is List ? json['data'] : [];

    return PaginationCategory(
      currentPage: _parseInt(json['current_page']), // Perubahan yang kamu buat
      data: dataJson
          .map((category) => Category.fromJson(category))
          .toList(), // Category.fromJson akan handle parsing internal
      firstPageUrl:
          json['first_page_url']?.toString() ?? '', // Perubahan yang kamu buat
      lastPageUrl:
          json['last_page_url']?.toString() ?? '', // Perubahan yang kamu buat
      nextPageUrl:
          json['next_page_url']?.toString(), // Perubahan yang kamu buat
      prevPageUrl:
          json['prev_page_url']?.toString(), // Perubahan yang kamu buat
      from: _parseInt(json['from']), // Perubahan yang kamu buat
      to: _parseInt(json['to']), // Perubahan yang kamu buat
      total: _parseInt(json['total']), // Perubahan yang kamu buat
      lastPage: _parseInt(json['last_page']), // Perubahan yang kamu buat
      perPage: _parseInt(json['per_page']), // Perubahan yang kamu buat
    );
  }
}
