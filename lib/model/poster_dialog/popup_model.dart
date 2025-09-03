class PopupModel {
  final String? image;
  final String? url;
  final bool isActive; // Properti ini

  PopupModel({
    this.image,
    this.url,
    this.isActive = true, // Tambahkan nilai default 'true' di sini
  });

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      image: json['gambar'] as String?,
      url: json['url'] as String?,
      isActive: true, // Atau set isActive ke true secara eksplisit
    );
  }
}
