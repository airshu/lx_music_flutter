import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';



class KWController extends GetxController {


  int page = 1;

  int pageSize = 10;
  final songList = [].obs;

  String keyword = '爱';

  /// 当前选中的平台
  final currentPlatform = ''.obs;


  final sortList = [].obs;


  @override
  void onInit() {
    changePlatform(AppConst.nameKW);
    super.onInit();


    // Future.delayed(const Duration(microseconds: 100), () {
    //   KWSongList.getSearch(keyword, page, pageSize);
    // });
  }




  Future<void> search() async {
    try {
      // List list = await KWSongList.getSearch(keyword, page, pageSize);
      // songList.addAll(list);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  void openBoard(Board board) async {
    // var result = await KWLeaderBoard.getList(board.bangid, page);
    // Logger.debug('$result');
    // songList.value = result['list'];
  }

  void changePlatform(String name) {
    songList.value = [];
    currentPlatform.value = name;

  }
}