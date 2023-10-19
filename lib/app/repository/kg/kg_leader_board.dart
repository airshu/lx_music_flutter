import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';

class KGLeaderBoard {
  static const int listDetailLimit = 100;

  static List<Board> list = [
    Board(id: 'kgtop500', name: 'TOP500', bangid: '8888'),
    Board(id: 'kgwlhgb', name: '网络榜', bangid: '23784'),
    Board(id: 'kgbsb', name: '飙升榜', bangid: '6666'),
    Board(id: 'kgfxb', name: '分享榜', bangid: '21101'),
    Board(id: 'kgcyyb', name: '纯音乐榜', bangid: '33164'),
    Board(id: 'kggfjqb', name: '古风榜', bangid: '33161'),
    Board(id: 'kgyyjqb', name: '粤语榜', bangid: '33165'),
    Board(id: 'kgomjqb', name: '欧美榜', bangid: '33166'),
    Board(id: 'kgdyrgb', name: '电音榜', bangid: '33160'),
    Board(id: 'kgjdrgb', name: 'DJ热歌榜', bangid: '24971'),
    Board(id: 'kghyxgb', name: '华语新歌榜', bangid: '31308'),
  ];

  static List<Board> boardList = [
    Board(id: 'kg__8888', name: 'TOP500', bangid: '8888'),
    Board(id: 'kg__6666', name: '飙升榜', bangid: '6666'),
    Board(id: 'kg__59703', name: '蜂鸟流行音乐榜', bangid: '59703'),
    Board(id: 'kg__52144', name: '抖音热歌榜', bangid: '52144'),
    Board(id: 'kg__52767', name: '快手热歌榜', bangid: '52767'),
    Board(id: 'kg__24971', name: 'DJ热歌榜', bangid: '24971'),
    Board(id: 'kg__23784', name: '网络红歌榜', bangid: '23784'),
    Board(id: 'kg__44412', name: '说唱先锋榜', bangid: '44412'),
    Board(id: 'kg__31308', name: '内地榜', bangid: '31308'),
    Board(id: 'kg__33160', name: '电音榜', bangid: '33160'),
    Board(id: 'kg__31313', name: '香港地区榜', bangid: '31313'),
    Board(id: 'kg__51341', name: '民谣榜', bangid: '51341'),
    Board(id: 'kg__54848', name: '台湾地区榜', bangid: '54848'),
    Board(id: 'kg__31310', name: '欧美榜', bangid: '31310'),
    Board(id: 'kg__33162', name: 'ACG新歌榜', bangid: '33162'),
    Board(id: 'kg__31311', name: '韩国榜', bangid: '31311'),
    Board(id: 'kg__31312', name: '日本榜', bangid: '31312'),
    Board(id: 'kg__49225', name: '80后热歌榜', bangid: '49225'),
    Board(id: 'kg__49223', name: '90后热歌榜', bangid: '49223'),
    Board(id: 'kg__49224', name: '00后热歌榜', bangid: '49224'),
    Board(id: 'kg__33165', name: '粤语金曲榜', bangid: '33165'),
    Board(id: 'kg__33166', name: '欧美金曲榜', bangid: '33166'),
    Board(id: 'kg__33163', name: '影视金曲榜', bangid: '33163'),
    Board(id: 'kg__51340', name: '伤感榜', bangid: '51340'),
    Board(id: 'kg__35811', name: '会员专享榜', bangid: '35811'),
    Board(id: 'kg__37361', name: '雷达榜', bangid: '37361'),
    Board(id: 'kg__21101', name: '分享榜', bangid: '21101'),
    Board(id: 'kg__46910', name: '综艺新歌榜', bangid: '46910'),
    Board(id: 'kg__30972', name: '酷狗音乐人原创榜', bangid: '30972'),
    Board(id: 'kg__60170', name: '闽南语榜', bangid: '60170'),
    Board(id: 'kg__65234', name: '儿歌榜', bangid: '65234'),
    Board(id: 'kg__4681', name: '美国BillBoard榜', bangid: '4681'),
    Board(id: 'kg__25028', name: 'Beatport电子舞曲榜', bangid: '25028'),
    Board(id: 'kg__4680', name: '英国单曲榜', bangid: '4680'),
    Board(id: 'kg__38623', name: '韩国Melon音乐榜', bangid: '38623'),
    Board(id: 'kg__42807', name: 'joox本地热歌榜', bangid: '42807'),
    Board(id: 'kg__36107', name: '小语种热歌榜', bangid: '36107'),
    Board(id: 'kg__4673', name: '日本公信榜', bangid: '4673'),
    Board(id: 'kg__46868', name: '日本SPACE SHOWER榜', bangid: '46868'),
    Board(id: 'kg__42808', name: 'KKBOX风云榜', bangid: '42808'),
    Board(id: 'kg__60171', name: '越南语榜', bangid: '60171'),
    Board(id: 'kg__60172', name: '泰语榜', bangid: '60172'),
    Board(id: 'kg__59895', name: 'R&B榜', bangid: '59895'),
    Board(id: 'kg__59896', name: '摇滚榜', bangid: '59896'),
    Board(id: 'kg__59897', name: '爵士榜', bangid: '59897'),
    Board(id: 'kg__59898', name: '乡村音乐榜', bangid: '59898'),
    Board(id: 'kg__59900', name: '纯音乐榜', bangid: '59900'),
    Board(id: 'kg__59899', name: '古典榜', bangid: '59899'),
    Board(id: 'kg__22603', name: '5sing音乐榜', bangid: '22603'),
    Board(id: 'kg__21335', name: '繁星音乐榜', bangid: '21335'),
    Board(id: 'kg__33161', name: '古风新歌榜', bangid: '33161'),
  ];

