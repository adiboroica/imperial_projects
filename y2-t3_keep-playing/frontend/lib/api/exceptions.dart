class ApiException implements Exception {
  final int statusCode;
  final String body;

  const ApiException({required this.statusCode, required this.body});

  String get message => 'Request failed ($statusCode)';

  @override
  String toString() => 'ApiException: $message';
}
