import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/respository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class WYLeaderBoard {
  static List<Board> list = [
    Board(id: 'wy__19723756', name: '飙升榜', bangid: '19723756'),
    Board(id: 'wy__3779629', name: '新歌榜', bangid: '3779629'),
    Board(id: 'wy__2884035', name: '原创榜', bangid: '2884035'),
    Board(id: 'wy__991319590', name: '说唱榜', bangid: '991319590'),
    Board(id: 'wy__71384707', name: '古典榜', bangid: '71384707'),
    Board(id: 'wy__1978921795', name: '电音榜', bangid: '1978921795'),
    Board(id: 'wy__5453912201', name: '黑胶VIP爱听榜', bangid: '5453912201'),
    Board(id: 'wy__71385702', name: 'ACG榜', bangid: '71385702'),
    Board(id: 'wy__745956260', name: '韩语榜', bangid: '745956260'),
    Board(id: 'wy__10520166', name: '国电榜', bangid: '10520166'),
    Board(id: 'wy__180106', name: 'UK排行榜周榜', bangid: '180106'),
    Board(id: 'wy__60198', name: '美国Billboard榜', bangid: '60198'),
    Board(id: 'wy__3812895', name: 'Beatport全球电子舞曲榜', bangid: '3812895'),
    Board(id: 'wy__21845217', name: 'KTV唛榜', bangid: '21845217'),
    Board(id: 'wy__60131', name: '日本Oricon榜', bangid: '60131'),
    Board(id: 'wy__2809513713', name: '欧美热歌榜', bangid: '2809513713'),
    Board(id: 'wy__2809577409', name: '欧美新歌榜', bangid: '2809577409'),
    Board(id: 'wy__27135204', name: '法国 NRJ Vos Hits 周榜', bangid: '27135204'),
    Board(id: 'wy__3001835560', name: 'ACG动画榜', bangid: '3001835560'),
    Board(id: 'wy__3001795926', name: 'ACG游戏榜', bangid: '3001795926'),
    Board(id: 'wy__3001890046', name: 'ACG VOCALOID榜', bangid: '3001890046'),
    Board(id: 'wy__3112516681', name: '中国新乡村音乐排行榜', bangid: '3112516681'),
    Board(id: 'wy__5059644681', name: '日语榜', bangid: '5059644681'),
    Board(id: 'wy__5059633707', name: '摇滚榜', bangid: '5059633707'),
    Board(id: 'wy__5059642708', name: '国风榜', bangid: '5059642708'),
    Board(id: 'wy__5338990334', name: '潜力爆款榜', bangid: '5338990334'),
    Board(id: 'wy__5059661515', name: '民谣榜', bangid: '5059661515'),
    Board(id: 'wy__6688069460', name: '听歌识曲榜', bangid: '6688069460'),
    Board(id: 'wy__6723173524', name: '网络热歌榜', bangid: '6723173524'),
    Board(id: 'wy__6732051320', name: '俄语榜', bangid: '6732051320'),
    Board(id: 'wy__6732014811', name: '越南语榜', bangid: '6732014811'),
    Board(id: 'wy__6886768100', name: '中文DJ榜', bangid: '6886768100'),
    Board(id: 'wy__6939992364', name: '俄罗斯top hit流行音乐榜', bangid: '6939992364'),
    Board(id: 'wy__7095271308', name: '泰语榜', bangid: '7095271308'),
    Board(id: 'wy__7356827205', name: 'BEAT排行榜', bangid: '7356827205'),
    Board(id: 'wy__7325478166', name: '编辑推荐榜VOL.44 天才女子摇滚乐队boygenius剖白卑微心迹', bangid: '7325478166'),
    Board(id: 'wy__7603212484', name: 'LOOK直播歌曲榜', bangid: '7603212484'),
    Board(id: 'wy__7775163417', name: '赏音榜', bangid: '7775163417'),
    Board(id: 'wy__7785123708', name: '黑胶VIP新歌榜', bangid: '7785123708'),
    Board(id: 'wy__7785066739', name: '黑胶VIP热歌榜', bangid: '7785066739'),
    Board(id: 'wy__7785091694', name: '黑胶VIP爱搜榜', bangid: '7785091694'),
  ];

  static List<Board> boardList = [
    Board(id: 'wybsb', name: '飙升榜', bangid: '19723756'),
    Board(id: 'wyrgb', name: '热歌榜', bangid: '3778678'),
    Board(id: 'wyxgb', name: '新歌榜', bangid: '3779629'),
    Board(id: 'wyycb', name: '原创榜', bangid: '2884035'),
    Board(id: 'wygdb', name: '古典榜', bangid: '71384707'),
    Board(id: 'wydouyb', name: '抖音榜', bangid: '2250011882'),
    Board(id: 'wyhyb', name: '韩语榜', bangid: '745956260'),
    Board(id: 'wydianyb', name: '电音榜', bangid: '1978921795'),
    Board(id: 'wydjb', name: '电竞榜', bangid: '2006508653'),
    Board(id: 'wyktvbb', name: 'KTV唛榜', bangid: '21845217'),
  ];

  static Future getBoardsData() async {
    String url = 'https://music.163.com/weapi/toplist';
    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({}));
    return result;
  }

  static Future getData(String id) async {
    String url = 'https://music.163.com/weapi/v3/playlist/detail';
    var result = await HttpCore.getInstance().post(url, data: CryptoUtils.weapi({'id': id, 'n': 100000, 'p': 1}), getResponse: true);
    return result;
  }

  static const int limit = 100000;

  static Future getList(String bangid, int page) async {
    var resp = await getData(bangid);
    var musicDetail = await MusiDetailApi.getList(resp['playlist']['trackIds'].map((trackId) => trackId['id']));

    return {
      'total': musicDetail['list'].length,
      'list': musicDetail['list'],
      'limit': limit,
      'page': page,
      'source': 'wy',
    };
  }
}

class MusiDetailApi {
  static Future getList(List ids) async {
    String url = 'https://music.163.com/weapi/v3/song/detail';
    Map<String, dynamic> headers = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36',
      'origin': 'https://music.163.com',
    };
    var res = await HttpCore.getInstance().post(url, headers: headers, data: CryptoUtils.weapi({
      'c': '[${ids.map((id) => '{"id":$id}').join(',')}]',
      'ids': '[${ids.join(',')}]',
    }));
    return res;
  }
}
