import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/search_model.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SearchSongController extends GetxController {
  int page = 0;

  int pageSize = 10;
  final searchModel = SearchMusicModel(list: [], allPage: 0, total: 0, source: '').obs;

  final searchListModel = SearchListModel(list: [], limit: 0, total: 0, source: '').obs;

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
    if (searchType.value == searchTypeSong) {
      SearchMusicModel? model = await SongRepository.searchSongs(keyword, AppConst.sourceMap[currentPlatform.value]!, page);
      if (model != null) {
        searchModel.value = model;
      }
    } else if (searchType.value == searchTypeList) {
      SearchListModel? model = await SongRepository.searchSongList(keyword, AppConst.sourceMap[currentPlatform.value]!, page);
      if (model != null) {
        searchListModel.value = model;
      }
    }
  }

  /// 切换平台重新请求搜索结果
  void changePlatform(String name) {
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
