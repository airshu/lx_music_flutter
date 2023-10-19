import 'package:lx_music_flutter/utils/log/logger.dart';

class MGApiTemp {
  static Future getMusicUrl(dynamic songinfo, String type) async {

    try {

    } catch(e, s) {
      Logger.error('$e $s');
    }
    return {'type': type, 'url': ''};
  }
}