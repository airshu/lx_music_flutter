import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart' as convert;
import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';

class ParamsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String url = options.uri.path;

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

}
