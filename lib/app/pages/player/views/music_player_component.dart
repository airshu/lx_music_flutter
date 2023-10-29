import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lx_music_flutter/app/pages/player/views/base/controll_buttons.dart';
import 'package:lx_music_flutter/app/pages/player/views/music_player_view.dart';
import 'package:lx_music_flutter/app/pages/player/views/base/seek_bar.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/models/music_item.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';

import '../controllers/music_player_controller.dart';

/// 播放器小组件
class MusicPlayerComponent extends StatefulWidget {
  const MusicPlayerComponent({
    super.key,
    this.musicItem,
  });

  final MusicItem? musicItem;

  @override
  State<MusicPlayerComponent> createState() => _MusicPlayerComponentState();
}

class _MusicPlayerComponentState extends State<MusicPlayerComponent> {
  late MusicPlayerController controller;

  @override
  void initState() {
    controller = Get.put(MusicPlayerController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.blue.withAlpha(10),
        child: Row(
          children: [

            IconButton(onPressed: (){
              Get.to(MusicPlayerView());
            }, icon: Icon(Icons.playlist_add_check), iconSize: 30),


            // buildCoverWidget(),
            // StreamBuilder<PositionData>(
            //   stream: MusicPlayer().positionDataStream,
            //   builder: (context, snapshot) {
            //     final positionData = snapshot.data;
            //     return SeekBar(
            //       duration: positionData?.duration ?? Duration.zero,
            //       position: positionData?.position ?? Duration.zero,
            //       bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
            //       onChangeEnd: MusicPlayer().player.seek,
            //     );
            //   },
            // ),
            const ControllButtons(iconSize: 30,),
          ],
        ),
      ),
    );
  }


}

