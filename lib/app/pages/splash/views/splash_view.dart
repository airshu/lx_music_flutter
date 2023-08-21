import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../pages/home/views/home_views.dart';
import '../controllers/splash_service.dart';

/// 引导页
class SplashView extends GetView<SplashService> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 20),
            ),
            const CircularProgressIndicator(),
            ElevatedButton(
                onPressed: () {
                  // Get.find<SplashService>().init();
                  Get.offAll(
                    () => HomeViews(),
                  );
                },
                child: const Text('Go')),
          ],
        ),
      ),
    );
  }
}
