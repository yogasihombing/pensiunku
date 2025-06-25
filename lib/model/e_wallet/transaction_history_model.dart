import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

enum TransactionType { pencairan, insentif, other }

class TransactionHistory {
  final DateTime date;
  final double amount;
  final String description;
  final TransactionType type;
  final String? transactionDetail; // Optional detail for transactions

  TransactionHistory({
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
    this.transactionDetail,
  });

  // Factory constructor to create a TransactionHistory from JSON
  // Disesuaikan dengan format respons API terbaru
  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing TransactionHistory from JSON: $json'); // Log incoming JSON

    // Parsing Tanggal: Kombinasikan 'date_only' dan 'transaction_date'
    // Asumsi: 'date_only' adalah hari (misal "01"), 'transaction_date' adalah bulan-tahun (misal "Jun-2025")
    DateTime parsedDate;
    try {
      String day = json['date_only']?.toString() ?? '01'; // Default ke '01' jika tidak ada
      String monthYear = json['transaction_date']?.toString() ?? DateFormat('MMM-yyyy').format(DateTime.now());
      String fullDateString = '$day-$monthYear';
      parsedDate = DateFormat('dd-MMM-yyyy').parse(fullDateString);
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback ke tanggal saat ini
      debugPrint('Error parsing date: ${json['date_only']}-${json['transaction_date']} - $e');
    }

    // Parsing Nominal: Hapus "Rp ", titik (ribuan), dan koma (desimal) sebelum parsing
    double parsedAmount;
    try {
      String amountStr = json['amount'].toString()
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .replaceAll(',', '')
          .replaceAll('-', ''); // Hapus tanda minus jika ada (karena tipe akan menentukannya)
      parsedAmount = double.parse(amountStr);
    } catch (e) {
      parsedAmount = 0.0;
      debugPrint('Error parsing amount: ${json['amount']} - $e');
    }

    // Menentukan Tipe Transaksi: Berdasarkan field 'type' di JSON
    TransactionType transactionType;
    String? typeString = json['type']?.toString().toLowerCase();
    if (typeString == 'withdraw' || typeString == 'pencairan') { // Tambahkan 'pencairan' sebagai alias
      transactionType = TransactionType.pencairan;
    } else if (typeString == 'insentif') {
      transactionType = TransactionType.insentif;
    } else {
      transactionType = TransactionType.other; // Tipe tidak dikenal
      debugPrint('Unknown transaction type: $typeString. Defaulting to other.');
    }

    return TransactionHistory(
      date: parsedDate,
      amount: parsedAmount,
      description: json['description'] ?? 'Tanpa Keterangan',
      type: transactionType,
      transactionDetail: json['detail_transaksi'] ?? json['description'] ?? '', // Menggunakan description jika detail_transaksi tidak ada
    );
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    String prefix = '';
    if (type == TransactionType.pencairan) {
      prefix = '-';
    } else if (type == TransactionType.insentif) {
      prefix = '+';
    }
    return '$prefix${formatter.format(amount)}';
  }

  String get formattedDay {
    return DateFormat('dd').format(date);
  }

  String get formattedMonthYear {
    return DateFormat('MMM yyyy').format(date); // Perbaiki format menjadi 3 huruf bulan + tahun
  }
}