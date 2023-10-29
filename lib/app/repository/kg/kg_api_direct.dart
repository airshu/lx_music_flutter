import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KGApiDirect {
  static Future getMusicUrl(MusicItem songInfo, String type) async {
    try {
      String url =
          'https://wwwapi.kugou.com/yy/index.php?r=play/getdata&hash=${songInfo.hash}&platid=4&album_id=${songInfo.albumId}&mid=00000000000000000000000000000000';
      var res = await HttpCore.getInstance().get(url);
      Logger.debug('KGApiDirect getMusicUrl  $res');
      return res['data']['play_backup_url'];
    } catch(e, s) {
      Logger.error('KGApiDirect getMusicUrl $e $s');
    }

    return {'type': type, 'url': ''};

  }
}
