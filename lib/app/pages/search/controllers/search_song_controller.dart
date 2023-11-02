import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SearchSongController extends GetxController {
  int page = 0;

  int pageSize = 10;
  final searchMusicModel = MusicModel(list: [], allPage: 0, total: 0, source: '').obs;

  final searchListModel = MusicListModel(list: [], limit: 0, total: 0, source: '').obs;

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
      MusicModel? model = await SongRepository.searchSongs(keyword, AppConst.sourceMap[currentPlatform.value]!, page);
      if (model != null) {
        searchMusicModel.value.allPage = model.allPage;
        searchMusicModel.value.total = model.total;
        searchMusicModel.value.source = model.source;
        searchMusicModel.value.list.addAll(model.list);
        searchMusicModel.refresh();
      }
    } else if (searchType.value == searchTypeList) {
      MusicListModel? model = await SongRepository.searchSongList(keyword, AppConst.sourceMap[currentPlatform.value]!, page);
      if (model != null) {
        searchListModel.value.total = model.total;
        searchListModel.value.source = model.source;
        searchListModel.value.list.addAll(model.list);
        searchListModel.refresh();
      }
    }
  }

  /// 切换平台重新请求搜索结果
  void changePlatform(String name) {
    currentPlatform.value = name;
    searchListModel.value.reset();
    searchMusicModel.value.reset();
    search();
  }
}
