import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // return [
      Get.lazyPut(() => LoginController());
    // ];
  }
}
