import 'package:get/get.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';

class HomeController extends GetxController {


  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(microseconds: 100), () {
      MusicPlayerService.instance.show();
    });

  }
}