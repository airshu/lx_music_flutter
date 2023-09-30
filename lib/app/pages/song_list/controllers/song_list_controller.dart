import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/respository/kg/kg_song_list.dart';
import 'package:lx_music_flutter/app/respository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/app/respository/mg/mg_song_list.dart';
import 'package:lx_music_flutter/app/respository/tx/tx_song_list.dart';
import 'package:lx_music_flutter/app/respository/wy/wy_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SongListController extends GetxController {
  int page = 1;

  int pageSize = 10;


  final songList = [].obs;

  String keyword = '爱';

  /// 当前选中的平台
  final currentPlatform = ''.obs;

  final tagList = [].obs;
  final sortList = <SortItem>[].obs;

  @override
  void onInit() {
    changePlatform(AppConst.nameKW);
    sortList.value = KWSongList.sortList;
    super.onInit();

    // Future.delayed(const Duration(microseconds: 100), () {
    //   KWSongList.getSearch(keyword, page, pageSize);
    // });
  }

  Future<void> search() async {
    try {
      List list = await KWSongList.getSearch(keyword, page, pageSize);
      songList.addAll(list);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  void openBoard(Board board) async {
    var result = await KWLeaderBoard.getList(board.bangid, page);
    Logger.debug('$result');
    songList.value = result['list'];
  }

  Future<void> changePlatform(String name) async {
    songList.value = [];
    currentPlatform.value = name;
    sortList.value = AppConst.sortListMap[name]!;

    switch (name) {
      case AppConst.nameKW:
        var res = await KWSongList.getTags();
        for(var item in res) {
          print('item   $item');
        }
        tagList.value = res;
        break;
    }
  }

  void openTag(item) {

  }
}
