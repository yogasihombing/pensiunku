class Categories {
  final int id;
  final String nama;

  Categories({
    required this.id,
    required this.nama,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class ListFranchise {
  final int id;
  final String nama;
  final String logo;
  final int kategori;

  ListFranchise({
    required this.id,
    required this.nama,
    required this.logo,
    required this.kategori,
  });

  factory ListFranchise.fromJson(Map<String, dynamic> json) {
    return ListFranchise(
      id: json['id'],
      nama: json['nama'],
      logo: json['logo'],
      kategori: json['kategori'],
    );
  }
}

class UsahaModel {
  // final String description;
  final List<Categories> categories;
  final List<ListFranchise> list;

  UsahaModel({
    // required this.description,
    required this.categories,
    required this.list,
  });

  factory UsahaModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> categoriesJson = json['categories'];
    List<dynamic> franchiseJson = json['list'];

    return UsahaModel(
      // description: json['description'],
      categories: categoriesJson.map((json) => Categories.fromJson(json)).toList(),
      list: franchiseJson.map((json) => ListFranchise.fromJson(json)).toList(),
    );
  }
}