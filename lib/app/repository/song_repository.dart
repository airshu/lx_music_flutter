import 'dart:convert';

import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_temp.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_test.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_music_search.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_song_list.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_tip_search.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_api_direct.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_music_search.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_tip_search.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_music_search.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_song_list.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_tip_search.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_api_direct.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_music_search.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_song_list.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_tip_search.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_api_direct.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_music_search.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_list.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_tip_search.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/search_model.dart';
import 'package:lx_music_flutter/services/app_service.dart';
import 'package:lx_music_flutter/utils/encrypt_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:lx_music_flutter/utils/md5_util.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

class SongRepository {
  /// 旧的酷狗搜索
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

  /// 酷狗搜索获取歌曲播放地址
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

  static Map tipSearchMap = {
    AppConst.sourceKG: KGTipSearch.search,
    AppConst.sourceKW: KWTipSearch.search,
    AppConst.sourceMG: MGTipSearch.search,
    AppConst.sourceTX: TXTipSearch.search,
    AppConst.sourceWY: WYTipSearch.search,
  };

  /// 根据关键字搜索热门词，方便用户快速选择
  /// [keyword]
  /// [source]
  static Future tipSearch(String keyword, String source) async {
    return await tipSearchMap[source](keyword);
  }

  static Map musicSearchMap = {
    AppConst.sourceKG: KGMusicSearch.search,
    AppConst.sourceKW: KWMusicSearch.search,
    AppConst.sourceMG: MGMusicSearch.search,
    AppConst.sourceTX: TXMusicSearch.search,
    AppConst.sourceWY: WYMusicSearch.search,
  };

  static Future getOtherSource(musicInfo, String source) async {}

  /// 搜索歌曲
  static Future<SearchMusicModel?> searchSongs(String str, String source, [int page = 1, int limit = 10]) async {
    try {
      return await musicSearchMap[source](str, page, limit);
    } catch (e, s) {
      Logger.error('$e  $s');
    }
    return null;
  }

  static Map songListSearchMap = {
    AppConst.sourceKG: KGSongList.search,
    AppConst.sourceKW: KWSongList.search,
    AppConst.sourceMG: MGSongList.search,
    AppConst.sourceTX: TXSongList.search,
    AppConst.sourceWY: WYSongList.search,
  };

  /// 搜索歌单
  static Future<SearchListModel?> searchSongList(String str, String source, [int page = 1, int limit = 10]) async {
    try {
      return await songListSearchMap[source](str, page, limit);
    } catch (e, s) {
      Logger.error('$e  $s');
    }
    return null;
  }

  static Map musicUrlMap = {
    AppConst.sourceKG + MusicSource.sourceDirect: KGApiDirect.getMusicUrl,
    AppConst.sourceKG + MusicSource.sourceTemp: KGApiTemp.getMusicUrl,
    AppConst.sourceKG + MusicSource.sourceTest: KGApiTest.getMusicUrl,
    AppConst.sourceKW + MusicSource.sourceDirect: KWApiDirect.getMusicUrl,
    AppConst.sourceKW + MusicSource.sourceTemp: KWApiDirect.getMusicUrl,
    AppConst.sourceKW + MusicSource.sourceTest: KWApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.sourceDirect: MGApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.sourceTemp: MGApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.sourceTest: MGApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.sourceDirect: TXApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.sourceTemp: TXApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.sourceTest: TXApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.sourceDirect: WYApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.sourceTemp: WYApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.sourceTest: WYApiDirect.getMusicUrl,
  };

  /// 获取歌曲播放地址
  /// [source] 平台 @see [AppConst.sourceMG]
  /// [musicSource] 音乐接口来源类型 @see [MusicSource]
  /// [songinfo] 歌曲信息
  /// [type] 音质
  static Future getMusicUrl(String source, String musicSource, dynamic songInfo, type) async {
    try {
      return musicUrlMap[source + musicSource](songInfo, type);
    } catch (e, s) {
      return getOtherSource(songInfo, source);
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
