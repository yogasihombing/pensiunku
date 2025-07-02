import 'dart:io';

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

    final String idFromApi = json['id']?.toString() ?? '';
    if (idFromApi.isEmpty) {
      // It's better to throw an error if the ID is missing, as it's crucial.
      throw ArgumentError('UserBankDetail requires a non-empty id from JSON.');
    }

    // Safely parse the account number. Using the record 'id' as a fallback is incorrect.
    // It's better to have an empty string if the account number is not provided.
    final String actualAccountNumber =
        json['account_number']?.toString() ?? json['norek']?.toString() ?? '';

    // Handle potential inconsistencies in the key for the account holder's name.
    final String accountHolderName = json['account_holder_name']?.toString() ??
        json['nama']?.toString() ??
        'Nama Pemilik Tidak Diketahui';

    return UserBankDetail(
      id: idFromApi,
      bankName: json['bank']?.toString() ?? 'Nama Bank Tidak Diketahui',
      accountNumber: actualAccountNumber,
      accountHolderName: accountHolderName,
      bankLogoUrl: json['bankLogoUrl']?.toString(),
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
