import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';

import 'base/controll_buttons.dart';
import 'base/seek_bar.dart';

/// 播放器页面 包括播放列表
class MusicPlayerView extends StatefulWidget {
  const MusicPlayerView({super.key});

  @override
  State<MusicPlayerView> createState() => _MusicPlayerViewState();
}

class _MusicPlayerViewState extends State<MusicPlayerView> {

  @override
  void initState() {
    super.initState();
    MusicPlayerService.instance.hide();
  }

  @override
  void dispose() {
    super.dispose();
    MusicPlayerService.instance.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildCoverWidget(),
            const ControllButtons(iconSize: 64),
            StreamBuilder<PositionData>(
              stream: MusicPlayer().positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: MusicPlayer().player.seek,
                );
              },
            ),
            buildPlaylistWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildCoverWidget() {
    return Container(
      height: 100,
      color: Colors.red,
    );
  }

  Widget buildPlaylistWidget() {
    return SizedBox(
      height: 240.0,
      child: StreamBuilder<SequenceState?>(
        stream: MusicPlayer().player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];
          return ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) newIndex--;
              MusicPlayer().playList.move(oldIndex, newIndex);
            },
            children: [
              for (var i = 0; i < sequence.length; i++)
                Dismissible(
                  key: ValueKey(sequence[i]),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (dismissDirection) {
                    MusicPlayer().playList.removeAt(i);
                  },
                  child: Material(
                    color: i == state!.currentIndex ? Colors.grey.shade300 : null,
                    child: ListTile(
                      title: Text('${sequence[i].tag?.title}  ${sequence[i].toString()}'),
                      onTap: () {
                        MusicPlayer().player.seek(Duration.zero, index: i);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
