

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:pensiunku/model/user_model.dart';

class TokoModel{
  final Pagination products;

  TokoModel({
    required this.products
  });

  factory TokoModel.fromJson(Map<String, dynamic> json) {
    return TokoModel(
      products: Pagination.fromJson(json['products']),
    );
  }
}

class ProductModel{
  final int id;
  final String nama;
  final String logo;
  final int harga;
  final double review;

  ProductModel({
    required this.id,
    required this.nama,
    required this.logo,
    required this.harga,
    required this.review
  });

  factory ProductModel.fromProductModel(Product product){

    int sumReview = 0;
    if(product.review!.length > 0){
      product.review!.map((rev) {
        sumReview = sumReview + rev.star;
      });
    }
     
    return ProductModel(
      id: product.id, 
      nama: product.nama, 
      logo: product.gallery[0].path, 
      harga: product.harga, 
      review: product.review!.length > 0 ? (sumReview / product.review!.length) : 0,
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

class Pagination{
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
    List<dynamic> productJson = json['data'] ?? [];

    return Pagination(
      currentPage: json['current_page'],
      data: productJson.map((product) => Product.fromJson(product)).toList(),
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      from: json['from'] ?? null,
      to: json['to'] ?? null,
      total: json['total'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
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
  // int? jumlahReview;
  double? averageRating;
  final int berat;
  String? terjual;


  Product({
    required this.id,
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
    // this.jumlahReview,
    this.averageRating,
    required this.berat,
    this.terjual
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<dynamic> galleryJson = json['gallery'] ?? [];
    List<dynamic> reviewJson = json['review'] ?? [];

    return Product(
      id: json['id'],
      kodeProduct: json['kode_produk'],
      idKategori: json['id_kategori'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      harga: json['harga'],
      stok: json['stok'],
      createdAt: DateTime.parse(json['created_at']),
      updateAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      gallery: galleryJson.map((gallery) => Gallery.fromJson(gallery)).toList(),
      review: json['review'] != [] ? reviewJson.map((review) => Review.fromJson(review)).toList() : null,
      // jumlahReview: json['jumlah_review'],
      averageRating: json['average_rating'] != null ? double.parse(json['average_rating']) : 0.0,
      berat: json['berat'],
      terjual: json['terjual'] != null ? json['terjual'] : "0",
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
      'created_at': createdAt.toString(),
      'updated_at': updateAt,
      'category': category!.toJson(),
      'gallery': gallery.map((gal) => gal.toJson()).toList(),
      'review': review!.map((e) => e.toJson()).toList(),
      'average_rating': averageRating,
      'berat': berat,
      'terjual' : terjual,
    };
  }
}

class Review{
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
      id: json['id'],
      idBarang: json['id_barang'],
      idUser: json['id_user'],
      userName: json['nama'],
      star: json['star'],
      ulasan: json['ulasan'],
      createdAt: DateTime.parse(json['created_at']),
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
      'created_at': createdAt
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
    return this.jumlah++;
  }
}

class Category {
  final int id;
  final String nama;
  int? parentId;

  Category({required this.id, required this.nama, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nama: json['nama'],
      parentId: json['parent_id'],
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
      id: json['id'],
      idProduct: json['id_barang'],
      path: json['path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_barang': idProduct,
      'path': path,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Barang {
  final int id;
  final String nama;
  final String logo;
  final int review;
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
        id: json['id'],
        nama: json['nama'],
        logo: json['logo'],
        review: json['kategori'],
        price: json['price'],
        jumlahReview: json['jumlah_review'],
        description: json['description']);
  }

  String getTotalPriceFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp. ',
    ).format(price.toString());
  }
}

class Cart{
  final int id;
  final int idUser;
  final int idBarang;
  final int jumlahBarang;
  final int totalPrice;
  final String totalPriceFormatted;
  final int amount;
  final Product product;

  Cart({
    required this.id,
    required this.idUser, 
    required this.idBarang, 
    required this.jumlahBarang, 
    required this.totalPrice, 
    required this.totalPriceFormatted, 
    required this.amount, 
    required this.product
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      idUser: json['id_user'],
      idBarang: json['id_barang'],
      jumlahBarang: json['jumlah_barang'],
      totalPrice: json['total_price_numeric'],
      totalPriceFormatted: json['total_price_formatted'],
      amount: json['amount_temp'],
      product: Product.fromJson(json['product']),
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

class PushToShoppingCart{
  final int id;
  final int stok;

  PushToShoppingCart({
    required this.id,
    required this.stok
  });

  factory PushToShoppingCart.fromJson(Map<String, dynamic> json) {
    return PushToShoppingCart(
      id: json['id'],
      stok: json['stok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stok': stok,
    };
  }
}

class MessageSuccessModel{
  final int success;
  final String message;
  final Cart item;

  MessageSuccessModel({
    required this.success,
    required this.message,
    required this.item
  });

  factory MessageSuccessModel.fromJson(Map<String, dynamic> json) {
    return MessageSuccessModel(
        success: json['success'],
        message: json['message'],
        item: json['item']
    );
  }

}

class ShippingAddress{
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

  ShippingAddress({
    this.address,
    this.province, 
    this.city, 
    this.subdistrict, 
    this.postalCode, 
    this.mobile, 
    this.idUser, 
    this.isPrimary, 
    this.id,
    this.kodeongkir
} );

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
        address: json['address'],
        province: json['province'],
        city: json['city'],
        subdistrict: json['subdistrict'],
        postalCode: json['postal_code'],
        mobile: json['mobile'],
        idUser: json['id_user'] is String ? int.parse(json['id_user']) : json['id_user'],
        isPrimary: json['is_primary'] ,
        id: json['id'],
        kodeongkir: json['kodeongkir'] != null ? json['kodeongkir'] : null
    );
  }

  factory ShippingAddress.fromJson2(Map<String, dynamic> json) {
    return ShippingAddress(
        address: json['address'],
        province: json['province'],
        city: json['city'],
        subdistrict: json['subdistrict'],
        postalCode: json['postal_code'],
        mobile: json['mobile'],
        idUser: json['id_user'] is String ? int.parse(json['id_user']) : json['id_user'],
        isPrimary: json['is_primary'] ,
        id: json['id'],
        kodeongkir: json['kodeongkir'] != null ? json['kodeongkir']['code'] : null
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
      'kodeongkir' : kodeongkir
    };
  }

  Map<String, dynamic> toMap(){
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
      'kodeongkir' : kodeongkir
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
        address: map['address'],
        province: map['province'],
        city: map['city'],
        subdistrict: map['subdistrict'],
        postalCode: map['postal_code'],
        mobile: map['mobile'],
        idUser: map['id_user'] is String ? int.parse(map['id_user']) : map['id_user'],
        isPrimary: map['is_primary'] ,
        id: map['id'],
        kodeongkir: map['kodeongkir'] != null ? map['kodeongkir'] : null
    );
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

class CheckoutModel{
  final int idAlamat;
  final String metodePembayaran;
  final String statusMessage;
  final int ongkir;
  final int destination;
  final String kurir;

  CheckoutModel({
    required this.idAlamat,
    this.metodePembayaran = 'midtrans',
    this.statusMessage = 'Menunggu konfirmasi pembayaran',
    required this.ongkir,
    required this.destination,
    required this.kurir
  });

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
      id: json["id"],
      idTransaksi: json["id_transaksi"],
      idUser: json["id_user"],
      idAlamat: json["id_alamat"],
      metodePembayaran:json["metode_pembayaran"],
      hargaTotal: json["harga_total"],
      ongkosKirim: json["ongkos_kirim"] != null ? json["ongkos_kirim"] : null,
      nomorResiPengiriman: json["nomor_resi_pengiriman"] != null ? json["nomor_resi_pengiriman"] : null,
      kurir: json["kurir"] != null ? json["kurir"] : null,
      tanggalPenyelesaianTransaksi: json["tanggal_penyelesaian_transaksi"] != null ? DateTime.tryParse(json["tanggal_penyelesaian_transaksi"]) : null,
      tanggalCheckOut: json["tanggal_check_out"] != null ? DateTime.tryParse(json["tanggal_check_out"]) : null,
      tanggalDiproses: json["tanggal_diproses"] != null ? DateTime.tryParse(json["tanggal_diproses"]) : null,
      tanggalDikirim: json["tanggal_dikirim"] != null ? DateTime.tryParse(json["tanggal_dikirim"]) : null,
      tanggalDiterima: json["tanggal_diterima"] != null ? DateTime.tryParse(json["tanggal_diterima"]) : null,
      status: json["status"],
      statusMessage: json["status_message"],
      paymentStatus: json["payment_status"] != null ? json["payment_status"] : null,
      snapToken: json["snap_token"] != null ? json["snap_token"] : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdAtFormatted: json["created_at_formatted"],
      updatedAtFormatted: json['updated_at_formatted'],
      user: UserModel.fromJson(json["user"]),
    );
  }
}

class CategoryModel{
  final PaginationCategory categories;

  CategoryModel({
    required this.categories
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categories: PaginationCategory.fromJson(json['categories']),
    );
  }
}

class PaginationCategory{
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
    List<dynamic> dataJson = json['data'];

    return PaginationCategory(
      currentPage: json['current_page'],
      data: dataJson.map((category) => Category.fromJson(category)).toList(),
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      from: json['from'],
      to: json['to'],
      total: json['total'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
    );
  }

}
