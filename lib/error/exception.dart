class HttpsException implements Exception{
  final String message;

  HttpsException(this.message);

  @override
  String toString() {
    return message;
  }
}