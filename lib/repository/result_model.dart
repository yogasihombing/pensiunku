class ResultModel<T> {
  final bool isSuccess;
  final String? message;
  final String? error;
  final T? data;

  ResultModel({
    required this.isSuccess,
    this.message,
    this.error,
    this.data,
  });

  @override
  String toString() {
    return {
      'isSuccess': isSuccess,
      'message': message,
      'error': error,
      'data': data.toString(),
    }.toString();
  }
}
