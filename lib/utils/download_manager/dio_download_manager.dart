import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'download_manager.dart';

/// 文件下载器的Dio实现
class DioDownloadManager extends DownloadManager {
  Map<String, CancelToken> callbacks = {};

  @override
  Future<int> download(
    String url,
    String path,
    String fileName, {
    Function(Object id)? onReady,
    Function(double percent)? onProgress,
    Function()? onFail,
    Function()? onSuccess,
  }) async {
    Dio dio = Dio();
    try {
      CancelToken cancelToken = CancelToken();
      callbacks['${cancelToken.hashCode}'] = cancelToken;
      onReady?.call(cancelToken.hashCode);
      await dio.download(
        url,
        path,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          debugPrint('dio  onReceiveProgress >>>count=$count  total=$total    ${count / total}');
          if (count >= total) {
            onSuccess?.call();
          } else {
            onProgress?.call(count / total);
          }
        },
      );

      String originName = url.split('.')[-1];
      await File('$path/$originName').rename(fileName);

      return DownloadManager.completed;
    } catch (e, s) {
      debugPrint('DioDownloadManager download err  $e   $s');
      onFail?.call();
    }

    return DownloadManager.failed;
  }

  @override
  Future<void> cancelTaskById(Object id) async {
    callbacks[id.toString()]?.cancel();
    callbacks.remove(id.toString());
  }
}
