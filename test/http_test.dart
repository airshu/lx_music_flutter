
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {


  test('description', () async {
    var response = await Dio().get('http://baidu.com');

  });
}