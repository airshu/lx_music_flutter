import 'package:fluttertoast/fluttertoast.dart';

/// toast工具类
class ToastUtil {
  /// 显示toast
  /// [msg] 显示内容
  static Future<void> show(String msg) async {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  /// 取消所有toast
  static void cancel() {
    Fluttertoast.cancel();
  }
}
