class ResultModel<T> {
  final bool isSuccess;
  final String? message; // Ditambahkan
  final String? error;
  final T? data;
  final bool isFromCache; // Ditambahkan

  ResultModel({
    required this.isSuccess,
    this.message, // Ditambahkan
    this.error,
    this.data,
    this.isFromCache = false, // Nilai default false
  });

  @override
  String toString() {
    return {
      'message': message,
      'error': error,
      'data': data.toString(),
      'isFromCache': isFromCache, // Ditambahkan
    }.toString();
  }
}
