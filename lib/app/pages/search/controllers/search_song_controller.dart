import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SearchSongController extends GetxController {
  int page = 0;

  int pageSize = 10;
  final songList = [].obs;

  /// 当前选中的平台
  final currentPlatform = ''.obs;

  String keyword = '';

  /// 搜索类型
  final searchType = ''.obs;
  static const String searchTypeSong = 'song';
  static const String searchTypeList = 'list';

  @override
  void onInit() {
    currentPlatform.value = AppConst.nameKG;
    searchType.value = searchTypeSong;
    super.onInit();
  }

  /// 搜索歌曲
  Future<void> search() async {
    try {
      var res = await SongRepository.tipSearch(keyword, AppConst.sourceMap[currentPlatform.value]!);
      Logger.debug('==search=== $res');
      songList.value.clear();
      songList.value.addAll(res);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  /// 切换平台重新请求搜索结果
  void changePlatform(String name) {
    songList.value = [];
    currentPlatform.value = name;
    switch (name) {
      case AppConst.nameKW:
        break;
      case AppConst.nameKG:
        break;
      case AppConst.nameWY:
        break;
      case AppConst.nameMG:
        break;
      case AppConst.nameTX:
        break;
    }
  }
}
