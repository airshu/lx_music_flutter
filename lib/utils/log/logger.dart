import 'package:flutter/foundation.dart';

/// 日志工具
class Logger {

  static const int levelInfo = 1;
  static const int levelDebug = 2;
  static const int levelWarning = 3;
  static const int levelError = 4;

  /// 输出日志级别
  static int level = levelDebug;

  static void setLevel(int l) {
    level = l;
  }

  static void write(String msg, {bool isError = false}) {
    Future.microtask(() => print('Logger:write---> $msg [isError=$isError]'));
  }

  /// 调试输出
  /// [msg]  日志信息
  /// [module]  模块名
  static void debug(dynamic msg, {String module = ''}) {
    if (kDebugMode) {
      _print(msg.toString());
    }
  }

  static void _print(String msg, {String module = ''}) {
    Future.microtask(() => print('[$module] ${DateTime.now()}---> $msg'));
  }

  /// error级别的日志，需要做记录
  static void error(dynamic error) {
    if (kDebugMode) {
      _print(error.toString());
    }
  }


}
