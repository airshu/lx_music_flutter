import 'dart:async';

import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/home/views/home_views.dart';

class SplashService extends GetxService {

  final memo = AsyncMemoizer<void>();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() {
    return memo.runOnce(_initFunction);
  }

  Future<void> _initFunction() async {
    await Future.delayed(const Duration(seconds: 1));
    Get.offAll(() => HomeViews(),);
  }
}
