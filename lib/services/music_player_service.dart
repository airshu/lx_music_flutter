import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/player/views/music_player_component.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/app/sql/music_sql_manager.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/download_manager/download_manager.dart';
import 'package:lx_music_flutter/utils/overlay_dragger.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

/// 音乐播放服务管理
class MusicPlayerService extends GetxService {
  static MusicPlayerService get instance => Get.find();

  MusicPlayerComponent musicPlayerComponent = const MusicPlayerComponent();

  /// 喜爱的播放列表
  List loveMusicList = [];

  /// 临时播放列表
  List tempMusicList = [];

  @override
  void onInit() {
    super.onInit();

    //todo 读取数据库获取播放列表数据
  }

  /// 播放音乐
  Future<void> play(String source, MusicItem songinfo) async {
    List types = songinfo.qualityList;
    for (var item in types) {
      String type = item['type'];

      for (var httpSource in MusicSource.httpSourceList) {
        Map urlInfo = await SongRepository.getMusicUrl(source, httpSource, songinfo, type);
        if (urlInfo['url'] != null && urlInfo['url'] != '') {
          songinfo.urlMap[type] = urlInfo['url'];
          MusicPlayer().addSongInfo(urlInfo['url'], songinfo);
          return;
        }
      }
    }
    ToastUtil.show('无法获取歌曲地址');
  }

  /// 播放音乐列表
  void playList(dynamic list) {}

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
    // String? url = await item.getUrl();
    // if(url == null) {
    //   ToastUtil.show('无法获取下载地址');
    //   return;
    // }
    // String path = '';
    // String fileName = '${item.hash}.mp3';
    // DownloadManager.instance.download(url, path, fileName).then((value) {
    //   ToastUtil.show('下载完成： $value');
    // });
    // MusicSQLManager().insert(item);
  }
}
