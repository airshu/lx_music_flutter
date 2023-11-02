import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_leader_board.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_leader_board.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_leader_board.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_leader_board.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class LeaderBoardController extends GetxController {
  int page = 1;
  int pageSize = 10;

  /// 当前选中的平台
  final currentPlatform = ''.obs;

  /// 当前排行榜列表
  final boardList = <Board>[].obs;

  final leaderBoardModel = LeaderBoardModel(list: [], total: 0, source: '', limit: 0).obs;

  /// 打开某个排行榜榜单
  void openBoard(Board board) async {
    LeaderBoardModel? model = await SongRepository.getLeaderBoardList(AppConst.sourceMap[currentPlatform.value]!, board.bangid, page);
    leaderBoardModel.value = model ?? LeaderBoardModel.empty();
  }

  @override
  void onInit() {
    changePlatform(AppConst.nameKW);
    super.onInit();
  }

  void changePlatform(String name) {
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

  void getMusicUrl() {

  }
}
