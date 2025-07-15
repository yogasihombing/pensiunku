class ArticleCategoryModel {
  final String name;

  ArticleCategoryModel({
    required this.name,
  });

  factory ArticleCategoryModel.fromJson(Map<String, dynamic> json) {
    return ArticleCategoryModel(
      name: json['name']?.toString() ?? '',
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
    final idValue = json['id'];
    int parsedId;
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else {
      parsedId = 0;
    }

    return ArticleModel(
      imageUrl: json['image']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      id: parsedId,
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
    final idValue = json['id'];
    int parsedId;
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else {
      parsedId = 0;
    }

    return MobileArticleModel(
      id: parsedId,
      // --- PERUBAHAN: Menggunakan key 'imageUrl' jika API mengirimkannya dengan nama itu, jika tidak fallback ke 'image' ---
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      // --- AKHIR PERUBAHAN ---
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      penulis: json['penulis']?.toString() ?? '',
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
    final idValue = json['id'];
    int parsedId;
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else {
      parsedId = 0;
    }
    
    return MobileArticleDetailModel(
      id: parsedId,
      title: json['title']?.toString() ?? '',
      // --- PERUBAHAN: Menggunakan key 'imageUrl' jika API mengirimkannya dengan nama itu, jika tidak fallback ke 'image' ---
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      // --- AKHIR PERUBAHAN ---
      category: json['category']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      penulis: json['penulis']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
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