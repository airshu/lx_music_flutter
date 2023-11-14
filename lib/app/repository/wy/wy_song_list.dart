import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_repository.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class WYSongList {
  static List<SortItem> sortList = [
    SortItem(name: '最热', tid: 'hot', id: 'hot', isSelect: true),
  ];

  static const int limit_list = 30;

  static Future getTag() async {
    String url = 'https://music.163.com/weapi/playlist/catalogue';

    var param = await CryptoUtils.weapi({});
    var options = Options(extra: {'form': param});
    var result = await HttpCore.getInstance().post(url, options: options);
    Logger.debug('$result');
    if(result != null && result['code'] == 200) {
      Map subList = {};
      Map categories = result['categories'];
      for(var item in result['sub']) {
        String key = item['category'].toString();
        if(!subList.containsKey(key)) {
          subList[key] = [];
        }
        (subList[key] as List).add({
          'parent_id': categories[key],
          'parent_name': categories[key],
          'id': item['name'],
          'name': item['name'],
          'source': AppConst.sourceWY,
        });
      }

      List list = [];
      for(var key in categories.keys) {
        list.add({
          'name': categories[key],
          'list': subList[key],
          'source': AppConst.sourceWY,
        });
      }
      return list;
    }
  }

  static Future getHotTag() async {
    String url = 'https://music.163.com/weapi/playlist/hottags';
    var param = await CryptoUtils.weapi({});
    var options = Options(extra: {'form': param});
    var result = await HttpCore.getInstance().post(url, options: options);
    Logger.debug('$result');
    if(result != null && result['code'] == 200) {
      List list = [];
      for(var item in result['tags']) {
        list.add({
          'id': item['playlistTag']['name'],
          'name': item['playlistTag']['name'],
          'source': AppConst.sourceWY,
        });
      }
      return list;
    }


  }

  static Future getTags() async {
    var res = await Future.wait([getTag(), getHotTag()]);
    return {
      'tags': res[0],
      'hotTags': res[1],
      'source': 'wy',
    };
  }

  /// 歌单获取音乐列表
  static Future<MusicListModel?> getList([String? sortId, String? tagId, int page = 0]) async {
    String url = 'https://music.163.com/weapi/playlist/list';
    var param = await CryptoUtils.weapi({
      'cat': tagId ?? '全部',
      // 全部,华语,欧美,日语,韩语,粤语,小语种,流行,摇滚,民谣,电子,舞曲,说唱,轻音乐,爵士,乡村,R&B/Soul,古典,民族,英伦,金属,朋克,蓝调,雷鬼,世界音乐,拉丁,另类/独立,New Age,古风,后摇,Bossa Nova,清晨,夜晚,学习,工作,午休,下午茶,地铁,驾车,运动,旅行,散步,酒吧,怀旧,清新,浪漫,性感,伤感,治愈,放松,孤独,感动,兴奋,快乐,安静,思念,影视原声,ACG,儿童,校园,游戏,70后,80后,90后,网络歌曲,KTV,经典,翻唱,吉他,钢琴,器乐,榜单,00后
      'order': sortId,
      // hot,new
      'limit': limit_list,
      'offset': limit_list * (page - 1),
      'total': true,
    });
    var res = await HttpCore.getInstance().post(url, options: Options(extra: {'form': param}));
    if (res != null && res['code'] == 200) {
      return MusicListModel(
        list: filterList(res['playlists']),
        limit: limit_list,
        total: res['total'],
        source: AppConst.sourceWY,
      );
    }
  }

  static Future<MusicModel?> getListDetail(String id, int page) async {}

  static Future<MusicListModel?> search(String text, [int page = 1, int limit = 10]) async {
    String url = '/api/cloudsearch/pc';
    var data = {
      's': text,
      'type': 1000, // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
      'limit': limit,
      'total': page == 1,
      'offset': limit * (page - 1),
    };
    var res = await WYSongRepository.eapiRequest(url, data);
    if (res != null && res['code'] == 200) {
      List<MusicListItem> list = filterList(res['result']['playlists']);
      return MusicListModel(list: list, limit: limit, total: res['result']['playlistCount'], source: AppConst.sourceWY);
    }
  }

  static List<MusicListItem> filterList(rawData) {
    List<MusicListItem> list = [];
    for (var item in rawData) {
      list.add(MusicListItem(
        name: item['name'],
        source: AppConst.sourceWY,
        img: item['coverImgUrl'],
        playCount: AppUtil.formatPlayCount(item['playCount']),
        id: item['id'].toString(),
        author: item['creator']['nickname'],
        total: item['trackCount'].toString(),
        desc: item['description'],
        time: item['createTime'] != null ? AppUtil.dateFormat(item['createTime']) : '',
      ));
    }
    return list;
  }
}
