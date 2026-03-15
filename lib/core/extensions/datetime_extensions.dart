extension DateTimeExtensions on DateTime {
  /// Unix milliseconds timestamp.
  int get unixMillis => millisecondsSinceEpoch;

  /// Create DateTime from Unix milliseconds.
  static DateTime fromUnixMillis(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis);
}
