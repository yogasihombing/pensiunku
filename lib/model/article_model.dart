class ArticleCategoryModel {
  final String name;

  ArticleCategoryModel({
    required this.name,
  });

  factory ArticleCategoryModel.fromJson(Map<String, dynamic> json) {
    return ArticleCategoryModel(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson(int order) {
    return {
      'name': name,
      'item_order': order,
    };
  }
}

class ArticleModel {
  final String imageUrl;
  final String url;
  final String title;
  final String category;
  final int id;

  ArticleModel({
    required this.imageUrl,
    required this.url,
    required this.title,
    required this.category,
    required this.id,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      imageUrl: json['image'],
      title: json['title'],
      category: json['category'],
      url: json['url'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson(int order) {
    return {
      'image': imageUrl,
      'title': title,
      'category': category,
      'url': url,
      'item_order': order,
      'id': id
    };
  }
}

class MobileArticleModel {
  final int id;
  final String imageUrl;
  final String url;
  final String title;
  final String category;
  final String tanggal;
  final String penulis;

  MobileArticleModel({
    required this.id,
    required this.imageUrl,
    required this.url,
    required this.title,
    required this.category,
    required this.tanggal,
    required this.penulis,
  });

  factory MobileArticleModel.fromJson(Map<String, dynamic> json) {
    return MobileArticleModel(
      id: json['id'],
      imageUrl: json['image'],
      title: json['title'],
      category: json['category'],
      url: json['url'],
      tanggal: json['tanggal'],
      penulis: json['penulis']
    );
  }

  Map<String, dynamic> toJson(int order) {
    return {
      'id': id,
      'image': imageUrl,
      'title': title,
      'category': category,
      'url': url,
      'item_order': order,
      'tanggal': tanggal,
      'penulis': penulis
    };
  }
}

class MobileArticleDetailModel {
  final int id;
  final String title;
  final String imageUrl;
  final String category;
  final String tanggal;
  final String penulis;
  final String content;

  MobileArticleDetailModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.tanggal,
    required this.penulis,
    required this.content,
  });

  factory MobileArticleDetailModel.fromJson(Map<String, dynamic> json) {
    return MobileArticleDetailModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      tanggal: json['tanggal'],
      penulis: json['penulis'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson(int order) {
    return {
      'id': id,
      'image': imageUrl,
      'title': title,
      'category': category,
      'item_order': order,
      'tanggal': tanggal,
      'penulis': penulis,
      'content': content,
    };
  }
}
