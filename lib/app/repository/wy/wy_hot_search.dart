import 'package:lx_music_flutter/app/repository/wy/wy_song_repository.dart';

class WYHotSearch {
  static Future getList() async {
    String url = '/api/search/chart/detail';
    var res = await WYSongRepository.eapiRequest(url, {
      'id': 'HOT_SEARCH_SONG#@#',
    });
    return {'source': 'wy', 'list': filterList(res['data']['itemList'])};
  }

  static filterList(rawList) {
    return rawList.map((item) => item.searchWord).toList();
  }
}
