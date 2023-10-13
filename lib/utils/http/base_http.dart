import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as xp_get;
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/utils/http/entity.dart';
import 'package:lx_music_flutter/utils/http/http_exception.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:convert/convert.dart' as convert;

class HttpCode {
  static const int SUCCESS = 2000; // 有点奇怪，后台接口返回的正常code=2000
  static const int CREATE_TEST_DRIVE_FAILED_1 = 2001; // 添加试驾失败，表示不能创建试驾 同一个客户 同一个时间段已存在一个预约
  static const int CREATE_TEST_DRIVE_FAILED_2 = 2002; // 添加试驾失败，表示不能创建试驾 同一个商机 已有进行中的试驾
  static const int CREATE_TEST_DRIVE_FAILED_3 = 2003; // 添加试驾失败，表示不能创建试驾 时间段被占用
  static const int TOKEN_4000 = 4000; // token 过期
  static const int TOKEN_4001 = 4001; // token 失效
}

class BaseHttp {
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static String? accessToken;
  static String? refreshToken;

  final Dio dio;

  ///  包信息
  ///  String appName = packageInfo.appName;
  /// String packageName = packageInfo.packageName;
  /// String version = packageInfo.version;
  /// String buildNumber = packageInfo.buildNumber;
  PackageInfo? packageInfo;
  var androidInfo;
  IosDeviceInfo? iosInfo;
  var isRefreshToken = false;
  Queue queue = Queue();

  BaseHttp(this.dio) {
    dio.options.connectTimeout = const Duration(milliseconds: 10 * 1000);
  }

