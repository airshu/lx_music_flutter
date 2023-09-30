import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/kg/kg_leader_board.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/pages/mg/mg_leader_board.dart';
import 'package:lx_music_flutter/app/pages/tx/tx_leader_board.dart';
import 'package:lx_music_flutter/app/pages/wy/wy_leader_board.dart';
import 'package:lx_music_flutter/models/music_item.dart';
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
    switch (currentPlatform.value) {
      case AppConst.nameKW:
        var result = await KWLeaderBoard.getList(board.bangid, page);
        Logger.debug('$result');
        songList.value = result['list'];
        break;
      case AppConst.nameKG:
        var result = await KGLeaderBoard.getList(board.bangid, page);
        Logger.debug('$result');
        songList.value = result['list'];
        break;
      case AppConst.nameWY:
        var result = await WYLeaderBoard.getList(board.bangid, page);
        songList.value = result['list'];
        break;
      case AppConst.nameMG:
        var result = await MGLeaderBoard.getList(board.bangid, page);
        songList.value = result['list'];
        break;
      case AppConst.nameTX:
        var result = await TxLeaderBoard.getList(board.bangid, page);
        songList.value = result['list'];
        break;
    }
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
        boardList.value = KGLeaderBoard.boardList;
        break;
      case AppConst.nameWY:
        boardList.value = WYLeaderBoard.boardList;
        break;
      case AppConst.nameMG:
        boardList.value = MGLeaderBoard.boardList;
        break;
      case AppConst.nameTX:
        boardList.value = TxLeaderBoard.boardList;
        break;
    }
    if (boardList.isNotEmpty) {
      openBoard(boardList.value.elementAt(0));
    }
  }
}
