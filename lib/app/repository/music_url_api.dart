import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

import '../../utils/log/logger.dart';

class MusicUrlApi {
  static Future getMusicUrl(MusicItem songInfo, String source, String type) async {
    try {
      String url = 'http://787255.xyz:1372/api/Music/GetMusicUrl';
      var param = {
        'Source': source,
        'Type': type,
        'MusicInfo': songInfo.toJson(),
      };
      var res = await HttpCore.getInstance().postByOptionsJson(url, data: param);
      Logger.debug('KGApiDirect getMusicUrl  $res');
      return (res['Data'] != null && res['Data'].isNotEmpty) ? {'url': res['Data']} : {};
    } catch (e, s) {
      Logger.error('KGApiDirect getMusicUrl $e $s');
    }

    return {'type': type, 'url': ''};
  }

  static Future getMusicUrl2(MusicItem songInfo, String source, String type) async {
    try {
      String url = 'http://787255.xyz:1372/api/Music/GetMusicUrl';
      var headers = {
        'Content-Type': 'application/json',
      };
      var param = {
        'Source': 'kw',
        'Type': '320k',
        'MusicInfo': {
          "name": "童话镇",
          "singer": "小野来了",
          "source": "kw",
          "songmid": "389924421",
          "img": "http://img2.kuwo.cn/star/albumcover/300/s3s96/45/2187383848.jpg",
          "albumId": "55040417",
          "interval": "04:20",
          "albumName": "童话镇",
          "hash": null,
          "strMediaMid": null,
          "albumMid": null,
          "copyrightId": null,
          "types": [
            {"type": "128k", "size": "3.97MB", "hash": null},
            {"type": "320k", "size": "9.94MB", "hash": null},
            {"type": "flac", "size": "47.61MB", "hash": null}
          ]
        },
      };
      var res = await HttpCore.getInstance().postByOptionsJson(url, data: param);
      Logger.debug('KGApiDirect getMusicUrl  $res');
      return (res['data'] != null && res['data'].isNotEmpty) ? res['data']['play_backup_url'] : {};
    } catch (e, s) {
      Logger.error('KGApiDirect getMusicUrl $e $s');
    }

    return {'type': type, 'url': ''};
  }


}
