import 'package:intl/intl.dart';

class LiveUpdateModel {
  final String imageUrl;
  final String title;
  final String plafond;
  final DateTime timestamp;

  LiveUpdateModel({
    required this.imageUrl,
    required this.title,
    required this.plafond,
    required this.timestamp,
  });

  factory LiveUpdateModel.fromJson(Map<String, dynamic> json) {
    return LiveUpdateModel(
      imageUrl: json['image'],
      timestamp: DateTime.parse(json['l1']),
      title: json['l2'],
      plafond: json['l3'],
    );
  }

  Map<String, dynamic> toJson(int newOrder) {
    return {
      'image': imageUrl,
      'l1': DateFormat('y-MM-dd HH:mm:ss').format(timestamp),
      'l1_millis': timestamp.millisecond,
      'l2': title,
      'l3': plafond,
    };
  }
}
