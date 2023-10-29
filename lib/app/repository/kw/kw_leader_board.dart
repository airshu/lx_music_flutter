import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KWLeaderBoard {
  static List<Board> list = [
    Board(id: 'kwbiaosb', name: '飙升榜', bangid: '93'),
    Board(id: 'kwregb', name: '热歌榜', bangid: '16'),
    Board(id: 'kwhuiyb', name: '会员榜', bangid: '145'),
    Board(id: 'kwdouyb', name: '抖音榜', bangid: '158'),
    Board(id: 'kwqsb', name: '趋势榜', bangid: '187'),
    Board(id: 'kwhuaijb', name: '怀旧榜', bangid: '26'),
    Board(id: 'kwhuayb', name: '华语榜', bangid: '104'),
    Board(id: 'kwyueyb', name: '粤语榜', bangid: '182'),
    Board(id: 'kwoumb', name: '欧美榜', bangid: '22'),
    Board(id: 'kwhanyb', name: '韩语榜', bangid: '184'),
    Board(id: 'kwriyb', name: '日语榜', bangid: '183'),
  ];

  static List<Board> boardList = [
    Board(id: 'kw__93', name: '飙升榜', bangid: '93'),
    Board(id: 'kw__17', name: '新歌榜', bangid: '17'),
    Board(id: 'kw__16', name: '热歌榜', bangid: '16'),
    Board(id: 'kw__158', name: '抖音热歌榜', bangid: '158'),
    Board(id: 'kw__292', name: '铃声榜', bangid: '292'),
    Board(id: 'kw__284', name: '热评榜', bangid: '284'),
    Board(id: 'kw__290', name: 'ACG新歌榜', bangid: '290'),
    Board(id: 'kw__286', name: '台湾KKBOX榜', bangid: '286'),
    Board(id: 'kw__279', name: '冬日暖心榜', bangid: '279'),
    Board(id: 'kw__281', name: '巴士随身听榜', bangid: '281'),
    Board(id: 'kw__255', name: 'KTV点唱榜', bangid: '255'),
    Board(id: 'kw__280', name: '家务进行曲榜', bangid: '280'),
    Board(id: 'kw__282', name: '熬夜修仙榜', bangid: '282'),
    Board(id: 'kw__283', name: '枕边轻音乐榜', bangid: '283'),
    Board(id: 'kw__278', name: '古风音乐榜', bangid: '278'),
    Board(id: 'kw__264', name: 'Vlog音乐榜', bangid: '264'),
    Board(id: 'kw__242', name: '电音榜', bangid: '242'),
    Board(id: 'kw__187', name: '流行趋势榜', bangid: '187'),
    Board(id: 'kw__204', name: '现场音乐榜', bangid: '204'),
    Board(id: 'kw__186', name: 'ACG神曲榜', bangid: '186'),
    Board(id: 'kw__185', name: '最强翻唱榜', bangid: '185'),
    Board(id: 'kw__26', name: '经典怀旧榜', bangid: '26'),
    Board(id: 'kw__104', name: '华语榜', bangid: '104'),
    Board(id: 'kw__182', name: '粤语榜', bangid: '182'),
    Board(id: 'kw__22', name: '欧美榜', bangid: '22'),
    Board(id: 'kw__184', name: '韩语榜', bangid: '184'),
    Board(id: 'kw__183', name: '日语榜', bangid: '183'),
  ];

  static Future getBoardsData() async {
    String url = 'http://qukudata.kuwo.cn/q.k?op=query&cont=tree&node=2&pn=0&rn=1000&fmt=json&level=2';
    var result = await HttpCore.getInstance().get(url);
    return result;
  }

  static const int limit = 100;

  /// 获取排行榜列表
  static Future<LeaderBoardModel?> getList(String bangid, int page) async {
    String url = getUrl(page, limit, bangid);
    var result = await HttpCore.getInstance().get(url);
    int total = int.parse(result['num']);
    List<LeaderBoardItem> list = filterData(result['musiclist']);
    return LeaderBoardModel(list: list, total: total, source: AppConst.sourceKW, limit: limit, page: page);
  }

  static List<LeaderBoardItem> filterData(List<dynamic> rawList) {
    return rawList.map((item) {
      List<String> formats = item['formats'].split('|');
      List<Map<String, dynamic>> types = [];
      Map<String, dynamic> _types = {};
      if (formats.contains('MP3128')) {
        types.add({'type': '128k', 'size': null});
        _types['128k'] = {'size': null};
      }
      // if (formats.includes('MP3192')) {
      //   types.push({ type: '192k', size: null })
      //   _types['192k'] = {
      //     size: null,
      //   }
      // }
      if (formats.contains('MP3H')) {
        types.add({'type': '320k', 'size': null});
        _types['320k'] = {'size': null};
      }
      // if (formats.includes('AL')) {
      //   types.push({ type: 'ape', size: null })
      //   _types.ape = {
      //     size: null,
      //   }
      // }
      if (formats.contains('ALFLAC')) {
        types.add({'type': 'flac', 'size': null});
        _types['flac'] = {'size': null};
      }
      if (formats.contains('HIRFLAC')) {
        types.add({'type': 'flac24bit', 'size': null});
        _types['flac24bit'] = {'size': null};
      }
      // types.reverse()
      return LeaderBoardItem(
        singer: AppUtil.formatSinger(KWSongList.decodeName(item['artist'])),
        name: KWSongList.decodeName(item['name']),
        albumName: KWSongList.decodeName(item['album']),
        albumId: item['albumid'],
        songmid: item['id'],
        source: AppConst.sourceKW,
        interval: AppUtil.formatPlayTime(int.parse(item['song_duration'])),
        img: item['pic'] ?? '',
        qualityList: types,
        qualityMap: _types,
        urlMap: {},
      );
    }).toList();
  }

  static String getUrl(int p, int l, String id) {
    return 'http://kbangserver.kuwo.cn/ksong.s?from=pc&fmt=json&pn=${p - 1}&rn=$l&type=bang&data=content&id=$id&show_copyright_off=0&pcmp4=1&isbang=1';
  }
}
