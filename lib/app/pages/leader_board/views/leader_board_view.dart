import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/app_const.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/leader_board/controllers/leader_board_controller.dart';
import 'package:lx_music_flutter/app/repository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/models/leader_board_model.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
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
              itemCount: controller.leaderBoardModel.value.list.length,
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
    if (controller.leaderBoardModel.value.list.length <= index) return Container();
    LeaderBoardItem item = controller.leaderBoardModel.value.list.elementAt(index);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        String source = item.source;
        MusicPlayerService.instance.play(source, MusicItem.fromLeaderBoardItem(item));
      },
      child: Container(
        height: 26,
        child: Row(
          children: [
            Expanded(
                child: Text(
              '${item.name}',
              overflow: TextOverflow.ellipsis,
            )),
            // Text('${item['singer']}'),
            // Text('${item['albumName']}'),
            Text('${item.interval}'),
          ],
        ),
      ),
    );
  }
}
