import 'dart:ffi';

import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/repository/kg/kg_song_list.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/app/repository/mg/mg_song_list.dart';
import 'package:lx_music_flutter/app/repository/song_repository.dart';
import 'package:lx_music_flutter/app/repository/tx/tx_song_list.dart';
import 'package:lx_music_flutter/app/repository/wy/wy_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/song_list.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

class SongListController extends GetxController {
  int page = 1;

  int pageSize = 10;

  String keyword = '爱';

  /// 当前选中的平台
  final currentPlatform = ''.obs;
  /// 选中的标签
  final currentTag = {}.obs;

  /// {
  /// 'tags': [],
  /// 'hotTags': [],
  /// 'source': '',
  /// }
  final tagList = {}.obs;
  final sortList = <SortItem>[].obs;

  final musicListModel = MusicListModel.empty().obs;

  @override
  void onInit() {
    changePlatform(AppConst.nameKW);
    sortList.value = KWSongList.sortList;
    super.onInit();

    // Future.delayed(const Duration(microseconds: 100), () {
    //   KWSongList.getSearch(keyword, page, pageSize);
    // });
  }

  Future<void> search() async {
    try {
      // List list = await KWSongList.search(keyword, page, pageSize);
      // songList.addAll(list);
    } catch (e, s) {
      Logger.error('$e $s');
    }
  }

  void openBoard(Board board) async {
    var result = await KWLeaderBoard.getList(board.bangid, page);
    Logger.debug('$result');
    // songList.value = result['list'];
  }

  Future<void> changePlatform(String name) async {
    Logger.debug('changePlatform  $name');
    currentPlatform.value = name;
    sortList.value = AppConst.sortListMap[name]!;
    musicListModel.value.reset();

    var res = await SongRepository.getTags(AppConst.sourceMap[name]!);
    for(var item in res['hotTags']) {
      Logger.debug('hotTags  $item');
    }
    for(var item in res['tags']) {
      Logger.debug(item['name']);
      for(var e in item['list']) {
        Logger.debug('e  $e');
      }
    }
    // print('res   $res' );
    tagList.value = res;
    openTag(res['hotTags'][0]);
  }

  /// 选择某个标签
  Future<void> openTag(item) async {
    String sortId = sortList.where((item) => item.isSelect).first.id;
    String tagId = item['id'].toString();
    MusicListModel? model = await SongRepository.getList(AppConst.sourceMap[currentPlatform.value]!, sortId.toString(), tagId, page);

    musicListModel.value.list.addAll(model?.list ?? []);
    musicListModel.value.limit = model?.limit ?? 0;
    musicListModel.value.total = model?.total ?? 0;
    musicListModel.value.source = model?.source ?? '';
    musicListModel.value.page = model?.page;
    musicListModel.refresh();
    currentTag.value = item;
    Logger.debug('openTag========${musicListModel.value.list.length}  ${musicListModel.value.limit}  ${musicListModel.value.total}  ${musicListModel.value.source}  ${musicListModel.value.page}');
  }

  Future<void> onRefresh() async {
    await openTag(currentTag.value);
  }

  Future onLoad() async {
    await openTag(currentTag.value);
  }
  
  
}
