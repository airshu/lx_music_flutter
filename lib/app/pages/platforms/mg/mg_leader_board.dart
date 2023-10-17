import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/models/music_item.dart';

class MGLeaderBoard {

  static const int limit = 200;

  static List<Board> boardList = [
    Board(id: 'mg__27553319', name: '尖叫新歌榜', bangid: '27553319', webId: 'jianjiao_newsong'),
    Board(id: 'mg__27186466', name: '尖叫热歌榜', bangid: '27186466', webId: 'jianjiao_hotsong'),
    Board(id: 'mg__27553408', name: '尖叫原创榜', bangid: '27553408', webId: 'jianjiao_original'),
    Board(id: 'mg__23189800', name: '港台榜', bangid: '23189800', webId: 'hktw'),
    Board(id: 'mg__23189399', name: '内地榜', bangid: '23189399', webId: 'mainland'),
    Board(id: 'mg__19190036', name: '欧美榜', bangid: '19190036', webId: 'eur_usa'),
    Board(id: 'mg__23189813', name: '日韩榜', bangid: '23189813', webId: 'jpn_kor'),
    Board(id: 'mg__23190126', name: '彩铃榜', bangid: '23190126', webId: 'coloring'),
    Board(id: 'mg__15140045', name: 'KTV榜', bangid: '15140045', webId: 'ktv'),
    Board(id: 'mg__15140034', name: '网络榜', bangid: '15140034', webId: 'network'),
  ];

  static List list = [
    Board(id: 'mgyyb', name: '音乐榜', bangid: '27553319'),
    Board(id: 'mgysb', name: '影视榜', bangid: '23603721'),
    Board(id: 'mghybnd', name: '华语内地榜', bangid: '23603926'),
    Board(id: 'mghyjqbgt', name: '华语港台榜', bangid: '23603954'),
    Board(id: 'mgomb', name: '欧美榜', bangid: '23603974'),
    Board(id: 'mgrhb', name: '日韩榜', bangid: '23603982'),
    Board(id: 'mgwlb', name: '网络榜', bangid: '23604058'),
    Board(id: 'mgclb', name: '彩铃榜', bangid: '23604023'),
    Board(id: 'mgktvb', name: 'KTV榜', bangid: '23604040'),
    Board(id: 'mgrcb', name: '原创榜', bangid: '23604032'),
  ];


  static Future getBoardsData() async {
    String url = 'https://app.c.nf.migu.cn/MIGUM3.0/v1.0/template/rank-list/release';
    var result = await HttpCore.getInstance().get(url, headers: {
      'Referer': 'https://app.c.nf.migu.cn/',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 5.1.1; Nexus 6 Build/LYZ28E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36',
      'channel': '0146921',
    });
    return result;
  }

  static Future getList(String bangid, int page) async {
    String url = getUrl(bangid);
    var result = await HttpCore.getInstance().get(url, getResponse: true);
    List list = [];
    if(result is Response) {
      Map<String, dynamic>? data = result.data;
      if (data?['code'] is String && data?['code'] == '000000') {
        list = AppUtil.filterMusicInfoList(data!['columnInfo']['contents'].map((e) => e['objectInfo']).toList());
      }
    }
    return {
      'total': list.length,
      'list': list,
      'limit': limit,
      'page': page,
      'source': 'mg',
    };
  }




  static String getUrl(String id) {
    return 'https://app.c.nf.migu.cn/MIGUM2.0/v1.0/content/querycontentbyId.do?columnId=$id&needAll=0';
  }

  String getDetailPageUrl(String id) {
    id = id.replaceAll('mg__', '');
    for (var item in boardList) {
      if (item.bangid == id) {
        return 'https://music.migu.cn/v3/music/order/record?listId=${item.webId}';
      }
    }
    return '';
  }

}