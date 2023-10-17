import 'package:get/get.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SearchSongController extends GetxController {
  int page = 0;

  int pageSize = 10;
  List songList = [].obs;

  String keyword = '';

  Future<void> search() async {
    try {
      List<MusicItem> list = await SongRepository.searchKuGou(keyword, pageSize, page);
      Logger.debug('==search=== $list');
      songList.addAll(list);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }
}
