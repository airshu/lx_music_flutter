import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/pages/kw/song_list/kw_list_view.dart';
import 'package:lx_music_flutter/app/respository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/utils/toast_util.dart';

import 'kw_controller.dart';

class KWView extends BaseStatefulWidget {
  const KWView({super.key, required super.title});

  @override
  State<KWView> createState() => _KWViewState();
}

class _KWViewState extends State<KWView> {
  late KWController kwController;

  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    kwController = Get.put(KWController());

    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    kwController.search();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(AppConst.navigatorKeyKW),
      onGenerateRoute: (settings) {
        print('====>>>>$settings');
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return buildBody();
          },
        );
      },
    );
  }

  Widget buildBody() {
    Widget buildItem(int index) {
      Board board = KWLeaderBoard.boardList.elementAt(index);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          kwController.openBoard(board);
        },
        child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Text(board.name),
        ),
      );
    }

    Widget buildRightItem(int index) {
      if (kwController.songList.length <= index) return Container();
      final item = kwController.songList.elementAt(index);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          String songmid = item['songmid'];
          for(var t in item['types']) {
            var result = await KWSongList.getMusicUrlDirect(songmid, t['type']);
            if(result['url'] != null && result['url'].isNotEmpty) {
              print('$songmid  ${t['type']}=======>>>>>>result=$result');
              item.url = result['url'];
            }
            return;
          }
        },
        child: Container(
          height: 26,
          child: Row(
            children: [
              Expanded(child: Text('${item['name']}', overflow: TextOverflow.ellipsis,)),
              // Text('${item['singer']}'),
              // Text('${item['albumName']}'),
              Text('${item['interval']}'),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
            flex: 1,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return buildItem(index);
              },
              itemCount: KWLeaderBoard.boardList.length,
            )),
        Expanded(
          flex: 3,
          child: Obx(
            () => ListView.builder(
              itemBuilder: (context, index) {
                return buildRightItem(index);
              },
              itemCount: kwController.songList.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildListWidget() {
    return Obx(
      () => EasyRefresh(
        controller: easyRefreshController,
        header: const ClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () async {
          if (kwController.keyword.isEmpty) {
            ToastUtil.show('请输入关键字');
            return;
          }
          if (!mounted) {
            return;
          }

          kwController.page = 0;
          kwController.search();

          easyRefreshController.finishRefresh();
          easyRefreshController.resetFooter();
        },
        onLoad: () async {
          if (kwController.keyword.isEmpty) {
            ToastUtil.show('请输入关键字');
            return;
          }
          if (!mounted) {
            return;
          }
          kwController.page++;
          await kwController.search();
          easyRefreshController.finishLoad(kwController.songList.length % kwController.pageSize >= kwController.pageSize
              ? IndicatorResult.noMore
              : IndicatorResult.success);
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            // MusicItem item = kwController.songList.elementAt(index);
            // return buildItem(item);
            var item = kwController.songList.elementAt(index);
            print('=====>>>>>>>>$item');
            // return Text('${item['name']}');
            return buildItem(item);
          },
          itemCount: kwController.songList.length,
        ),
      ),
    );
  }

  Widget buildItem(Map item) {
    return GestureDetector(
      onTap: () async {
        Get.to(KWListView(playlistid: item['playlistid']), id: AppConst.navigatorKeyKW);
      },
      child: Container(
        child: Row(
          children: [
            Image.network(
              item['pic'],
              cacheWidth: 100,
            ),
            Expanded(
              child: Text(
                "${item['name']}".replaceAll("&nbsp;", " "),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
