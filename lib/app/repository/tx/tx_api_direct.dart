import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class TXApiDirect {
  static Map fileConfig = {
    '128k': {
      's': 'M500',
      'e': '.mp3',
      'bitrate': '128kbps',
    },
    '320k': {
      's': 'M800',
      'e': '.mp3',
      'bitrate': '320kbps',
    },
    'flac': {
      's': 'F000',
      'e': '.flac',
      'bitrate': 'FLAC',
    },
  };

  static Future getMusicUrl(MusicItem songInfo, String type) async {
    try {
      String url = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
      const guid = '10000';
      List songmidList = [songInfo.songmid];
      const uin = '0';
      Map? fileInfo = fileConfig[type];

      var file;
      if(fileInfo != null) {
        file = '${fileInfo['s']}${songInfo.songmid}${songInfo.songmid}${fileInfo['e']}';
      }
      var reqData = {
        'req_0': {
          'module': 'vkey.GetVkeyServer',
          'method': 'CgiGetVkey',
          'param': {
            'filename': file != null ? [file] : [],
            'guid': guid,
            'songmid': songmidList,
            'songtype': [0],
            'uin': uin,
            'loginflag': 1,
            'platform': '20',
          },
        },
        'loginUin': uin,
        'comm': {
          'uin': uin,
          'format': 'json',
          'ct': 24,
          'cv': 0,
        },
      };

      url = '${url}?format=json&data=${jsonEncode(reqData)}';
      // var res = await HttpCore.getInstance().get(url);

      Response res1 = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
          ),);
      String jsonStr = const Utf8Decoder().convert(res1.data);
      var res = json.decode(jsonStr);
      Logger.debug('TXApiDirect getMusicUrl  $res');
      var purl = res['req_0']['data']['midurlinfo'][0]['purl'];
      if(purl != null || purl == '') {
        return {'type': type, 'url': ''}; // vip
      }
      var rurl = res['req_0']['data']['sip'][0] + purl;
      return {'type': type, 'url': rurl};
    } catch (e, s) {
      Logger.error('$e $s');
    }

    return {'type': type, 'url': ''};
  }
}
