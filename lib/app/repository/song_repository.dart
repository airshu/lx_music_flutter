import 'dart:convert';

import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_temp.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_api_test.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_leader_board.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_music_search.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_song_list.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_tip_search.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_api_direct.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_music_search.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_tip_search.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_api_direct.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_leader_board.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_music_search.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_song_list.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_tip_search.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_api_direct.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_leader_board.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_music_search.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_song_list.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_tip_search.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_api_direct.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_leader_board.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_music_search.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_list.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_tip_search.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/models/music_item.dart';
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
          songmid: element['id'] as String? ?? '',
          name: element['filename'] as String? ?? '',
          albumName: element['artist'] as String? ?? '',
          albumId: element['album'] as String? ?? '',
          hash: element['hash'] as String? ?? '',
          singer: element['artistid'] as String? ?? '',
          interval: element['timelength'],
          source: '',
          img: '',
          qualityList: [],
          qualityMap: {},
          urlMap: {},
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
  /// [keyword] 关键字
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
  /// [str] 歌曲关键字
  static Future<MusicModel?> searchSongs(String str, String source, [int page = 1, int limit = 10]) async {
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
  /// [str] 关键字
  static Future<MusicListModel?> searchSongList(String str, String source, [int page = 1, int limit = 10]) async {
    try {
      return await songListSearchMap[source](str, page, limit);
    } catch (e, s) {
      Logger.error('$e  $s');
    }
    return null;
  }

  static Map musicUrlMap = {
    AppConst.sourceKG + MusicSource.httpSourceDirect: KGApiDirect.getMusicUrl,
    AppConst.sourceKG + MusicSource.httpSourceTemp: KGApiTemp.getMusicUrl,
    AppConst.sourceKG + MusicSource.httpSourceTest: KGApiTest.getMusicUrl,
    AppConst.sourceKW + MusicSource.httpSourceDirect: KWApiDirect.getMusicUrl,
    AppConst.sourceKW + MusicSource.httpSourceTemp: KWApiDirect.getMusicUrl,
    AppConst.sourceKW + MusicSource.httpSourceTest: KWApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.httpSourceDirect: MGApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.httpSourceTemp: MGApiDirect.getMusicUrl,
    AppConst.sourceMG + MusicSource.httpSourceTest: MGApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.httpSourceDirect: TXApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.httpSourceTemp: TXApiDirect.getMusicUrl,
    AppConst.sourceTX + MusicSource.httpSourceTest: TXApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.httpSourceDirect: WYApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.httpSourceTemp: WYApiDirect.getMusicUrl,
    AppConst.sourceWY + MusicSource.httpSourceTest: WYApiDirect.getMusicUrl,
  };

  /// 获取歌曲播放地址
  /// [source] 平台 @see [AppConst.sourceMG]
  /// [musicSource] 音乐接口来源类型 @see [MusicSource]
  /// [songinfo] 歌曲信息
  /// [type] 音质
  static Future getMusicUrl(String source, String musicSource, MusicItem songInfo, type) async {
    try {
      return musicUrlMap[source + musicSource]?.call(songInfo, type);
    } catch (e, s) {
      return getOtherSource(songInfo, source);
    }
  }

  static Map songListMap = {
    AppConst.sourceKG: KGSongList.getList,
    AppConst.sourceKW: KWSongList.getList,
    AppConst.sourceMG: MGSongList.getList,
    AppConst.sourceTX: TXSongList.getList,
    AppConst.sourceWY: WYSongList.getList,
  };

  /// 获取歌单列表
  /// [sortId] 分类ID
  /// [tagId] 标签ID
  static Future<MusicListModel?> getList(String source, String? sortId, String? tagId, [int page = 0]) async {
    try {
      return songListMap[source]?.call(sortId, tagId, page);
    } catch (e, s) {
      Logger.error('$e  $s');
    }
  }

  static Map songListDetailMap = {
    AppConst.sourceKG: KGSongList.getListDetail,
    AppConst.sourceKW: KWSongList.getListDetail,
    AppConst.sourceMG: MGSongList.getListDetail,
    AppConst.sourceTX: TXSongList.getListDetail,
    AppConst.sourceWY: WYSongList.getListDetail,
  };

  /// 获取歌单详情
  /// [id] 歌单ID
  static Future<MusicModel?> getListDetail(String source, String id, int page) async {
    return songListDetailMap[source]?.call(id, page);
  }

  static Map leaderBoardMap = {
    AppConst.sourceKG: KGLeaderBoard.getList,
    AppConst.sourceKW: KWLeaderBoard.getList,
    AppConst.sourceMG: MGLeaderBoard.getList,
    AppConst.sourceTX: TxLeaderBoard.getList,
    AppConst.sourceWY: WYLeaderBoard.getList,
  };

  /// 获取榜单列表
  /// [bangid] 榜单ID
  static Future<LeaderBoardModel?> getLeaderBoardList(String source, String bangid, int page) async {
    return await leaderBoardMap[source](bangid, page);
  }

  static Map tagsMap = {
    AppConst.sourceKG: KGSongList.getTags,
    AppConst.sourceKW: KWSongList.getTags,
    AppConst.sourceMG: MGSongList.getTags,
    AppConst.sourceTX: TXSongList.getTags,
    AppConst.sourceWY: WYSongList.getTags,
  };

  /// 获取不同平台歌单标签
  static Future getTags(String source) async {
    return tagsMap[source]?.call();
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
