import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/kw/kw_leader_board.dart';
import 'package:lx_music_flutter/app/pages/leader_board/controllers/leader_board_controller.dart';
import 'package:lx_music_flutter/app/respository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';

class LeaderBoardWidget extends BaseStatefulWidget {
  const LeaderBoardWidget({super.key, required super.title});

  @override
  State<LeaderBoardWidget> createState() => _LeaderBoardWidgetState();
}

class _LeaderBoardWidgetState extends State<LeaderBoardWidget> {
  late LeaderBoardController controller;

  @override
  void initState() {
    controller = Get.put(LeaderBoardController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<LeaderBoardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildButton(),
        Expanded(child: buildBody()),
      ],
    );
  }

  _buildButton() {
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
      value: controller.currentPlatform.value,
      items: children,
      onChanged: (value) {
        controller.changePlatform(value.toString());
      },
    );
  }

  Widget buildBody() {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Obx(
              () => ListView.builder(
                itemBuilder: (context, index) {
                  return buildItem(index);
                },
                itemCount: controller.boardList.length,
              ),
            )),
        Expanded(
          flex: 3,
          child: Obx(
            () => ListView.builder(
              itemBuilder: (context, index) {
                return buildRightItem(index);
              },
              itemCount: controller.songList.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildItem(int index) {
    Board board = controller.boardList.elementAt(index);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.openBoard(board);
      },
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(board.name),
      ),
    );
  }

  Widget buildRightItem(int index) {
    if (controller.songList.length <= index) return Container();
    final item = controller.songList.elementAt(index);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        String songmid = item['songmid'];
        for (var t in item['types']) {
          var result = await KWSongList.getMusicUrlDirect(songmid, t['type']);
          if (result['url'] != null && result['url'].isNotEmpty) {
            MusicItem songItem = MusicItem(
              id: item['songmid'],
              songName: item['name'],
              artist: item['singer'],
              album: item['albumName'],
              hash: '',
              artistid: item['songmid'],
              length: 0,
              size: 0,
              url: result['url'],
            );
            MusicPlayer().add(songItem);
            print('$songmid  ${t['type']}=======>>>>>>result=$result');
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
}
