import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class KGApiTest {
  static Future getMusicUrl(MusicItem songinfo, String type) async {
    try {
      // Logger.debug('KGApiTest getMusicUrl  $res');
    } catch (e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }
}
