class NoInternetException implements Exception {
  NoInternetException([this.message = 'no_internet']);

  final String message;

  @override
  String toString() => message;
}
