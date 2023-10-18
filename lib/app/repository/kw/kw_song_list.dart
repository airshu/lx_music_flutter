import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/app_util.dart';
import 'package:lx_music_flutter/app/repository/wy/crypto_utils.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/http/http_client.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:convert/convert.dart' as convert;

class KWSongList {
  static const int limit_song = 10000;
  static const int limit_list = 36;

  static const String tagsUrl =
      'http://wapi.kuwo.cn/api/pc/classify/playlist/getTagList?cmd=rcm_keyword_playlist&user=0&prod=kwplayer_pc_9.0.5.0&vipver=9.0.5.0&source=kwplayer_pc_9.0.5.0&loginUid=0&loginSid=0&appUid=76039576';
  static const String hotTagUrl = 'http://wapi.kuwo.cn/api/pc/classify/playlist/getRcmTagList?loginUid=0&loginSid=0&appUid=76039576';

  static List<SortItem> sortList = [
    SortItem(name: '最新', tid: 'new', id: 'new', isSelect: true),
    SortItem(name: '最热', tid: 'hot', id: 'hot'),
  ];

  static Future getSearch(String text, int page, int pageSize) async {
    String url =
        'http://search.kuwo.cn/r.s?all=${Uri.encodeComponent(text)}&pn=${page - 1}&rn=$pageSize&rformat=json&encoding=utf8&ver=mbox&vipver=MUSIC_8.7.7.0_BCS37&plat=pc&devid=28156413&ft=playlist&pay=0&needliveshow=0';

    var result = await HttpCore.getInstance().get(url);
    result = result.replaceAll(RegExp(r"('(?=(,\s*')))|('(?=:))|((?<=([:,]\s*))')|((?<={)')|('(?=}))"), '"');
    result = json.decode(result);
    List list = [];
    result['abslist'].forEach((e) {
      Logger.debug('$e');
      list.add(e);
    });
    return list;
  }

  static RegExp mInfo = RegExp(r'level:(\w+),bitrate:(\d+),format:(\w+),size:([\w.]+)');
  static RegExp listDetailLink = RegExp(r'^.+\/playlist(?:_detail)?\/(\d+)(?:\?.*|&.*$|#.*$|$)');

  static Future getListDetail(String id, int page) async {
    if (RegExp(r'\/bodian\/').hasMatch(id)) {
      return getListDetailMusicListByBD(id, page);
    }
    if (RegExp(r'[?&:/]').hasMatch(id)) {
      id = id.replaceAll(listDetailLink, '\$1');
    } else if (RegExp(r'^digest-').hasMatch(id)) {
      final parts = id.split('__');
      String digest = parts[0].replaceFirst('digest-', '');
      id = parts[1];
      switch (digest) {
        case '8':
          break;
        case '13':
          return getAlbumListDetail(id, page);
        case '5':
        default:
          return getListDetailDigest5(id, page);
      }
    }
    return getListDetailDigest8(id, page);
  }

  static Future getListDetailDigest5(String id, int page) async {
    final detailId = await getListDetailDigest5Info(id, page);
    return getListDetailDigest5Music(detailId, page);
  }

  static Future getListDetailDigest5Music(String id, int page) async {
    final result = await HttpCore.getInstance().get(
        'http://nplserver.kuwo.cn/pl.svc?op=getlistinfo&pid=$id&pn=${page - 1}&rn=$limit_song&encode=utf-8&keyset=pl2012&identity=kuwo&pcmp4=1');
    if (result['result'] != 'ok') {
      return getListDetail(id, page);
    }
    return {
      'list': filterListDetail(result['musiclist']),
      'page': page,
      'limit': result['rn'],
      'total': result['total'],
      'source': 'kw',
      'info': DetailInfo(
        name: result['title'],
        imgUrl: result['pic'],
        desc: result['info'],
        author: result['uname'],
        playCount: AppUtil.formatPlayCount(result['playnum']),
      ),
    };
  }

