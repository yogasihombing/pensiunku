class UserBankDetail {
  // Properti 'id' yang baru ditambahkan dan sangat penting.
  // Ini akan digunakan sebagai 'id_rekening' untuk API pengajuanWithdraw.
  final String id;
  final String bankName;
  final String
      accountNumber; // Menggunakan 'id' dari API sebagai nomor rekening
  final String accountHolderName;
  final String? bankLogoUrl; // URL logo bank, bisa null

  UserBankDetail({
    required this.id, // Pastikan 'id' ada dan required di konstruktor
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.bankLogoUrl,
  });

  // Factory constructor untuk membuat UserBankDetail dari JSON
  factory UserBankDetail.fromJson(Map<String, dynamic> json) {
    // Log untuk debugging, Anda bisa menghapusnya setelah yakin berfungsi
    // debugPrint('Parsing UserBankDetail from JSON: $json');

    // Menggunakan kunci yang sesuai dengan respons API getUserRekening
    // 'bank' untuk nama bank, 'id' untuk ID (yang kita gunakan sebagai accountNumber),
    // 'account_holder_name' untuk nama pemilik rekening.
    String bankName = json['bank'] ?? 'Nama Bank Tidak Diketahui';
    String idFromApi = json['id']?.toString() ?? ''; // Ambil 'id' dari JSON
    String accountNumber =
        idFromApi; // Gunakan 'id' dari API sebagai nomor rekening

    String accountHolderName =
        json['account_holder_name'] ?? 'Nama Pemilik Tidak Diketahui';
    String? bankLogoUrl = json['logo_bank']; // Ambil URL logo jika ada

    return UserBankDetail(
      id: idFromApi, // Set properti 'id' dari JSON
      bankName: bankName,
      accountNumber:
          accountNumber, // Set properti 'accountNumber' dari 'id' JSON
      accountHolderName: accountHolderName,
      bankLogoUrl: bankLogoUrl,
    );
  }

  // Metode untuk membuat representasi string yang cocok untuk DropdownButtonFormField
  @override
  String toString() {
    return '$bankName - Rek: ${accountNumber} (Pemilik: $accountHolderName)';
    // Atau jika Anda ingin menampilkan ID:
    // return '$bankName - ID: $id (Pemilik: $accountHolderName)';
  }
}
