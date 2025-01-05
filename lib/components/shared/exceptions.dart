
class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = "App está sem conexão a internet!"]);

  @override
  String toString() => "NoInternetException: $message";
}
