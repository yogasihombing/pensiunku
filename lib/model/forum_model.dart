class ForumFotoModel {
  String? path;
  // --- PERUBAHAN: Menambahkan field 'type' dan memastikan parsing aman ---
  int? type;

  ForumFotoModel({
    required this.path,
    this.type, // type bisa null jika tidak ada di JSON
  });

  factory ForumFotoModel.fromJson(Map<String, dynamic> json) {
    return ForumFotoModel(
      path: json['path']?.toString(),
      // --- PERUBAHAN: Parsing 'type' dengan aman (handle 'tipe' atau 'type' dan String ke int) ---
      type: json['type'] is String ? int.tryParse(json['type']) : json['type'],
      // --- AKHIR PERUBAHAN ---
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

  ForumkomentarModel({
    required this.content,
    required this.nama,
  });

  factory ForumkomentarModel.fromJson(Map<String, dynamic> json) {
    return ForumkomentarModel(
      content: json['content']?.toString(),
      nama: json['nama']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'nama': nama,
    };
  }
}

class ForumDetailModel {
  int? id_forum;
  String? nama;
  DateTime? created_at;
  String? content;
  int? total_comment;
  int? total_like;
  List<ForumkomentarModel>? comment;
  List<ForumFotoModel>? foto;

  ForumDetailModel({
    required this.id_forum,
    required this.nama,
    required this.content,
    required this.created_at,
    this.total_like,
    this.total_comment,
    this.comment,
    this.foto,
  });

  factory ForumDetailModel.fromJson(Map<String, dynamic> json) {
    // Perubahan: Parsing id_forum dengan aman
    int? parsedIdForum;
    final idForumValue = json['id_forum'];
    if (idForumValue is int) {
      parsedIdForum = idForumValue;
    } else if (idForumValue is String && idForumValue.isNotEmpty) {
      parsedIdForum = int.tryParse(idForumValue);
    }

    // Perubahan: Parsing created_at dengan aman
    DateTime? parsedCreatedAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtValue);
    }

    // Perubahan: Parsing total_comment dengan aman
    int? parsedTotalComment;
    final totalCommentValue = json['total_comment'];
    if (totalCommentValue is int) {
      parsedTotalComment = totalCommentValue;
    } else if (totalCommentValue is String && totalCommentValue.isNotEmpty) {
      parsedTotalComment = int.tryParse(totalCommentValue);
    }

    // Perubahan: Parsing total_like dengan aman
    int? parsedTotalLike;
    final totalLikeValue = json['total_like'];
    if (totalLikeValue is int) {
      parsedTotalLike = totalLikeValue;
    } else if (totalLikeValue is String && totalLikeValue.isNotEmpty) {
      parsedTotalLike = int.tryParse(totalLikeValue);
    }

    List<dynamic> fotoJson = json['foto'] is List ? json['foto'] : [];
    List<dynamic> komentarJson = json['comment'] is List ? json['comment'] : [];

    return ForumDetailModel(
      id_forum: parsedIdForum,
      nama: json['nama']?.toString(),
      content: json['content']?.toString(),
      created_at: parsedCreatedAt,
      total_comment: parsedTotalComment,
      total_like: parsedTotalLike,
      comment: komentarJson
          .map((komentar) => ForumkomentarModel.fromJson(komentar))
          .toList(),
      foto: fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': id_forum,
      'nama': nama,
      'created_at': created_at?.toIso8601String(),
      'content': content,
      'total_comment': total_comment,
      'total_like': total_like,
      'comment': comment?.map((comment) => comment.toJson()).toList() ?? [],
      'foto': foto?.map((foto) => foto.toJson()).toList() ?? [],
    };
  }
}

class ForumModel {
  int? id_forum;
  int? id_user;
  String? phone;
  String? nama;
  DateTime? created_at;
  String? content;
  int? total_comment;
  int? total_like;
  List<ForumkomentarModel>? comment;
  List<ForumFotoModel>? foto;

  ForumModel({
    required this.id_forum,
    this.id_user,
    this.phone,
    required this.nama,
    required this.content,
    required this.created_at,
    this.total_comment,
    this.total_like,
    this.comment,
    this.foto,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
    // Perubahan: Parsing id_forum dengan aman
    int? parsedIdForum;
    final idForumValue = json['id_forum'];
    if (idForumValue is int) {
      parsedIdForum = idForumValue;
    } else if (idForumValue is String && idForumValue.isNotEmpty) {
      parsedIdForum = int.tryParse(idForumValue);
    }

    // Perubahan: Parsing id_user dengan aman
    int? parsedIdUser;
    final idUserValue = json['id_user'];
    if (idUserValue is int) {
      parsedIdUser = idUserValue;
    } else if (idUserValue is String && idUserValue.isNotEmpty) {
      parsedIdUser = int.tryParse(idUserValue);
    }

    // Perubahan: Parsing created_at dengan aman
    DateTime? parsedCreatedAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is String && createdAtValue.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAtValue);
    }

    // Perubahan: Parsing total_comment dengan aman
    int? parsedTotalComment;
    final totalCommentValue = json['total_comment'];
    if (totalCommentValue is int) {
      parsedTotalComment = totalCommentValue;
    } else if (totalCommentValue is String && totalCommentValue.isNotEmpty) {
      parsedTotalComment = int.tryParse(totalCommentValue);
    }

    // Perubahan: Parsing total_like dengan aman
    int? parsedTotalLike;
    final totalLikeValue = json['total_like'];
    if (totalLikeValue is int) {
      parsedTotalLike = totalLikeValue;
    } else if (totalLikeValue is String && totalLikeValue.isNotEmpty) {
      parsedTotalLike = int.tryParse(totalLikeValue);
    }

    List<dynamic> fotoJson = json['foto'] is List ? json['foto'] : [];
    List<dynamic> komentarJson = json['comment'] is List ? json['comment'] : [];

    return ForumModel(
      id_forum: parsedIdForum,
      id_user: parsedIdUser,
      phone: json['phone']?.toString(),
      nama: json['nama']?.toString(),
      content: json['content']?.toString(),
      created_at: parsedCreatedAt,
      total_comment: parsedTotalComment,
      total_like: parsedTotalLike,
      comment: komentarJson.map((komentar) => ForumkomentarModel.fromJson(komentar)).toList(),
      foto: fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': id_forum,
      'id_user': id_user,
      'phone': phone,
      'nama': nama,
      'created_at': created_at?.toIso8601String(),
      'content': content,
      'forum_comment_count': total_comment,
      'total_like': total_like,
      'comment': comment?.map((comment) => comment.toJson()).toList() ?? [],
      'foto': foto?.map((foto) => foto.toJson()).toList() ?? [],
    };
  }
}
