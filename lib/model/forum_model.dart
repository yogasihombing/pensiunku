// ignore_for_file: non_constant_identifier_names

class ForumFotoModel {
  String? path;

  ForumFotoModel({
    required this.path,
  });

  ForumFotoModel.fromJson(Map<String, dynamic> json) {
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
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

  ForumkomentarModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    nama = json['nama'];
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

  ForumDetailModel.fromJson(Map<String, dynamic> json) {
    id_forum = json['id_forum'];
    nama = json['nama'];
    content = json['content'];
    created_at = DateTime.parse(json['created_at']);
    List<dynamic> fotoJson = json['foto'];
    List<dynamic> komentarJson = json['comment'];
    total_comment = json['total_comment'];
    total_like = json['total_like'];
    comment = komentarJson
        .map((komentar) => ForumkomentarModel.fromJson(komentar))
        .toList();
    foto = fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': id_forum,
      'nama': nama,
      'created_at': created_at.toString(),
      'content': content,
      'total_comment': total_comment,
      'total_like': total_like,
      'comment': comment!.map((comment) => comment.toJson()).toList(),
      'foto': foto!.map((foto) => foto.toJson()).toList(),
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

  ForumModel.fromJson(Map<String, dynamic> json) {
    id_forum = json['id_forum'];
    id_user = json['id_user'];
    phone = json['phone'];
    nama = json['nama'];
    content = json['content'];
    created_at = DateTime.parse(json['created_at']);
    total_comment = json['total_comment'];
    total_like = json['total_like'];
    List<dynamic> fotoJson = json['foto'];
    foto = fotoJson.map((foto) => ForumFotoModel.fromJson(foto)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_forum': id_forum,
      'id_user': id_user,
      'phone': phone,
      'nama': nama,
      'created_at': created_at.toString(),
      'content': content,
      'forum_comment_count': total_comment,
      'total_like': total_like,
      'foto': foto!.map((foto) => foto.toJson()).toList(),
    };
  }
}
