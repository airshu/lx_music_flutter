import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'dart:math';

import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';

class MGMusicSearch {
  static createSignature(time, str) {
    var deviceId = '963B7AA0D21511ED807EE5846EC87D20';
    var signatureMd5 = '6cdc72a439cef99a3418d2a78aa28c73';
    var sign = MD5Util.generateMD5('${str}${signatureMd5}yyapp2d16148780a1dcc7408e06336b98cfd50${deviceId}${time}');
    return {'sign': sign, 'deviceId': deviceId};
  }

  static Future musicSearch(String str, [int page = 1, int limit = 10]) async {
    var time = DateTime.now().millisecondsSinceEpoch;
    var signData = createSignature(time, str);
    String url =
        'https://jadeite.migu.cn/music_search/v3/search/searchAll?isCorrect=1&isCopyright=1&searchSwitch=%7B%22song%22%3A1%2C%22album%22%3A0%2C%22singer%22%3A0%2C%22tagSong%22%3A1%2C%22mvSong%22%3A0%2C%22bestShow%22%3A1%2C%22songlist%22%3A0%2C%22lyricSong%22%3A0%7D&pageSize=${limit}&text=${Uri.encodeComponent(str)}&pageNo=${page}&sort=0';
    var headers = {
      'uiVersion': 'A_music_3.6.1',
      'deviceId': signData['deviceId'],
      'timestamp': time,
      'sign': signData['sign'],
      'channel': '0146921',
      'User-Agent':
          'Mozilla/5.0 (Linux; U; Android 11.0.0; zh-cn; MI 11 Build/OPR1.170623.032) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    };

    var res = await HttpCore.getInstance().get(url, headers: headers);
    return res;
  }

  static Future search(String str, [int page = 1, int limit = 20]) async {
    var res = await musicSearch(str, page, limit);
    var songResultData = res['songResultData'];

    List<MusicItem> list = filterData(songResultData['resultList']);

    int total = int.parse(songResultData['totalCount']);

    int allPage = (total / limit).ceil();

    return MusicModel(list: list, allPage: allPage, total: total, source: AppConst.sourceMG);
  }

  static List<MusicItem> filterData(rawData) {
    List<MusicItem> list = [];
    Map ids = {};
    for (var item in rawData) {
      for (var data in item) {
        if (data['songId'] == null || data['songId'] == '' || data['copyrightId'] == null || data['copyrightId'] == ''|| ids.containsKey(data['copyrightId'])) {
          break;
        }
        ids[data['copyrightId']] = '';
        List qualityList = [];
        Map qualityMap = {};
        for (var type in data['audioFormats']) {
          dynamic size;
          switch (type['formatType']) {
            case 'PQ':
              size = AppUtil.sizeFormate(type['asize'] ?? type['isize']);
              qualityList.add({
                'type': '128k',
                'size': size,
              });
              qualityMap['128k'] = {
                'size': size,
              };
              break;
            case 'HQ':
              size = AppUtil.sizeFormate(type['asize'] ?? type['isize']);
              qualityList.add({
                'type': '320k',
                'size': size,
              });
              qualityMap['320k'] = {
                'size': size,
              };
              break;
            case 'SQ':
              size = AppUtil.sizeFormate(type['asize'] ?? type['isize']);
              qualityList.add({
                'type': 'flac',
                'size': size,
              });
              qualityMap['flac'] = {
                'size': size,
              };
              break;
            case 'ZQ24':
              size = AppUtil.sizeFormate(type['asize'] ?? type['isize']);
              qualityList.add({
                'type': 'flac24bit',
                'size': size,
              });
              qualityMap['flac24bit'] = {
                'size': size,
              };
              break;
          }
        }

        var img = data['img3'] ?? data['img2'] ?? data['img1'];
        if (img != null && RegExp(r"https?:").hasMatch(data['img3'])) {
          img = 'http://d.musicapp.migu.cn$img';
        }

        list.add(MusicItem(
          singer: AppUtil.formatSingerName(singers: data['singerList']),
          name: data['name'],
          albumName: data['album'],
          albumId: data['albumId'],
          songmid: data['songId'],
          source: AppConst.sourceMG,
          interval: AppUtil.formatPlayTime(data['duration']),
          img: img,
          lrc: '',
          otherSource: '',
          hash: '',
          qualityList: qualityList,
          qualityMap: qualityMap,
          urlMap: {},
          copyrightId: data['copyrightId'],
          lrcUrl: data['lrcUrl'],
          trcUrl: data['trcUrl'],
          mrcUrl: data['mrcUrl'],
        ));
        // list.add({
        //   'singer': AppUtil.formatSingerName(singers: data['singerList']),
        //   'name': data['name'],
        //   'albumName': data['album'],
        //   'albumId': data['albumId'],
        //   'songmid': data['songId'],
        //   'copyrightId': data['copyrightId'],
        //   'source': AppConst.sourceMG,
        //   'interval': AppUtil.formatPlayTime(data['duration']),
        //   'img': img,
        //   'lrc': null,
        //   'lrcUrl': data['lrcUrl'],
        //   'mrcUrl': data['mrcurl'],
        //   'trcUrl': data['trcUrl'],
        //   'types': types,
        //   '_types': _types,
        //   'typeUrl': {},
        // });
      }
    }
    return list;
  }
}
