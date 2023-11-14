


import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_list.dart';
// import 'package:lx_music_flutter/app/repository/wy/song_list.dart';

void main() {
  testWidgets('description', (_) async {

    // WYSongList.getTag();

    // String key = '7923066785499273';
    // print('key===$key');
    // var x = utf8.encode(key);
    // print('===$x');
    // List list = x.reversed.toList();
    // print('=====$list');
    // Uint8List.

    // var res = await WYSongList.getList('hot', '全部', 1);
    // print('=====$res');

    var headers = {
      'user-agent': 'xxx',
    };
    headers.addAll({'user-agent': ''});
    print('====$headers');

  });
}