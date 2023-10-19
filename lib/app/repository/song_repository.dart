import 'dart:convert';

import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_temp.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_test.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_api_direct.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_api_direct.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_api_direct.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/services/app_service.dart';
import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

class SongRepository {
  static Map eapi(String url, object) {
    String text = (object is String) ? json.encode(object) : object;
    String message = 'nobody${url}use${text}md5forencrypt';
    String digest = MD5Util.generateMD5(message);
    String data = '${url}-36cd479b6b5-${text}-36cd479b6b5-${digest}';

    return {
      'params': EncryptUtil.aesDecrypt(EncryptUtil.encodeBase64(data), AppService.to.eapiKey, AppService.to.iv),
      'encSecKey': EncryptUtil.encryptByPublicKeyText(AppService.to.publicKey, digest),
    };
  }

  static Future eapiRequest(data) async {
    String url = 'http://interface.music.163.com/eapi/batch';
    var result = await HttpCore.getInstance().post(url, headers: {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36',
      'origin': 'https://music.163.com',
    },data: eapi(url, data));
    return result;
  }

  static Future<List<MusicItem>> searchKuGou(String keyword, int pageSize, int page) async {
    String url = '${Urls.kugouSearch}keyword=$keyword&cmd=300&pagesize=$pageSize&page=$page';

    try {
      var result = await HttpCore.getInstance().get(url);

      List<MusicItem> list = [];
      result['data'].forEach((element) {
        MusicItem item = MusicItem(
          id: element['id'] as String? ?? '',
          songName: element['filename'] as String? ?? '',
          artist: element['artist'] as String? ?? '',
          album: element['album'] as String? ?? '',
          hash: element['hash'] as String? ?? '',
          artistid: element['artistid'] as String? ?? '',
          length: element['timelength'] as int ?? 0,
          size: element['size'] as int ?? 0,
        );
        list.add(item);
        // getSongUrl(element['hash']);
      });
      return list;
    } catch (e, s) {
      rethrow;
    }
  }

  static Future<String?> getSongUrl(String hash) async {
    String key = MD5Util.generateMD5('${hash}kgcloud');
    String url = '${Urls.kugouGetSongUrl}pid=6&cmd=3&acceptMp3=1&hash=$hash&key=$key';
    try {
      var result = await HttpCore.getInstance().get(url);
      if (result['url'] == null) {
        ToastUtil.show(result['error']);
        return null;
      }
      return result['url'];
    } catch (e, s) {
      rethrow;
    }
  }



  /// 获取歌曲播放地址
  /// [source] 平台
  /// [songinfo] 歌曲信息
  /// [type] 音质
  static Future getMusicUrl(String source, String musicSource, dynamic songinfo, type) async {

    switch(source) {
      case AppConst.sourceKG:
        if(musicSource == MusicSource.sourceDirect) {
          return KGApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTemp) {
          return KGApiTemp.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTest) {
          return KGApiTest.getMusicUrl(songinfo, type);
        }
        break;
      case AppConst.sourceKW:
        if(musicSource == MusicSource.sourceDirect) {
          return KWApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTemp) {
          return KWApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTest) {
          return KWApiDirect.getMusicUrl(songinfo, type);
        }
        break;
      case AppConst.sourceMG:
        if(musicSource == MusicSource.sourceDirect) {
          return MGApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTemp) {
          return MGApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTest) {
          return MGApiDirect.getMusicUrl(songinfo, type);
        }
        break;
      case AppConst.sourceTX:
        if(musicSource == MusicSource.sourceDirect) {
          return TXApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTemp) {
          return TXApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTest) {
          return TXApiDirect.getMusicUrl(songinfo, type);
        }
        break;
      case AppConst.sourceWY:
        if(musicSource == MusicSource.sourceDirect) {
          return WYApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTemp) {
          return WYApiDirect.getMusicUrl(songinfo, type);
        } else if(musicSource == MusicSource.sourceTest) {
          return WYApiDirect.getMusicUrl(songinfo, type);
        }
        break;
    }
  }
}

/// 所有url
class Urls {
  static String getBaseUrl() {
    return '';
  }

  /// 酷狗搜索
  static const String kugouSearch = "http://mobilecdn.kugou.com/new/app/i/search.php?";

  /// 获取真实播放地址
  static const String kugouGetSongUrl = "http://trackercdn.kugou.com/i/?";
}
