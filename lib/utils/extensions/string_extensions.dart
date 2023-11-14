import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

extension StringExtensions on String {

  String get md5 {
    final bytes = utf8.encode(this);
    return crypto.md5.convert(bytes).toString();
  }
}