import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogUtil {

  /// 设置弹窗具体位置
  static void showDialog({required Widget child, double x = 0.0, double y = 0.0}) {
    Get.dialog(
      Stack(
        children: [
          Positioned(
            left: x,
            top: y,
            child: child,
          ),
        ],
      ),
      barrierDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
    );
  }
}
