import 'package:intl/intl.dart';

/// Notification model
///
class NotificationModel {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? url;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.url,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      readAt:
          json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': DateFormat('y-MM-dd HH:mm:ss').format(createdAt),
      'read_at': readAt != null
          ? DateFormat('y-MM-dd HH:mm:ss').format(readAt!)
          : null,
      'url': url,
    };
  }
}
