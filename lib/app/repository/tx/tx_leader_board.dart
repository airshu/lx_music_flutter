import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/models/music_item.dart';

class TxLeaderBoard {
  static List<Board> list = [
    Board(id: 'txlxzsb', name: '流行榜', bangid: '4'),
    Board(id: 'txrgb', name: '热歌榜', bangid: '26'),
    Board(id: 'txwlhgb', name: '网络榜', bangid: '28'),
    Board(id: 'txdyb', name: '抖音榜', bangid: '60'),
    Board(id: 'txndb', name: '内地榜', bangid: '5'),
    Board(id: 'txxgb', name: '香港榜', bangid: '59'),
    Board(id: 'txtwb', name: '台湾榜', bangid: '61'),
    Board(id: 'txoumb', name: '欧美榜', bangid: '3'),
    Board(id: 'txhgb', name: '韩国榜', bangid: '16'),
    Board(id: 'txrbb', name: '日本榜', bangid: '17'),
    Board(id: 'txtybb', name: 'YouTube榜', bangid: '128'),
  ];

  static List<Board> boardList = [
    Board(id: 'tx__4', name: '流行指数榜', bangid: '4'),
    Board(id: 'tx__26', name: '热歌榜', bangid: '26'),
    Board(id: 'tx__27', name: '新歌榜', bangid: '27'),
    Board(id: 'tx__62', name: '飙升榜', bangid: '62'),
    Board(id: 'tx__58', name: '说唱榜', bangid: '58'),
    Board(id: 'tx__57', name: '喜力电音榜', bangid: '57'),
    Board(id: 'tx__28', name: '网络歌曲榜', bangid: '28'),
    Board(id: 'tx__5', name: '内地榜', bangid: '5'),
    Board(id: 'tx__3', name: '欧美榜', bangid: '3'),
    Board(id: 'tx__59', name: '香港地区榜', bangid: '59'),
    Board(id: 'tx__16', name: '韩国榜', bangid: '16'),
    Board(id: 'tx__60', name: '抖快榜', bangid: '60'),
    Board(id: 'tx__29', name: '影视金曲榜', bangid: '29'),
    Board(id: 'tx__17', name: '日本榜', bangid: '17'),
    Board(id: 'tx__52', name: '腾讯音乐人原创榜', bangid: '52'),
    Board(id: 'tx__36', name: 'K歌金曲榜', bangid: '36'),
    Board(id: 'tx__61', name: '台湾地区榜', bangid: '61'),
    Board(id: 'tx__63', name: 'DJ舞曲榜', bangid: '63'),
    Board(id: 'tx__64', name: '综艺新歌榜', bangid: '64'),
    Board(id: 'tx__65', name: '国风热歌榜', bangid: '65'),
    Board(id: 'tx__67', name: '听歌识曲榜', bangid: '67'),
    Board(id: 'tx__72', name: '动漫音乐榜', bangid: '72'),
    Board(id: 'tx__73', name: '游戏音乐榜', bangid: '73'),
    Board(id: 'tx__75', name: '有声榜', bangid: '75'),
    Board(id: 'tx__131', name: '校园音乐人排行榜', bangid: '131'),
  ];

  static Map periods = {};
  static const String periodUrl = 'https://c.y.qq.com/node/pc/wk_v15/top.html';
  static const int limit = 300;

  static Future<LeaderBoardModel?> getList(String bangid, int page) async {
    var info = periods[bangid];
    var period = info != null ? info['period'] : await getPeriods(bangid);

    var res = await listDetailRequest(bangid, period, limit);
    if (res != null && res['toplist']?['data']?['songInfoList'] == null) {
      return null;
    }
    List<LeaderBoardItem> list = filterData(res['toplist']['data']['songInfoList']);
    return LeaderBoardModel(
        list: list, total: (res['toplist']['data']['songInfoList'] as List).length, source: AppConst.sourceTX, limit: limit, page: 1);
  }

  static List<LeaderBoardItem> filterData(List rawList) {
    return rawList.map((item) {
      List types = [];
      Map _types = {};
      if (item['file']['size_128mp3'] != 0) {
        String size = AppUtil.sizeFormate(item['file']['size_128mp3']);
        types.add({'type': '128k', 'size': size});
        _types['128k'] = {'size': size};
      }
      if (item['file']['size_320mp3'] != 0) {
        String size = AppUtil.sizeFormate(item['file']['size_320mp3']);
        types.add({'type': '320k', 'size': size});
        _types['320k'] = {'size': size};
      }
      if (item['file']['size_flac'] != 0) {
        String size = AppUtil.sizeFormate(item['file']['size_flac']);
        types.add({'type': 'flac', 'size': size});
        _types['flac'] = {'size': size};
      }
      if (item['file']['size_hires'] != 0) {
        String size = AppUtil.sizeFormate(item['file']['size_hires']);
        types.add({'type': 'flac24bit', 'size': size});
        _types['flac24bit'] = {'size': size};
      }

      return LeaderBoardItem(
        singer: AppUtil.formatSingerName(singers: item['singer'], nameKey: 'name'),
        name: item['title'],
        albumName: item['album']['name'],
        albumId: item['album']['mid'],
        songmid: item['mid'],
        source: AppConst.sourceTX,
        interval: AppUtil.formatPlayTime(item['interval']),
        img: (item['album']['name'] == '' || item['album']['name'] == '空')
            ? (item['singer']?['length'] != null ? 'https://y.gtimg.cn/music/photo_new/T001R500x500M000${item.singer[0]['mid']}.jpg' : '')
            : 'https://y.gtimg.cn/music/photo_new/T002R500x500M000${item['album']['mid']}.jpg',
        qualityList: types,
        qualityMap: _types,
        urlMap: {},
      );
    }).toList();
  }

  static RegExp periodList = RegExp(
      r'<i class="play_cover__btn c_tx_link js_icon_play" data-listkey=".+?" data-listname=".+?" data-tid=".+?" data-date=".+?" .+?</i>');
  static RegExp period = RegExp(r'data-listname="([^"]+)" data-tid=".*?\/(.+?)" data-date="([^"]+)"');

  static Future listDetailRequest(String id, String period, int limit) async {
    String url = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
    var headers = {
      'User-Agent': 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
    };
    var body = {
      'toplist': {
        'module': 'musicToplist.ToplistInfoServer',
        'method': 'GetDetail',
        'param': {
          'topid': int.parse(id),
          'num': limit,
          'period': period,
        },
      },
      'comm': {
        'uin': 0,
        'format': 'json',
        'ct': 20,
        'cv': 1859,
      },
    };
    Response res = await Dio().post(url,
        options: Options(
          responseType: ResponseType.bytes,
          contentType: Headers.jsonContentType,
          headers: headers,
        ),
        data: jsonEncode(body));
    String jsonStr = const Utf8Decoder().convert(res.data);
    Map tagMap = json.decode(jsonStr);
    return tagMap;
  }

  static Future getPeriods(String bangid) async {
    var res = await HttpCore.getInstance().get(periodUrl);
    Iterable<RegExpMatch> it = periodList.allMatches(res);
    for (var item in it) {
      String info = item.group(0) ?? '';
      if (info.isNotEmpty) {
        Match? match = period.firstMatch(info);
        periods[match!.group(2)] = {
          'name': match.group(1),
          'bangid': match.group(2),
          'period': match.group(3),
        };
      }
    }

    return periods[bangid]['period'];
  }
}
