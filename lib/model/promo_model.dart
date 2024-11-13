class PromoModel {
  final String imageUrl;
  final String? url;

  PromoModel({
    required this.imageUrl,
    required this.url,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      imageUrl: json['image'],
      url: json['url'],
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
