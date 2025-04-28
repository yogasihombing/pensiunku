// ignore_for_file: non_constant_identifier_names

import 'package:pensiunku/model/user_model.dart';

class OrderModel {
  int? id;
  String? id_transaksi;
  int? id_user;
  int? id_alamat;
  String? metode_pembayaran;
  String? status;
  int? harga_total;
  String? status_message;
  DateTime? created_at;
  DateTime? updated_at;
  List<OrderDetailsModel>? order_details;
  ShippingAddressModel? shippingAddress;
  UserModel? user;
  String? snapToken;
  String? kurir;
  int? ongkosKirim;
  String? nomorResiPengiriman;
  List<ReviewProduct>? reviewProduct;

  OrderModel({
    required this.id,
    required this.id_transaksi,
    required this.id_user,
    required this.id_alamat,
    required this.metode_pembayaran,
    required this.status,
    required this.harga_total,
    this.status_message,
    this.created_at,
    this.updated_at,
    required this.order_details,
    required this.shippingAddress,
    required this.user,
    this.snapToken,
    this.kurir,
    this.ongkosKirim,
    this.nomorResiPengiriman,
    this.reviewProduct,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> order_details_Json = json['order_details'];
    List<dynamic> review_product = json["product_reviews"];

    id = json["id"];
    id_transaksi = json["id_transaksi"];
    id_user = json["id_user"];
    id_alamat = json["id_alamat"];
    metode_pembayaran = json["metode_pembayaran"];
    status = json["status"];
    harga_total = json["harga_total"];
    status_message = json["status_message"];
    created_at = DateTime.parse(json['created_at']);
    updated_at = DateTime.parse(json['updated_at']);
    order_details = order_details_Json
        .map((item) => OrderDetailsModel.fromJson(item))
        .toList();
    shippingAddress = ShippingAddressModel.fromJson(json['shipping_address']);
    user = UserModel.fromJson(json["user"]);
    snapToken = json["snap_token"];
    kurir = json["kurir"];
    ongkosKirim = json["ongkos_kirim"];
    nomorResiPengiriman = json["nomor_resi_pengiriman"];
    reviewProduct =
        review_product.map((item) => ReviewProduct.fromJson(item)).toList();
  }

  CodeToText(String status) {
    String text = "";
    switch (status) {
      case "1":
        text = "Dibatalkan";
        break;
      case "2":
        text = "Kadaluarsa";
        break;
      case "3":
        text = "Menunggu Pembayaran";
        break;
      case "4":
        text = "Menunggu Konfirmasi";
        break;
      case "5":
        text = "Dikemas";
        break;
      case "6":
        text = "Dikirim";
        break;
      case "7":
        text = "Selesai";
        break;
    }
    return text;
  }
}

class OrderDetailsModel {
  String? id_order;
  String? id_produk;
  int? harga_produk;
  int? jumlah_barang;
  DateTime? created_at;
  DateTime? updated_at;
  ProductModel? product;

  OrderDetailsModel({
    required this.id_order,
    required this.id_produk,
    required this.harga_produk,
    required this.jumlah_barang,
    this.created_at,
    this.updated_at,
    required this.product,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id_order = json["id_order"];
    id_produk = json["id_produk"];
    harga_produk = json["harga_produk"];
    jumlah_barang = json["jumlah_barang"];
    created_at = DateTime.parse(json['created_at']);
    updated_at = DateTime.parse(json['updated_at']);
    product = ProductModel.fromJson(json["product"]);
  }
}

class ShippingAddressModel {
  int? id;
  String? address;
  String? province;
  String? city;
  String? subdistrict;
  String? postal_code;
  String? mobile;
  int? isPrimary;
  String? id_user;

  ShippingAddressModel({
    required this.id,
    this.address,
    this.province,
    this.city,
    this.subdistrict,
    this.postal_code,
    this.mobile,
    this.isPrimary,
    required this.id_user,
  });

  ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    address = json["address"];
    province = json["province"];
    city = json["city"];
    subdistrict = json["subdistrict"];
    postal_code = json["postal_code"];
    mobile = json["mobile"];
    isPrimary = json["isPrimary"];
    id_user = json["id_user"];
  }
}

class ProductModel {
  int? id;
  String? kode_produk;
  int? id_kategori;
  String? nama;
  String? deskripsi;
  int? harga;
  int? stok;
  DateTime? created_at;
  DateTime? updated_at;
  List<GalleryModel>? gallery;

  ProductModel({
    required this.id,
    required this.kode_produk,
    required this.id_kategori,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    this.created_at,
    this.updated_at,
    required this.gallery,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    kode_produk = json["kode_produk"];
    id_kategori = json["id_kategori"];
    nama = json["nama"];
    deskripsi = json["deskripsi"];
    harga = json["harga"];
    stok = json["stok"];
    created_at = DateTime.parse(json['created_at']);
    updated_at = DateTime.parse(json['updated_at']);
    List<dynamic> galleryJson = json['gallery'];
    gallery = galleryJson.map((foto) => GalleryModel.fromJson(foto)).toList();
  }
}

class GalleryModel {
  int? id;
  int? id_barang;
  String? path;
  DateTime? created_at;
  // DateTime? updated_at;

  GalleryModel({
    required this.id,
    required this.id_barang,
    required this.path,
    this.created_at,
    // this.updated_at,
  });

  GalleryModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    id_barang = json["id_barang"];
    path = json["path"];
    created_at = DateTime.parse(json['created_at']);
    // updated_at = DateTime.parse(json['updated_at']);
  }
}

class ReviewProduct {
  final int id;
  final int idBarang;
  final int idOrder;
  final int star;
  String? ulasan;

  ReviewProduct(
      {required this.id,
      required this.idBarang,
      required this.idOrder,
      required this.star,
      this.ulasan});

  factory ReviewProduct.fromJson(Map<String, dynamic> json) {
    return ReviewProduct(
      id: json['id'],
      idBarang: json['id_barang'],
      idOrder: json['id_order'],
      star: json['star'],
      ulasan: json['ulasan'] != null ? json['ulasan'] : null,
    );
  }
}