  static String getUrl(p, id, limit) {
    return 'http://mobilecdnbj.kugou.com/api/v3/rank/song?version=9108&ranktype=1&plat=0&pagesize=${limit}&area_code=1&page=${p}&rankid=${id}&with_res_tag=0&show_portrait_mv=1';
  }

  static Future getBoardsData() async {
    String url =
        'http://mobilecdnbj.kugou.com/api/v5/rank/list?version=9108&plat=0&showtype=2&parentid=0&apiver=6&area_code=1&withsong=1';
    var result = await HttpCore.getInstance().get(url);
    return result;
  }

  String getSinger(singers) {
    List arr = [];
    singers.forEach((s) {
      arr.add(s['author_name']);
    });
    return arr.join('`');
  }

  static Future getList(String bangid, int page) async {
    String url = getUrl(page, bangid, listDetailLimit);
    var result = await HttpCore.getInstance().get(url);
    var total = result['data']['total'];
    int limit = 100;
    List list = filterData(result['data']['info']);
    return {
      'total': total,
      'list': list,
      'page': page,
      'source': 'kg',
      'limit': limit,
    };
  }

  static List filterData(List<dynamic> rawList) {
    return rawList.map((item) {
      List types = [];
      Map _types = {};
      if (item['filesize'] != 0) {
        String size = AppUtil.sizeFormate(item['filesize']);
        types.add({'type': '128k', 'size': size});
        _types['128k'] = {'size': size, 'hash': item['hash']};
      }
      if (item['320filesize'] != 0) {
        String size = AppUtil.sizeFormate(item['320filesize']);
        types.add({'type': '320k', 'size': size});
        _types['320k'] = {'size': size, 'hash': item['320hash']};
      }
      if (item['sqfilesize'] != 0) {
        String size = AppUtil.sizeFormate(item['sqfilesize']);
        types.add({'type': 'flac', 'size': size});
        _types['flac'] = {'size': size, 'hash': item['sqhash']};
      }
      if (item['filesize_high'] != 0) {
        String size = AppUtil.sizeFormate(item['sqfilesize']);
        types.add({'type': 'flac24bit', 'size': size});
        _types['flac24bit'] = {'size': size, 'hash': item['sqhash']};
      }
      return {
        'singer': AppUtil.formatSingerName(singers: item['authors'], nameKey: 'author_name'),
        'name': AppUtil.decodeName(item['songname']),
        'albumName': AppUtil.decodeName(item['remark']),
        'albumId': item['album_id'],
        'songmid': item['audio_id'],
        'source': 'kg',
        'interval': AppUtil.formatPlayTime(item['duration']),
        'img': null,
        'lrc': null,
        'hash': item['hash'],
        'otherSource': null,
        'types': types,
        '_types': _types,
        'typeUrl': {},
      };
    }).toList();
  }
}
