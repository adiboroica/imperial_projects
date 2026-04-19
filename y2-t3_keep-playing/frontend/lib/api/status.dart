/// HTTP status code constants used across the app.
///
/// `dart:io` exports `HttpStatus` but isn't available on the web build, so we
/// keep a minimal subset here covering the codes we actually check.
class HttpStatus {
  HttpStatus._();

  static const int ok = 200;
  static const int badRequest = 400;
}
