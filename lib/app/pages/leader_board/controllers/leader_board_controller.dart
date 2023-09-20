import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class LeaderBoardController extends GetxController {
  int page = 1;
  int pageSize = 10;

  /// 歌曲列表
  final songList = [].obs;

  /// 当前选中的平台
  final currentPlatform = ''.obs;

  /// 当前排行榜列表
  final boardList = <Board>[].obs;

  /// 打开某个排行榜榜单
  void openBoard(Board board) async {
    var result = await KWLeaderBoard.getList(board.bangid, page);
    Logger.debug('$result');
    songList.value = result['list'];
  }

  @override
  void onInit() {
    changePlatform(AppConst.nameKW);
    super.onInit();
  }

  void changePlatform(String name) {
    songList.value = [];
    currentPlatform.value = name;
    switch (name) {
      case AppConst.nameKW:
        boardList.value = KWLeaderBoard.boardList;
        break;
      case AppConst.nameKG:
        boardList.value = [];
        break;
      case AppConst.nameWY:
        boardList.value = [];
        break;
      case AppConst.nameMG:
        boardList.value = [];
        break;
      case AppConst.nameQQ:
        boardList.value = [];
        break;
    }
    if (boardList.isNotEmpty) {
      openBoard(boardList.value.elementAt(0));
    }
  }
}
