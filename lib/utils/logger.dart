import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger();

  static void init({Level level = Level.debug}) {
    if (kDebugMode) {
      Logger.level = level; // Enable logging in debug mode
    } else {
      Logger.level = Level.off; // Disable logging in release mode
    }
  }

  static void d(dynamic message) {
    if (kDebugMode) _logger.d(_stringify(message));
  }

  static void i(dynamic message) {
    if (kDebugMode) _logger.i(_stringify(message));
  }

  static void w(dynamic message) {
    if (kDebugMode) _logger.w(_stringify(message));
  }

  static void e(dynamic message) {
    if (kDebugMode) _logger.e(_stringify(message));
  }

  static String _stringify(dynamic message) {
    return message.toString();
  }
}
