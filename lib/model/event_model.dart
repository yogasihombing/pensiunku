class EventModel{
  final int id;
  final String nama;
  final String tempat;
  final String tanggal;
  final String foto;

  EventModel({
    required this.id,
    required this.nama,
    required this.tempat,
    required this.tanggal,
    required this.foto
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        id: json['id'],
        nama: json['nama'],
        tempat: json['tempat'],
        tanggal: json['tanggal'],
        foto: json['foto']
      );
  }
}

class EventDetailModel{
  final int status;
  final String eflyer;
  final String nama;
  final String tanggal;
  final String waktu;
  final String tempat;
  final String alamat;  
  final String description;
  final String? link;
  final List<EventFotoModel> foto;

  EventDetailModel({
    required this.status, 
    required this.eflyer, 
    required this.nama, 
    required this.tanggal, 
    required this.waktu, 
    required this.tempat, 
    required this.alamat, 
    required this.description,
    this.link,
    required this.foto, });

  factory EventDetailModel.fromJson(Map<String, dynamic> json){
    List<dynamic> fotoJson = json['foto'];

    return EventDetailModel(
      status: json['status'], 
      eflyer: json['eflyer'], 
      nama: json['nama'], 
      tanggal: json['tanggal'], 
      waktu: json['waktu'], 
      tempat: json['tempat'], 
      alamat: json['alamat'], 
      description: json['description'],
      link: json['link'],
      foto: fotoJson.map((json) => EventFotoModel.fromJson(json)).toList(), );
  }

  }

  class EventFotoModel{
    final String path;
    final int type;

    EventFotoModel({
      required this.path,
      required this.type,
    });

    factory EventFotoModel.fromJson(Map<String, dynamic> json){
      return EventFotoModel(
        path: json['path'],
        type : json['tipe']
      );
    }
  }