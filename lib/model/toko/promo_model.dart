class PromoModel {
  final String imageUrl;
  final String? url;

  PromoModel({
    required this.imageUrl,
    required this.url,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      // Perubahan yang kamu buat: Memastikan 'image' diurai dengan aman sebagai String
      imageUrl: json['image']?.toString() ?? '', // Default ke string kosong jika null
      // Perubahan yang kamu buat: Memastikan 'url' diurai dengan aman sebagai String?
      url: json['url']?.toString(), // Akan null jika json['url'] adalah null
    );
  }

  Map<String, dynamic> toJson(int order) {
    return {
      'image': imageUrl,
      'url': url,
      'item_order': order,
    };
  }
}
