import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_repository.dart';
import 'package:lx_music_flutter/models/search_model.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class WYSongList {
  static List<SortItem> sortList = [
    SortItem(name: '最热', tid: 'hot', id: 'hot', isSelect: true),
  ];

  static Future getTag() async {
    String url = 'https://music.163.com/weapi/playlist/catalogue';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }

  static Future getHotTag() async {
    String url = 'https://music.163.com/weapi/playlist/hottags';

    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    Logger.debug('$result');
  }

  static Future getTags() async {
    var res = await Future.wait([getTag(), getHotTag()]);
    return {
      'tags': res[0],
      'hotTags': res[1],
      'source': 'wy',
    };
  }

  static getList() {}

  static Future getListDetail(String id, int page) async {}

  static Future<SearchListModel?> search(String text, [int page = 1, int limit = 10]) async {
    String url = '/api/cloudsearch/pc';
    var data = {
      's': text,
      'type': 1000, // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
      'limit': limit,
      'total': page == 1,
      'offset': limit * (page - 1),
    };
    var res = await WYSongRepository.eapiRequest(url, data);
    if (res['code'] == 200) {
      List<SearchListItem> list = filterList(res['result']['playlists']);
      return SearchListModel(list: list, limit: limit, total: res['result']['playlistCount'], source: AppConst.sourceWY);
    }
  }

  static List<SearchListItem> filterList(rawData) {
    List<SearchListItem> list = [];
    for (var item in rawData) {
      list.add(SearchListItem(
        name: item['name'],
        source: AppConst.sourceWY,
        img: item['coverImgUrl'],
        playCount: AppUtil.formatPlayCount(item['playCount']),
        id: item['id'].toString(),
        author: item['creator']['nickname'],
        total: item['trackCount'],
        desc: item['description'],
        time: item['createTime'] != null ? AppUtil.dateFormat(item['createTime']) : '',
      ));
    }
    return list;
  }
}
