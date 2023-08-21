import 'dio_download_manager.dart';

///下载管理器
abstract class DownloadManager {
  static DownloadManager _instance = DioDownloadManager();

  static DownloadManager get instance => _instance;

  static set instance(DownloadManager instance) {
    print('set DownloadManager instance: $instance' );
    _instance = instance;
  }

  static const int idle = 0;
  static const int pending = 1;
  static const int running = 2;
  static const int completed = 3;
  static const int failed = 4;
  static const int canceled = 5;

  Future<void> init() async {}

  /// 下载文件
  ///
  /// [url] 文件url
  /// [path] 存储本地文件路径
  /// [onReady] 准备开始下载 返回任务id
  /// [onProgress] 下载进度回调
  /// [onFail] 下载失败回调
  /// [onSuccess] 下载成功
  Future<int> download(
    String url,
    String path,
    String fileName, {
    Function(Object id)? onReady,
    Function(double percent)? onProgress,
    Function()? onFail,
    Function()? onSuccess,
  }) async {
    return -1;
  }

  /// 取消某个id任务
  Future<void> cancelTaskById(Object id) async {}

  /// 删除所有任务
  Future<void> removeAllTask() async {}
}