  static Future getListDetailDigest5Info(String id, int page) async {
    final result =
        await HttpCore.getInstance().get('http://qukudata.kuwo.cn/q.k?op=query&cont=ninfo&node=$id&pn=0&rn=1&fmt=json&src=mbox&level=2');
    if (result['child'] == null) {
      return getListDetail(id, page);
    }
    // console.log(body)
    return result['child'].length > 0 ? result['child'][0]['sourceid'] : null;
  }

  static Future getAlbumListDetail(
    String id,
    int page,
  ) async {
    List<Map<String, dynamic>> filterListDetail(List<dynamic> rawList, String albumName, String albumId) {
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
        return {
          'singer': formatSinger(decodeName(item['artist'])),
          'name': decodeName(item['name']),
          'albumName': albumName,
          'albumId': albumId,
          'songmid': item['id'],
          'source': 'kw',
          'interval': null,
          'img': item['pic'],
          'lrc': null,
          'otherSource': null,
          'types': types,
          '_types': _types,
          'typeUrl': {},
        };
      }).toList();
    }

    var result = await HttpCore.getInstance().get(
        'http://search.kuwo.cn/r.s?pn=${page - 1}&rn=${limit_song}&stype=albuminfo&albumid=$id&show_copyright_off=0&encoding=utf&vipver=MUSIC_9.1.0');

    result = result.replaceAll(RegExp(r"('(?=(,\s*')))|('(?=:))|((?<=([:,]\s*))')|((?<={)')|('(?=}))"), '"');
    var body = json.decode(result);

    if (body['musiclist'] == null) {
      return getAlbumListDetail(id, page);
    }
    body['name'] = decodeName(body['name']);
    return {
      'list': filterListDetail(body['musiclist'], body['name'], body['albumid']),
      'page': page,
      'limit': limit_song,
      'total': int.parse(body['songnum']),
      'source': 'kw',
      'info': DetailInfo(
        name: body['name'],
        imgUrl: body['img'] ?? body['hts_img'],
        desc: decodeName(body['info']),
        author: decodeName(body['artist']),
        playCount: AppUtil.formatPlayCount(body['playnum'] ?? '0'),
      ),
    };
  }

  static Future getListDetailDigest8(String id, int page) async {
    final result = await HttpCore.getInstance().get(getListDetailUrl(id, page));
    if (result['result'] != 'ok') {
      return getListDetail(id, page);
    }
    return {
      'list': filterListDetail(result['musiclist']),
      'page': page,
      'limit': result['rn'],
      'total': result['total'],
      'source': 'kw',
      'info': DetailInfo(
        name: result['title'],
        imgUrl: result['pic'],
        desc: result['info'],
        author: result['uname'],
        playCount: AppUtil.formatPlayCount(result['playnum']),
      ),
    };
  }

  static List<Map<String, dynamic>> filterListDetail(List<dynamic> rawData) {
    return rawData.map((item) {
      List<String> infoArr = item['N_MINFO'].split(';');
      List<Map<String, dynamic>> types = [];
      Map<String, dynamic> _types = {};
      for (var info in infoArr) {
        RegExpMatch? match = mInfo.firstMatch(info);
        if (match != null) {
          switch (match.group(2)) {
            case '4000':
              types.add({'type': 'flac24bit', 'size': match.group(4)});
              _types['flac24bit'] = {'size': match.group(4)?.toUpperCase()};
              break;
            case '2000':
              types.add({'type': 'flac', 'size': match.group(4)});
              _types['flac'] = {'size': match.group(4)?.toUpperCase()};
              break;
            case '320':
              types.add({'type': '320k', 'size': match.group(4)});
              _types['320k'] = {'size': match.group(4)?.toUpperCase()};
              break;
            case '192':
            case '128':
              types.add({'type': '128k', 'size': match.group(4)});
              _types['128k'] = {'size': match.group(4)?.toUpperCase()};
              break;
          }
        }
      }
      types = types.reversed.toList();

      return {
        'singer': formatSinger(decodeName(item['artist'])),
        'name': decodeName(item['name']),
        'albumName': decodeName(item['album']),
        'albumId': item['albumid'],
        'songmid': item['id'],
        'source': 'kw',
        'interval': AppUtil.formatPlayTime(int.parse(item['duration'])),
        'img': null,
        'lrc': null,
        'otherSource': null,
        'types': types,
        '_types': _types,
        'typeUrl': {},
      };
    }).toList();
  }

  static String formatSinger(String rawData) {
    return rawData.replaceAll('&', '、');
  }

  static String decodeName(String? str) {
    final encodeNames = {
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&apos;': '\'',
      '&#039;': '\'',
      '&nbsp;': ' ',
    };

    return str?.replaceAllMapped(RegExp('(?:&amp;|&lt;|&gt;|&quot;|&apos;|&#039;|&nbsp;)'), (match) {
          return encodeNames[match.group(0)]!;
        }) ??
        '';
  }

  static Future getListDetailMusicListByBD(String id, int page) async {
    final uid = RegExp(r'uid=(\d+)').firstMatch(id)?.group(1);
    final listId = RegExp(r'playlistId=(\d+)').firstMatch(id)?.group(1);
    final source = RegExp(r'source=(\d+)').firstMatch(id)?.group(1);
    if (listId == null) {
      throw Exception('failed');
    }
    final tasks = [getListDetailMusicListByBDList(listId, source!, page)];
    switch (source) {
      case '4':
        tasks.add(getListDetailMusicListByBDListInfo(listId, source));
        break;
      case '5':
        tasks.add(getListDetailMusicListByBDUserPub(uid ?? listId));
        break;
    }
    final results = await Future.wait(tasks);
    final listData = results[0];
    final info = results[1];
    listData.info = info ??
        {
          'name': '',
          'img': '',
          'desc': '',
          'author': '',
          'play_count': '',
        };
    // print(listData);
    return listData;
  }

  static Future<Map<String, dynamic>?> getListDetailMusicListByBDUserPub(String id) async {
    final url = 'https://bd-api.kuwo.cn/api/ucenter/users/pub/$id?reqId=${getReqId()}';
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
      'plat': 'h5',
    };

    try {
      final response = await HttpCore.getInstance().get(url, headers: headers);
      final infoData = json.decode(response.body);

      if (infoData['code'] != 200) {
        return null;
      }

      return {
        'name': infoData['data']['userInfo']['nickname'] + '喜欢的音乐',
        'img': infoData['data']['userInfo']['headImg'],
        'desc': '',
        'author': infoData['data']['userInfo']['nickname'],
        'play_count': '',
      };
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getListDetailMusicListByBDListInfo(String id, String source) async {
    final url = 'https://bd-api.kuwo.cn/api/service/playlist/info/$id?reqId=${getReqId()}&source=$source';
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
      'plat': 'h5',
    };

    try {
      final response = await HttpCore.getInstance().get(url, headers: headers);
      final infoData = json.decode(response.body);

      if (infoData['code'] != 200) {
        return null;
      }

      return {
        'name': infoData['data']['name'],
        'img': infoData['data']['pic'],
        'desc': infoData['data']['description'],
        'author': infoData['data']['creatorName'],
        'play_count': infoData['data']['playNum'],
      };
    } catch (e) {
      return null;
    }
  }

  static String getReqId() {
    String t() {
      return (65536 * (1 + Random().nextDouble()) ~/ 1).toRadixString(16).substring(1);
    }

    return t() + t() + t() + t() + t() + t() + t() + t();
  }

  static Future getListDetailMusicListByBDList(String id, String source, int page, {int tryNum = 0}) async {
    final url = 'https://bd-api.kuwo.cn/api/service/playlist/$id/musicList?reqId=${getReqId()}&source=$source&pn=$page&rn=${limit_song}';
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
      'plat': 'h5',
    };

    try {
      final response = await HttpCore.getInstance().get(url, headers: headers);
      final listData = json.decode(response.body);

      if (listData['code'] != 200) {
        throw Exception('failed');
      }

      return {
        'list': filterBDListDetail(listData['data']['list']),
        'page': page,
        'limit': listData['data']['pageSize'],
        'total': listData['data']['total'],
        'source': 'kw',
      };
    } catch (e) {
      if (tryNum > 2) {
        throw Exception('try max num');
      }
      return getListDetailMusicListByBDList(id, source, page, tryNum: tryNum + 1);
    }
  }

  static List<Map<String, dynamic>> filterBDListDetail(List<dynamic> rawList) {
    return rawList.map((item) {
      List<Map<String, dynamic>> types = [];
      Map<String, dynamic> _types = {};
      for (var info in item['audios']) {
        info['size'] = info['size']?.toString()?.toUpperCase();
        switch (info['bitrate']) {
          case '4000':
            types.add({'type': 'flac24bit', 'size': info['size']});
            _types['flac24bit'] = {'size': info['size']};
            break;
          case '2000':
            types.add({'type': 'flac', 'size': info['size']});
            _types['flac'] = {'size': info['size']};
            break;
          case '320':
            types.add({'type': '320k', 'size': info['size']});
            _types['320k'] = {'size': info['size']};
            break;
          case '192':
          case '128':
            types.add({'type': '128k', 'size': info['size']});
            _types['128k'] = {'size': info['size']};
            break;
        }
      }
      types = types.reversed.toList();

      return {
        'singer': item['artists'].map((s) => s['name']).join('、'),
        'name': item['name'],
        'albumName': item['album'],
        'albumId': item['albumId'],
        'songmid': item['id'],
        'source': 'kw',
        'interval': AppUtil.formatPlayTime(item['duration']),
        'img': item['albumPic'],
        'releaseDate': item['releaseDate'],
        'lrc': null,
        'otherSource': null,
        'types': types,
        '_types': _types,
        'typeUrl': {},
      };
    }).toList();
  }

  static String getListDetailUrl(String id, int page) {
    String url =
        'http://nplserver.kuwo.cn/pl.svc?op=getlistinfo&pid=${id}&pn=${page - 1}&rn=${limit_song}&encode=utf8&keyset=pl2012&identity=kuwo&pcmp4=1&vipver=MUSIC_9.0.5.0_W1&newver=1';
    return url;
  }

  static String? token;

  static Future getToken() async {
    if (token != null) {
      return token;
    }
    String url = 'http://www.kuwo.cn/';

    var result = await HttpCore.getInstance().get(url);
    print('=====  $result');
  }

  /// 返回热门歌单标签
  ///
  /// {
  ///   'key': '',
  ///   'describe': '',
  ///   'type': '',
  ///   'popularity': '',
  /// }
  static Future<List> getHotTagList() async {
    String url =
        'http://hotword.kuwo.cn/hotword.s?prod=kwplayer_ar_9.3.0.1&corp=kuwo&newver=2&vipver=9.3.0.1&source=kwplayer_ar_9.3.0.1_40.apk&p2p=1&notrace=0&uid=0&plat=kwplayer_ar&rformat=json&encoding=utf8&tabid=1';
    var result = await HttpCore.getInstance().get(url);
    Logger.debug('$result');
    return result['tagvalue'];
  }

  static Future getHotTag() async {
    try {
      var res = await HttpCore.getInstance().get(hotTagUrl);
      Logger.debug(res);
      if (res['code'] == 200) {
        return filterInfoHotTag(res['data'][0]['data']);
      }
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  static filterInfoHotTag(List rawList) {
    return rawList.map((item) {
      return {
        'id': '${item['id']}-${item['digest']}',
        'name': item['name'],
        'source': 'kw',
      };
    }).toList();
  }

  static filterTagInfo(List rawList) {
    return rawList.map((type) {
      return {
        'name': type['name'],
        'list': type['data'].map(((item) {
          return {
            'parent_id': type['id'],
            'parent_name': type['name'],
            'id': '${item['id']}-${item['digest']}',
            'name': item['name'],
            'source': 'kw',
          };
        })),
      };
    }).toList();
  }

  static Future getTag() async {
    try {
      var res = await HttpCore.getInstance().get(tagsUrl);
      Logger.debug(res);
      if (res['code'] == 200) {
        return filterTagInfo(res['data']);
      }
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  static Future getTags() async {
    try {
      var tags = await getTag();
      var hotTags = await getHotTag();
      return {
        'tags': tags ?? [],
        'hotTags': hotTags ?? [],
        'source': 'kw',
      };
    } catch (e, s) {
      Logger.error('$e  $s');
    }

    // List list = [];
    // res.forEach((element) {
    //   list.addAll(element.map((e) {
    //     e['source'] = 'kw';
    //     return e;
    //   }).toList());
    // });
    // return list;
  }

  static Future getMusicUrlDirect(String songmid, String type) async {
    String url = 'http://www.kuwo.cn/api/v1/www/music/playUrl?mid=$songmid&type=music&br=$type';
    Map<String, dynamic> headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:82.0) Gecko/20100101 Firefox/82.0',
      'Referer': 'http://kuwo.cn/',
      'cookie': 'Hm_Iuvt_cdb524f42f0cer9b268e4v7y734w5esq24=4cGcsx3ej3tkYfeGrFtdS2kSZ6YD3nbD',
      'Secret': '14da58a88a83170f11c3a63bb0ff6aec68a7487b64551a1f997356d719980a2b028f34f5',
      "Accept": "application/json",
      'Secret': '14da58a88a83170f11c3a63bb0ff6aec68a7487b64551a1f997356d719980a2b028f34f5',
    };
    final result = await HttpCore.getInstance().get(url, headers: headers);
    if (result['success'] == false) {
      return {'type': type, 'url': ''};
    }
    return {'type': type, 'url': result['data']['url']};
  }

  static Future getMusicUrlTemp(String songmid, String type) async {
    String url = 'http://tm.tempmusics.tk/url/kw/$songmid/$type';
    Map<String, dynamic> headers = {
      'User-Agent': 'lx-music request',
      AppConst.bHh: AppConst.bHh,
    };
    final result = await HttpCore.getInstance().get(url, headers: headers);
    return result != null && result['code'] == 0 ? {'type': type, 'url': result['data']} : Future.error(Exception(result['msg']));
  }

  static Future getMusicUrlTest(String songmid, String type) async {
    Map<String, dynamic> headers = {
      'User-Agent': 'lx-music request',
      AppConst.bHh: AppConst.bHh,
      'family': 4,
    };
    String url = 'http://ts.tempmusics.tk/url/kw/$songmid/$type';
    // headers = await getHeader(url, headers);
    final result = await HttpCore.getInstance()
        .get(url, headers: headers, options: Options(sendTimeout: const Duration(seconds: 15), method: 'get'));
    return result['code'] == 0 ? {'type': type, 'url': result['data']} : Future.error(Exception(result.fail));
  }

  /// 获取歌曲封面
  static Future getPic(String songmid) async {
    String url = 'http://artistpicserver.kuwo.cn/pic.web?corp=kuwo&type=rid_pic&pictype=500&size=500&rid=$songmid';
    var result = await HttpCore.getInstance().get(url);
    return result;
  }

  // static RegExp regx = RegExp(r'(?:\d\w)+');
  //
  // static Future<Map<String, dynamic>> getHeader(String url, Map<String, dynamic> headers) async {
  //   if (headers.containsKey(AppConst.bHh)) {
  //     final bytes = convert.hex.decode(AppConst.bHh);
  //     String s = utf8.decode(bytes);
  //     s = s.replaceAll(s.substring(s.length-1), '');
  //     s = utf8.decode(base64.decode(s));
  //
  //     String v = AppConst.version.split('-')[0].split('.').map((n) => n.length < 3 ? n.padLeft(3, '0') : n).join('');
  //     String v2 = '';
  //
  //     List matches = regx.allMatches('$url$v').map((match) => match.group(0)).toList();
  //     final jsonStr = json.encode(matches);
  //     print('正则匹配http最后两位 jsonStr:  $jsonStr');
  //     String tempStr = _formatJson(jsonStr, 1);
  //     tempStr = '$tempStr$v';
  //     tempStr = base64.encode(utf8.encode(tempStr));
  //     print('base64处理  $tempStr');
  //
  //     final codec = ZLibCodec(raw: true);
  //     final value = codec.encode(utf8.encode(tempStr));
  //     print('deflateRaw压缩算法  $value');
  //     String hexString = value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  //     hexString = '$hexString&${int.parse(v)}$v2';
  //     print('计算最终结果： $hexString');
  //
  //     headers.remove(AppConst.bHh);
  //     headers[s] = hexString;
  //   }
  //   headers["Accept"] =  "application/json";
  //   return headers;
  // }
  //
  // static String _formatJson(String jsonString, int spaces) {
  //   final indent = ' ' * spaces;
  //   final buffer = StringBuffer();
  //   var level = 0;
  //
  //   for (var i = 0; i < jsonString.length; i++) {
  //     final char = jsonString[i];
  //
  //     if (char == '{' || char == '[') {
  //       buffer.write(char);
  //       buffer.write('\n');
  //       level++;
  //       buffer.write(indent * level);
  //     } else if (char == '}' || char == ']') {
  //       buffer.write('\n');
  //       level--;
  //       buffer.write(indent * level);
  //       buffer.write(char);
  //     } else if (char == ',') {
  //       buffer.write(char);
  //       buffer.write('\n');
  //       buffer.write(indent * level);
  //     } else {
  //       buffer.write(char);
  //     }
  //   }
  //
  //   return buffer.toString();
  // }

  static Future<List<int>> deflateRaw(List<int> input) async {
    final codec = ZLibCodec(raw: true);
    final compressed = codec.encode(input);
    return compressed;
  }

  static Future getList([String? sortId, String? tagId, int page = 0]) async {
    dynamic id;
    dynamic type;
    if (tagId != null) {
      List arr = tagId.split('-');
      id = arr[0];
      type = arr[1];
    } else {
      id = null;
    }
    try {
      var url = await getListUrl(sortId, id, type, page);
      var res = await HttpCore.getInstance().get(url, getResponse: true);
      if (res.data is String) {
        res = jsonDecode(res.data);
      } else {
        res = res.data;
      }
      if (id == null || type == '10000') {
        return {
          'list': filterList(res['data']['data']),
          'total': res['data']['total'],
          'page': res['data']['pn'],
          'limit': res['data']['rn'],
          'source': 'kw',
        };
      }

      return {
        'list': filterList2(res),
        'total': 1000,
        'page': page,
        'limit': 1000,
        'source': 'kw',
      };
    } catch (e, s) {
      Logger.error('kw getList  $e  $s');
    }
  }

  static getListUrl([sortId, id, type, page]) {
    if (id == null) {
      return 'http://wapi.kuwo.cn/api/pc/classify/playlist/getRcmPlayList?loginUid=0&loginSid=0&appUid=76039576&&pn=${page}&rn=${limit_list}&order=${sortId}';
    }
    switch (type) {
      case '10000':
        return 'http://wapi.kuwo.cn/api/pc/classify/playlist/getTagPlayList?loginUid=0&loginSid=0&appUid=76039576&pn=${page}&id=${id}&rn=${limit_list}';
      case '43':
        return 'http://mobileinterfaces.kuwo.cn/er.s?type=get_pc_qz_data&f=web&id=${id}&prod=pc';
    }
  }

  static filterList(List rawData) {
    List list = [];
    for (var item in rawData) {
      list.add({
        'play_count': AppUtil.formatPlayCount(int.parse(item['listencnt'] ?? '0')),
        'id': 'digest-${item['digest']}__${item['id']}',
        'author': item['uname'],
        'name': item['name'],
        'total': item['total'],
        'img': item['img'],
        'grade': double.parse(item['favorcnt']) / 10,
        'desc': item['desc'],
        'source': 'kw',
      });
    }
    return list;
  }

  static filterList2(rawData) {
    List list = [];
    for (var data in rawData) {
      if (data['label'] == null) continue;
      for (var item in data['list']) {
        list.add({
          'play_count': AppUtil.formatPlayCount(item['listencnt'] ?? 0),
          'id': 'digest-${item['digest']}__${item['id']}',
          'author': item['uname'],
          'name': item['name'],
          'total': item['total'],
          'img': item['img'],
          'grade': (double.parse(item['favorcnt'] ?? '1.0')) / 10,
          'desc': item['desc'],
          'source': 'kw',
        });
      }
    }
    return list;
  }
}
