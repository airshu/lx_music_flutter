import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/player/views/music_player_component.dart';
import 'package:lx_music_flutter/app/sql/music_sql_manager.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/download_manager/download_manager.dart';
import 'package:lx_music_flutter/utils/overlay_dragger.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

class MusicPlayerService extends GetxService {
  static MusicPlayerService get instance => Get.find();

  MusicPlayerComponent musicPlayerComponent = const MusicPlayerComponent();

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> play(MusicItem item) async {

  }

  /// 显示播放小组件
  void show() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DragOverlay.show(context: Get.overlayContext!, view: musicPlayerComponent);
    });
  }

  /// 隐藏播放小组件
  void hide() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DragOverlay.remove();
    });
  }

  void download(MusicItem item) async {
    String? url = await item.getUrl();
    if(url == null) {
      ToastUtil.show('无法获取下载地址');
      return;
    }
    String path = '';
    String fileName = '${item.hash}.mp3';
    DownloadManager.instance.download(url, path, fileName).then((value) {
      ToastUtil.show('下载完成： $value');
    });
    MusicSQLManager().insert(item);
  }
}
