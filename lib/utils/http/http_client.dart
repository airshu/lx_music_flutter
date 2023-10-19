import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/utils/http/interceptors/params_interceptor.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

import 'base_http.dart';

/// http请求封装类
class HttpCore extends BaseHttp {
  static HttpCore? _instance;
  static final _dio = Dio(BaseOptions(
    baseUrl: Urls.getBaseUrl(),
    connectTimeout: const Duration(milliseconds: 10 * 1000),
    receiveTimeout: const Duration(milliseconds: 10 * 1000),
    contentType: Headers.formUrlEncodedContentType,
  ));

  HttpCore._internal() : super(_dio) {
    _init();
  }

  static void changeBaseUrl(String url) {
    _dio.options.baseUrl = url;
    Logger.debug('changeBaseUrl  $url   ${_dio.options.baseUrl}');
  }

  static String getBaseUrl() {
    return _dio.options.baseUrl;
  }

  static String? getProxyIP() {
    return (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate?.toString();
  }

  void _init() {
    _dio.interceptors.add(ParamsInterceptor());
  }

  static void changeProxyIP(String ip) {}

  static HttpCore getInstance() {
    _instance ??= HttpCore._internal();
    return _instance!;
  }

  /// 下载文件
  ///
  /// [url] 网络文件url
  /// [savePath] 保存地址
  Future<Response> download(String url, String savePath) async {
    var response = await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {},
    );

    return response;
  }


}
