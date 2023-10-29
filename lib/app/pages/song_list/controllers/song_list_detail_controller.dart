import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_song_list.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_song_list.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_song_list.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

class SongListDetailController extends GetxController {
  int page = 1;

  int pageSize = 10;

  final detailInfo = MusicModel.empty().obs;

  Future getListDetail(MusicListItem musicListItem) async {
    String id = musicListItem.id ?? '';
    if (id.isEmpty) {
      ToastUtil.show('id is null');
      return;
    }
    MusicModel? model = await SongRepository.getListDetail(musicListItem.source!, id, page);

    detailInfo.value = model ?? MusicModel.empty();
    // switch (musicListItem.source) {
    //   case AppConst.sourceWY:
    //     res = await WYSongList.getListDetail(id, page);//todo
    //     break;
    //   case AppConst.sourceMG:
    //     res = await MGSongList.getListDetail(id, page);
    //     break;
    //   case AppConst.sourceKW:
    //     res = await KWSongList.getListDetail(id, page);
    //     break;
    //   case AppConst.sourceKG:
    //     res = await KGSongList.getListDetail(id, page);
    //     break;
    //   case AppConst.sourceTX:
    //     res = await TXSongList.getListDetail(id, page);
    //     break;
    // }

    // Logger.debug('getListDetail---------$res');
    // detailInfo.value = res;
  }
}
