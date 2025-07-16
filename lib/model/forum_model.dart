class ForumFotoModel {
  String? path;
  int? type;

  ForumFotoModel({
    required this.path,
    this.type, // type bisa null jika tidak ada di JSON
  });

  factory ForumFotoModel.fromJson(Map<String, dynamic> json) {
    return ForumFotoModel(
      path: json['path']?.toString(),
      type: json['type'] is String ? int.tryParse(json['type']) : json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type,
    };
  }
}

class ForumkomentarModel {
  String? content;
  String? nama;
  DateTime? createdAt; // Mengubah created_at menjadi createdAt

  ForumkomentarModel({
    required this.content,
    required this.nama,
    this.createdAt, // Menggunakan createdAt di konstruktor
  });

  factory ForumkomentarModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    final createdAtValue = json['created_at']; // Tetap baca dari 'created_at' JSON
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtValue);
    }

    return ForumkomentarModel(
      content: json['content']?.toString(),
      nama: json['nama']?.toString(),
      createdAt: parsedCreatedAt, // Gunakan parsed value untuk properti model
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'nama': nama,
      'created_at': createdAt?.toIso8601String(), // Tetap tulis ke 'created_at' JSON
    };
  }
}

class ForumDetailModel {
  int? idForum; // Mengubah id_forum menjadi idForum
  String? nama;
  DateTime? createdAt; // Mengubah created_at menjadi createdAt
  String? content;
  int? totalComment; // Mengubah total_comment menjadi totalComment
  int? totalLike; // Mengubah total_like menjadi totalLike
  List<ForumkomentarModel>? comment;
  List<ForumFotoModel>? foto;

  ForumDetailModel({
    required this.idForum, // Menggunakan idForum di konstruktor
    required this.nama,
    required this.content,
    required this.createdAt, // Menggunakan createdAt di konstruktor
    this.totalLike,
    this.totalComment,
    this.comment,
    this.foto,
  });

  factory ForumDetailModel.fromJson(Map<String, dynamic> json) {
    // Perubahan: Parsing idForum dengan aman
    int? parsedIdForum;
    final idForumValue = json['id_forum']; // Tetap baca dari 'id_forum' JSON
    if (idForumValue is int) {
      parsedIdForum = idForumValue;
    } else if (idForumValue is String && idForumValue.isNotEmpty) {
      parsedIdForum = int.tryParse(idForumValue);
    }

    // Perubahan: Parsing createdAt dengan aman
    DateTime? parsedCreatedAt;
    final createdAtValue = json['created_at']; // Tetap baca dari 'created_at' JSON
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtValue);
    }

    // Perubahan: Parsing totalComment dengan aman
    int? parsedTotalComment;
    final totalCommentValue = json['total_comment']; // Tetap baca dari 'total_comment' JSON
    if (totalCommentValue is int) {
      parsedTotalComment = totalCommentValue;
    } else if (totalCommentValue is String && totalCommentValue.isNotEmpty) {
      parsedTotalComment = int.tryParse(totalCommentValue);
    }

    // Perubahan: Parsing totalLike dengan aman
    int? parsedTotalLike;
    final totalLikeValue = json['total_like']; // Tetap baca dari 'total_like' JSON
    if (totalLikeValue is int) {
      parsedTotalLike = totalLikeValue;
    } else if (totalLikeValue is String && totalLikeValue.isNotEmpty) {
      parsedTotalLike = int.tryParse(totalLikeValue);
    }

    List<dynamic> fotoJson = json['foto'] is List ? json['foto'] : [];
    List<dynamic> komentarJson = json['comment'] is List ? json['comment'] : [];

    return ForumDetailModel(
      idForum: parsedIdForum, // Gunakan idForum yang sudah di-parse
      nama: json['nama']?.toString(),
      content: json['content']?.toString(),
      createdAt: parsedCreatedAt, // Gunakan createdAt yang sudah di-parse
      totalComment: parsedTotalComment, // Gunakan totalComment yang sudah di-parse
      totalLike: parsedTotalLike, // Gunakan totalLike yang sudah di-parse
      comment: komentarJson
          .map((komentar) => ForumkomentarModel.fromJson(komentar))
          .toList(),
      foto: fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': idForum, // Tetap tulis ke 'id_forum' JSON
      'nama': nama,
      'created_at': createdAt?.toIso8601String(), // Tetap tulis ke 'created_at' JSON
      'content': content,
      'total_comment': totalComment, // Tetap tulis ke 'total_comment' JSON
      'total_like': totalLike, // Tetap tulis ke 'total_like' JSON
      'comment': comment?.map((comment) => comment.toJson()).toList() ?? [],
      'foto': foto?.map((foto) => foto.toJson()).toList() ?? [],
    };
  }
}

