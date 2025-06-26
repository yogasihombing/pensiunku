import 'package:flutter/material.dart'; // Diperlukan untuk debugPrint

/// Model untuk merepresentasikan data Bank
class BankModel {
  final String id; // ID unik bank, mungkin digunakan sebagai kode bank
  final String name; // Nama bank (misalnya "Bank Central Asia")
  final String? logoUrl; // URL opsional untuk logo bank

  BankModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  /// Factory constructor untuk membuat instance BankModel dari data JSON
  factory BankModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing BankModel from JSON: $json'); // Log JSON yang masuk

    // Pastikan field 'id' ada dan tidak null
    // Gunakan nilai default jika tidak ada untuk menghindari error
    String parsedId = json['id']?.toString() ?? '';
    // Perbaikan di sini: Mengambil nama bank dari field 'nama' di JSON
    String parsedName = json['nama']?.toString() ?? 'Nama Bank Tidak Diketahui';
    // Perbaikan di sini: Mengambil URL logo dari field 'foto' di JSON
    String? parsedLogoUrl = json['foto']?.toString();

    return BankModel(
      id: parsedId,
      name: parsedName,
      logoUrl: parsedLogoUrl,
    );
  }

  /// Override toString untuk representasi string yang lebih mudah dibaca
  @override
  String toString() {
    return name; // Cukup mengembalikan nama bank untuk tampilan di Dropdown
  }
}
