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

  //
  // Future<ResponseEntity<T>> getResponseEntity<T>() async {
  //
  // }
  //
  /// get method
  ///
  /// [cancelToken] 可取消该请求，cancelToken.cancel();
  Future<dynamic> get(String url,
      {Map<String, dynamic>? params, Map<String, dynamic>? headers, Options? options, CancelToken? cancelToken}) async {
    return _request(url, method: GET, params: params, options: options, cancelToken: cancelToken, headers: headers);
  }

  Future<T> getEntity<T>(
    String url,
    EntityFactory<T> factory, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var responseEntity = await getResponseEntity<T>(url, factory, params: params, options: options, cancelToken: cancelToken);
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
  }) async {
    var res = await get(url, params: params, options: options, cancelToken: cancelToken);
    // Logger.debug('\n\n\n==========>>>>>>>>>>>>>>>>$url>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    // Logger.debug(res);
    // Logger.debug('==========>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n\n');
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  /// post method
  Future<dynamic> post(String url,
      {dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback,
      Map<String, dynamic>? headers}) async {
    return _request(url,
        method: POST,
        params: params,
        headers: headers,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
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
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    options ??= Options();
    options.contentType = Headers.jsonContentType;
    return _request(url,
        method: POST,
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
  }) async {
    var responseEntity =
        await postResponseEntity<T>(url, factory, data: data, params: params, options: options, cancelToken: cancelToken);
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
  }) async {
    var res = await post(url, data: data, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  /// patch method
  Future<dynamic> patch(String url, {Map<String, dynamic>? params, Options? options, CancelToken? cancelToken}) async {
    return _request(url, method: PATCH, params: params, options: options, cancelToken: cancelToken);
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? params, Options? options, CancelToken? cancelToken}) async {
    return _request(url, method: PUT, params: params, options: options, cancelToken: cancelToken);
  }

  Future<dynamic> putByOptionsJson(String url,
      {dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    options ??= Options();
    options.contentType = Headers.jsonContentType;
    return _request(url,
        method: PUT,
        params: params,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
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
  Future<dynamic> _request(String url,
      {String? method,
      dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      Map<String, dynamic>? headers,
      ProgressCallback? onSendProgressCallback}) async {
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
    Logger.debug('调用接口:  ----data=$data-------params=$params------------------------> $url '
        '---->response=：\n$response');

    statusCode = response?.statusCode ?? -1;
    if (statusCode < 0) {
      errorMsg = 'Network request error, code: $statusCode';
      throw HttpResponseNot200Exception(errorMsg);
    }
    if (response?.data is Map<String, dynamic>) {
      Map<String, dynamic>? data = response?.data;
      int code = HttpCode.SUCCESS;
      code = data?["code"] ?? HttpCode.SUCCESS;
      // 4000：token过期 4001：未认证、或者token非法  4002：refresh_token过期
      if (code == HttpCode.TOKEN_4000 || code == HttpCode.TOKEN_4001) {
        // 这里token失效的操作放在拦截器中处理
      } else if (code != HttpCode.SUCCESS) {
        // account.InvalidToken 用户token失效
        // UserUtil.cleanAccessToken();
        // accessToken = null;
        // refreshToken = null;
        // // 跳转到登陆页面
        // xp_get.Get.offAllNamed(PadAppPages.INITIAL);
        // 在刷新token时才跳转至登陆页面
      }
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

  /// 刷新token后，重新发请求
  Future<dynamic> _retryRequest(String url,
      {String? method,
      dynamic data,
      Map<String, dynamic>? params,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgressCallback}) async {
    String errorMsg = '';
    int statusCode = -1;
    Response? response = await _getResponse(url,
        method: method,
        data: data,
        params: params,
        options: options,
        cancelToken: cancelToken,
        onSendProgressCallback: onSendProgressCallback);
    Logger.debug('!!!!!!刷新token!!!!!! 重新发请求 _retryRequest 调用接口: $url');
    statusCode = response?.statusCode ?? -1;
    if (statusCode < 0) {
      errorMsg = 'Network request error, code: $statusCode';
      throw HttpResponseNot200Exception(errorMsg);
    }
    return response;
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
    // assert(() {
    // Logger.debug("token: 'Bearer $accessToken'");
    //   return true;
    // }());
    // options.headers?['Client-Type'] = options.headers?['Client-Type'] ?? 'PC'; // 设置客户端类型
    //
    packageInfo ??= await PackageInfo.fromPlatform();
    var version = packageInfo?.version ?? '';
    var buildNumber = packageInfo?.buildNumber ?? '';
    //
    // options.headers?['versionCode'] = '$version+$buildNumber';
    // options.headers?['time'] = DateTime.now().millisecondsSinceEpoch;
    //
    // if (Platform.isAndroid && androidInfo != null) {
    //   androidInfo ??= await DeviceInfoPlugin().androidInfo;
    //   options.headers?['model'] = androidInfo?.model ?? '';
    //   options.headers?['androidId'] = androidInfo?.androidId ?? '';
    // }
    //
    // if (Platform.isIOS) {
    //   iosInfo ??= await DeviceInfoPlugin().iosInfo;
    //   options.headers?['model'] = iosInfo?.model ?? ''; //设备类型
    //   options.headers?['iosId'] = iosInfo?.identifierForVendor ?? ''; //设备id
    // }

    // Logger.debug('option headers....   ${options.headers}');
    Logger.debug('>>>>>开始调用接口:'
        '$url-----headers=${options.headers}--params=$params--------data=$data--------------------->');
    switch (method) {
      case GET:
        if (params != null && params.isNotEmpty) {
          StringBuffer sb = StringBuffer('?');
          params.forEach((key, value) {
            if (value != null) {
              sb.write('$key=$value&');
            }
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0, paramStr.length - 1);
          url += paramStr;
        }
        response = await tokenDio.get(url, options: options, cancelToken: cancelToken);
        break;
      case POST:
        if (params != null && params.isNotEmpty) {
          response =
              await tokenDio.post(url, data: params, options: options, cancelToken: cancelToken, onSendProgress: onSendProgressCallback);
        } else if (data != null) {
          response =
              await tokenDio.post(url, data: data, options: options, cancelToken: cancelToken, onSendProgress: onSendProgressCallback);
        } else {
          response = await tokenDio.post(url, options: options, cancelToken: cancelToken, onSendProgress: onSendProgressCallback);
        }
        break;
      case PATCH:
        if (params != null && params.isNotEmpty) {
          response = await tokenDio.patch(url, data: params, options: options, cancelToken: cancelToken);
        }
        break;
      case PUT:
        response = await tokenDio.put(url, data: params, options: options, cancelToken: cancelToken);
        break;
      case DELETE:
        response = await tokenDio.delete(url, data: params, options: options, cancelToken: cancelToken);
        break;
      default:
        throw 'error';
    }
    return response;
  }
}