  /// get method
  ///
  /// [cancelToken] 可取消该请求，cancelToken.cancel();
  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
  }) async {
    options ??= Options();
    options.extra ??= {};
    headers = headers ??= {};
    handleRequestData(url, headers, options.extra!, GET);
    return _request(
      url,
      method: GET,
      params: params,
      data: data,
      options: options,
      cancelToken: cancelToken,
      headers: headers,
      getResponse: getResponse,
    );
  }

  Future<T> getEntity<T>(
    String url,
    EntityFactory<T> factory, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
    Map<String, dynamic>? headers,
  }) async {
    options ??= Options();
    options.extra ??= {};
    handleRequestData(url, headers ?? {}, options.extra!, GET);

    var responseEntity = await getResponseEntity<T>(url, factory,
        headers: headers, params: params, options: options, cancelToken: cancelToken, getResponse: getResponse);
    if (responseEntity.code != HttpCode.SUCCESS) {
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
    }
    return responseEntity.data;
  }

  Future<ResponseEntity<T>> getResponseEntity<T>(
    String url,
    EntityFactory<T> factory, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
    Map<String, dynamic>? headers,
  }) async {
    var res = await get(url, params: params, headers: headers, options: options, cancelToken: cancelToken, getResponse: getResponse);
    // Logger.debug('\n\n\n==========>>>>>>>>>>>>>>>>$url>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    // Logger.debug(res);
    // Logger.debug('==========>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n');
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  /// post method
  Future<dynamic> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgressCallback,
    Map<String, dynamic>? headers,
    bool getResponse = false,
  }) async {
    options ??= Options();
    options.extra ??= {};
    headers = headers ??= {};
    handleRequestData(url, headers, options.extra!, POST);

    return _request(
      url,
      method: POST,
      params: params,
      headers: headers,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgressCallback: onSendProgressCallback,
      getResponse: getResponse,
    );
  }

  Future<dynamic> delete(String url,
      {dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    return _request(url,
        method: DELETE,
        params: params,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
  }

  /// 设置json格式
  Future<dynamic> postByOptionsJson(String url,
      {dynamic data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    options ??= Options();
    options.contentType = Headers.jsonContentType;

    options.extra ??= {};
    headers = headers ??= {};
    handleRequestData(url, headers, options.extra!, POST);
    return _request(url,
        method: POST,
        headers: headers,
        params: params,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
  }

  Future<dynamic> getByOptionsJson(String url,
      {dynamic data,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    options ??= Options();
    options.contentType = Headers.jsonContentType;

    options.extra ??= {};
    headers ??= {};
    handleRequestData(url, headers, options.extra!, GET);

    return _request(url,
        method: GET,
        headers: headers,
        params: params,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
  }

  Future<T> postEntity<T>(
    String url,
    EntityFactory<T>? factory, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
  }) async {
    options ??= Options();
    options.extra ??= {};
    headers = headers ??= {};
    handleRequestData(url, headers, options.extra!, POST);

    var responseEntity = await postResponseEntity<T>(url, factory,
        data: data, headers: headers, params: params, options: options, cancelToken: cancelToken);
    if (responseEntity.code != ResponseCode.SUCCESS && responseEntity.code != HttpCode.SUCCESS) {
      Logger.debug(responseEntity);
      Logger.debug('####' * 20);
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg, subMsg: responseEntity.subMsg);
    }
    return responseEntity.data;
  }

  Future<ResponseEntity<T>> postResponseEntity<T>(
    String url,
    EntityFactory<T>? factory, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
    Map<String, dynamic>? headers,
  }) async {
    var res = await post(url, data: data, headers: headers, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  /// patch method
  Future<dynamic> patch(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
  }) async {
    return _request(url, method: PATCH, params: params, options: options, cancelToken: cancelToken, getResponse: getResponse);
  }

  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool getResponse = false,
  }) async {
    return _request(url, method: PUT, params: params, options: options, cancelToken: cancelToken, getResponse: getResponse);
  }

  Future<dynamic> putByOptionsJson(
    String url, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgressCallback,
    bool getResponse = false,
  }) async {
    options ??= Options();
    options.contentType = Headers.jsonContentType;
    return _request(
      url,
      method: PUT,
      params: params,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgressCallback: onSendProgressCallback,
      getResponse: getResponse,
    );
  }

  Future<T> patchEntity<T>(
    String url,
    EntityFactory<T> factory, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var responseEntity = await patchResponseEntity<T>(url, factory, params: params, options: options, cancelToken: cancelToken);
    if (responseEntity.code != ResponseCode.SUCCESS && responseEntity.code != HttpCode.SUCCESS) {
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
    }
    return responseEntity.data;
  }

  Future<ResponseEntity<T>> patchResponseEntity<T>(
    String url,
    EntityFactory<T> factory, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var res = await patch(url, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  /// 发起网络请求
  Future<dynamic> _request(
    String url, {
    String? method,
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgressCallback,
    bool getResponse = false, //返回未处理数据
  }) async {
    String errorMsg = '';
    int statusCode = -1;
    Response? response = await _getResponse(url,
        method: method,
        data: data,
        params: params,
        headers: headers,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback,
        aDio: dio);
    Logger.debug('调用接口:  ----data=$data-------params=$params------------------------> $url ');
    if (getResponse == true) {
      return response;
    }

    statusCode = response?.statusCode ?? -1;
    if (statusCode < 0) {
      errorMsg = 'Network request error, code: $statusCode';
      throw HttpResponseNot200Exception(errorMsg);
    }
    if (response?.data is Map<String, dynamic>) {
      Map<String, dynamic>? data = response?.data;
      int code = HttpCode.SUCCESS;
      return response?.data;
    }
    Map<String, dynamic>? map;
    try {
      map = json.decode(response?.data);
    } catch (error) {
      try {
        map = json.decode(response?.data);
      } catch (error) {
        Logger.debug('===http error===> $error');
      }
    }
    return map ?? response?.data;
  }

  /// 返回重新请求响应体
  Future<Response?> _getResponse(String url,
      {String? method,
      dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback,
      Dio? aDio,
      Map<String, dynamic>? headers}) async {
    Response? response;
    // 使用新的dio
    Dio tokenDio = aDio ??
        Dio(BaseOptions(
          baseUrl: Urls.getBaseUrl(),
          connectTimeout: const Duration(milliseconds: 10 * 1000),
          receiveTimeout: const Duration(milliseconds: 10 * 1000),
          contentType: Headers.formUrlEncodedContentType,
        ));
    options ??= Options();
    options.headers = headers ?? {};
    options.headers ??= {};
    Logger.debug('>>>>>开始调用接口:'
        '$url-----headers=${options.headers}--params=$params--------data=$data--------------------->');
    switch (method) {
      case GET:
        response = await tokenDio.get(url, data: data, queryParameters: params, options: options, cancelToken: cancelToken);
        break;
      case POST:
        response = await tokenDio.post(url,
            data: data, queryParameters: params, options: options, cancelToken: cancelToken, onSendProgress: onSendProgressCallback);
        break;
      case PATCH:
        response = await tokenDio.patch(url, data: data, queryParameters: params, options: options, cancelToken: cancelToken);
        break;
      case PUT:
        response = await tokenDio.put(url, data: data, queryParameters: params, options: options, cancelToken: cancelToken);
        break;
      case DELETE:
        response = await tokenDio.delete(url, data: data, queryParameters: params, options: options, cancelToken: cancelToken);
        break;
      default:
        throw 'error';
    }
    return response;
  }

  static RegExp regx = RegExp(r'(?:\d\w)+');

  /// 对请求参数预处理
  void handleRequestData(String url, Map<String, dynamic> headers, Map options, String method) {
    Logger.debug('handleRequestData:  url=$url, headers=$headers, options=$options');
    if(method == POST) {
      if (options['form'] != null) {
        headers['Content-Type'] = Headers.formUrlEncodedContentType;
        List formBody = [];
        for (final key in options['form'].keys) {
          final value = options['form'][key];
          String encodedKey = Uri.encodeComponent(key);
          String encodedValue = Uri.encodeComponent(value);
          formBody.add('$encodedKey=$encodedValue}');
        }
        options['body'] = formBody.join('&');
        options.remove('form');
      } else if (options['formData'] != null) {
        headers['Content-Type'] = Headers.multipartFormDataContentType;

        List formBody = [];
        for (final key in options['formData'].keys) {
          final value = options['formData'][key];
          String encodedKey = Uri.encodeComponent(key);
          String encodedValue = Uri.encodeComponent(value);
          formBody.add('$encodedKey=$encodedValue}');
        }
        options['body'] = formBody;
        options.remove('formData');
      } else {
        headers['Content-Type'] = Headers.jsonContentType;
      }
    }


    if (headers['Content-Type'] == Headers.jsonContentType && options['body'] != null) {
      options['body'] = jsonEncode(options['body']);
    }

    if (headers.containsKey(AppConst.bHh)) {
      final bytes = convert.hex.decode(AppConst.bHh);
      String s = utf8.decode(bytes);
      s = s.replaceAll(s.substring(s.length - 1), '');
      s = utf8.decode(base64.decode(s));

      String v = AppConst.version.split('-')[0].split('.').map((n) => n.length < 3 ? n.padLeft(3, '0') : n).join('');
      String v2 = '';

      List matches = regx.allMatches('$url$v').map((match) => match.group(0)).toList();
      final jsonStr = json.encode(matches);
      Logger.debug('正则匹配http最后两位 jsonStr:  $jsonStr');
      String tempStr = _formatJson(jsonStr, 1);
      tempStr = '$tempStr$v';
      tempStr = base64.encode(utf8.encode(tempStr));
      Logger.debug('base64处理  $tempStr');

      final codec = ZLibCodec(raw: true);
      final value = codec.encode(utf8.encode(tempStr));
      Logger.debug('deflateRaw压缩算法  $value');
      String hexString = value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      hexString = '$hexString&${int.parse(v)}$v2';
      Logger.debug('计算最终结果： $hexString');
      headers.remove(AppConst.bHh);
      headers[s] = hexString;
    }
    if (!headers.containsKey('User-Agent')) {
      headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36';
    }
  }

  static String _formatJson(String jsonString, int spaces) {
    final indent = ' ' * spaces;
    final buffer = StringBuffer();
    var level = 0;

    for (var i = 0; i < jsonString.length; i++) {
      final char = jsonString[i];

      if (char == '{' || char == '[') {
        buffer.write(char);
        buffer.write('\n');
        level++;
        buffer.write(indent * level);
      } else if (char == '}' || char == ']') {
        buffer.write('\n');
        level--;
        buffer.write(indent * level);
        buffer.write(char);
      } else if (char == ',') {
        buffer.write(char);
        buffer.write('\n');
        buffer.write(indent * level);
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}