class ForumModel {
  int? idForum; // Mengubah id_forum menjadi idForum
  int? idUser; // Mengubah id_user menjadi idUser
  String? phone;
  String? nama;
  DateTime? createdAt; // Mengubah created_at menjadi createdAt
  String? content;
  int? totalComment; // Mengubah total_comment menjadi totalComment
  int? totalLike; // Mengubah total_like menjadi totalLike
  List<ForumkomentarModel>? comment;
  List<ForumFotoModel>? foto;

  ForumModel({
    required this.idForum, // Menggunakan idForum di konstruktor
    this.idUser,
    this.phone,
    required this.nama,
    required this.content,
    required this.createdAt, // Menggunakan createdAt di konstruktor
    this.totalComment,
    this.totalLike,
    this.comment,
    this.foto,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
    // Perubahan: Parsing idForum dengan aman
    int? parsedIdForum;
    final idForumValue = json['id_forum']; // Tetap baca dari 'id_forum' JSON
    if (idForumValue is int) {
      parsedIdForum = idForumValue;
    } else if (idForumValue is String && idForumValue.isNotEmpty) {
      parsedIdForum = int.tryParse(idForumValue);
    }

    // Perubahan: Parsing idUser dengan aman
    int? parsedIdUser;
    final idUserValue = json['id_user']; // Tetap baca dari 'id_user' JSON
    if (idUserValue is int) {
      parsedIdUser = idUserValue;
    } else if (idUserValue is String && idUserValue.isNotEmpty) {
      parsedIdUser = int.tryParse(idUserValue);
    }

    // Perubahan: Parsing createdAt dengan aman
    DateTime? parsedCreatedAt;
    final createdAtValue = json['created_at']; // Tetap baca dari 'created_at' JSON
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtValue);
    }

    // Perubahan: Parsing totalComment dengan aman
    int? parsedTotalComment;
    final totalCommentValue = json['total_comment']; // Tetap baca dari 'total_comment' JSON
    if (totalCommentValue is int) {
      parsedTotalComment = totalCommentValue;
    } else if (totalCommentValue is String && totalCommentValue.isNotEmpty) {
      parsedTotalComment = int.tryParse(totalCommentValue);
    }

    // Perubahan: Parsing totalLike dengan aman
    int? parsedTotalLike;
    final totalLikeValue = json['total_like']; // Tetap baca dari 'total_like' JSON
    if (totalLikeValue is int) {
      parsedTotalLike = totalLikeValue;
    } else if (totalLikeValue is String && totalLikeValue.isNotEmpty) {
      parsedTotalLike = int.tryParse(totalLikeValue);
    }

    List<dynamic> fotoJson = json['foto'] is List ? json['foto'] : [];
    List<dynamic> komentarJson = json['comment'] is List ? json['comment'] : [];

    return ForumModel(
      idForum: parsedIdForum, // Gunakan idForum yang sudah di-parse
      idUser: parsedIdUser, // Gunakan idUser yang sudah di-parse
      phone: json['phone']?.toString(),
      nama: json['nama']?.toString(),
      content: json['content']?.toString(),
      createdAt: parsedCreatedAt, // Gunakan createdAt yang sudah di-parse
      totalComment: parsedTotalComment, // Gunakan totalComment yang sudah di-parse
      totalLike: parsedTotalLike, // Gunakan totalLike yang sudah di-parse
      comment: komentarJson.map((komentar) => ForumkomentarModel.fromJson(komentar)).toList(),
      foto: fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': idForum, // Tetap tulis ke 'id_forum' JSON
      'id_user': idUser, // Tetap tulis ke 'id_user' JSON
      'phone': phone,
      'nama': nama,
      'created_at': createdAt?.toIso8601String(), // Tetap tulis ke 'created_at' JSON
      'content': content,
      'total_comment': totalComment, // Tetap tulis ke 'total_comment' JSON
      'total_like': totalLike, // Tetap tulis ke 'total_like' JSON
      'comment': comment?.map((comment) => comment.toJson()).toList() ?? [],
      'foto': foto?.map((foto) => foto.toJson()).toList() ?? [],
    };
  }
}