import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/services/app_service.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              child: const Text(
                'Do LOGIN !!',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
              onPressed: () {
                // final thenTo = context.params['then'];
                // Get.offNamed(thenTo ?? Routes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}
