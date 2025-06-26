import 'package:flutter/material.dart';

class UserBankDetail {
  final String id;
  final String bankName;
  final String accountNumber; // Ini akan diisi dengan nomor rekening aktual
  final String accountHolderName;
  final String? bankLogoUrl;

  UserBankDetail({
    required this.id,
    required this.bankName,
    required this.accountNumber, // Pastikan ini diisi dengan nomor rekening aktual
    required this.accountHolderName,
    this.bankLogoUrl,
  });

  factory UserBankDetail.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UserBankDetail from JSON: $json');

    String bankName = json['bank'] ?? 'Nama Bank Tidak Diketahui';
    String idFromApi = json['id']?.toString() ?? '';

    // PENTING: Perbaikan ini mengasumsikan API akan mengembalikan 'account_number' atau 'norek'.
    // Ini akan mencoba mengambil data dari 'account_number' terlebih dahulu,
    // lalu dari 'norek', dan terakhir dari 'id' jika keduanya tidak ada.
    String actualAccountNumber = json['account_number']?.toString() ?? json['norek']?.toString() ?? idFromApi;

    String accountHolderName = json['account_holder_name'] ?? 'Nama Pemilik Tidak Diketahui';
    String? bankLogoUrl = json['bankLogoUrl']?.toString();

    return UserBankDetail(
      id: idFromApi,
      bankName: bankName,
      accountNumber: actualAccountNumber, // Sekarang menggunakan nomor rekening aktual
      accountHolderName: accountHolderName,
      bankLogoUrl: bankLogoUrl,
    );
  }

  // Getter baru untuk menampilkan nomor rekening yang sebagian tersembunyi
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) {
      return accountNumber; // Jika terlalu pendek, tampilkan saja semua
    }
    // Sembunyikan semua kecuali 4 digit terakhir
    return 'xxxxxxxxxx${accountNumber.substring(accountNumber.length - 4)}';
  }

  @override
  String toString() {
    return '$bankName - Rek: $accountNumber (Pemilik: $accountHolderName)';
  }
}