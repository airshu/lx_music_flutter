import 'package:get/get.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KWListController extends GetxController {
  int page = 1;

  int pageSize = 10;
  List songList = [].obs;

  @override
  void onInit() {
    super.onInit();

    KWSongList.getToken();
    // Future.delayed(const Duration(microseconds: 100), () {
    //   KWSongList.getSearch(keyword, page, pageSize);
    // });
  }

  Future<void> search(String playlistid) async {
    return;
    // try {
    //   var result = await KWSongList.getListDetail(playlistid, page);
    //
    //   for (var element in result['list']) {
    //     final songmid = element['songmid'];
    //     for (var item in element['types']) {
    //       final song = await KWSongList.getMusicUrl(songmid, item['type']);
    //
    //       var pic = await KWSongList.getPic(songmid);
    //       Logger.debug('===$pic');
    //       // print('============>>>>>$song');
    //       // if(song != null) {
    //       //   songList.add(song);
    //       // }
    //     }
    //   }
    // } catch (e, s) {
    //   Logger.error('$e $s');
    // }
  }
}
