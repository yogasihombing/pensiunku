class ApiUtil {
  static Map<String, String> getTokenHeaders(String token) {
    return {
      'Authorization': token,
      'Content-Type': 'application/json', // tambahkan ini jika perlu
    };
  }
}
