import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/pages/search/views/search_view.dart';
import 'package:lx_music_flutter/app/pages/song_list/controllers/song_list_controller.dart';
import 'package:lx_music_flutter/app/respository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/overlay_dragger.dart';

/// 歌单主页
class SongListView extends BaseStatefulWidget {
  const SongListView({super.key, required super.title});

  @override
  State<SongListView> createState() => _SongListState();
}

class _SongListState extends State<SongListView> {
  late SongListController songListController;

  late EasyRefreshController easyRefreshController;

  @override
  void initState() {
    songListController = Get.put(SongListController());

    easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

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
          songListController.openBoard(board);
        },
        child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Text(board.name),
        ),
      );
    }

    Widget buildRightItem(int index) {
      if (songListController.songList.length <= index) return Container();
      final item = songListController.songList.elementAt(index);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          String songmid = item['songmid'];
          for (var t in item['types']) {
            var result = await KWSongList.getMusicUrlDirect(songmid, t['type']);
            if (result['url'] != null && result['url'].isNotEmpty) {
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
              Expanded(
                  child: Text(
                '${item['name']}',
                overflow: TextOverflow.ellipsis,
              )),
              // Text('${item['singer']}'),
              // Text('${item['albumName']}'),
              Text('${item['interval']}'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: buildDrawer(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(child: buildTopLeftBottons(), scrollDirection: Axis.horizontal),
              ),
              Builder(builder: (ctx) {
                return Container(
                  child: ElevatedButton(
                      onPressed: () {
                        Scaffold.of(ctx).openDrawer();
                      },
                      child: Text('默认')),
                  margin: EdgeInsets.only(left: 12, right: 12),
                );
              }),
              buildTopRightButton(),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          Expanded(
            flex: 3,
            child: Obx(
              () => ListView.builder(
                itemBuilder: (context, index) {
                  return buildRightItem(index);
                },
                itemCount: songListController.songList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopLeftBottons() {
    return Obx(
      () {
        List<Widget> children = [];
        songListController.sortList.forEach((element) {
          children.add(Text(element.name));
        });
        return ToggleButtons(
          isSelected: songListController.sortList.map((element) => element.isSelect).toList(),
          children: children,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < songListController.sortList.length; i++) {
                if (i == index) {
                  songListController.sortList[i].isSelect = true;
                } else {
                  songListController.sortList[i].isSelect = false;
                }
              }
            });
          },
        );
      },
    );
  }

  Widget buildTopRightButton() {
    List<DropdownMenuItem> children = [];
    AppConst.platformNames.forEach((element) {
      children.add(
        DropdownMenuItem(
          child: Text(element),
          value: element,
        ),
      );
    });
    return DropdownButton(
      value: songListController.currentPlatform.value,
      items: children,
      onChanged: (value) {
        songListController.changePlatform(value.toString());
      },
    );
  }

  Widget buildDrawer() {
    List<Widget> children = [];
    for (var element in songListController.tagList.value) {
      if(element['list'] == null || element['list'].isEmpty) {
        continue;
      }

      children.add(Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            element['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          )));

      List<Widget> tags = [];
      if (element['list'] != null) {
        element['list'].forEach((item) {
          tags.add(
            GestureDetector(
              onTap: (){
                songListController.openTag(item);
              },
              child: Container(
                color: Colors.grey[200],
                // margin: EdgeInsets.only(left: 4, right: 0, top: 4, bottom: 4),
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Text(item['name']),
              ),
            ),
          );
        });
        children.add(Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: tags,
          ),
        ));
      }
    }
    children.add(const SizedBox(height: 10,));
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
