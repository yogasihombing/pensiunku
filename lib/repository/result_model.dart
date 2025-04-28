class ResultModel<T> {
  final bool isSuccess;
  final String? message;
  final String? error;
  final T? data;
   final bool isFromCache; 

  ResultModel({
    required this.isSuccess,
    this.message,
    this.error,
    this.data,
    errorMessage,
     this.isFromCache = false, // Nilai default false
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
