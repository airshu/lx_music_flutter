

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lx_music_flutter/utils/player/music_player.dart';

class ControllButtons extends StatelessWidget {
  const ControllButtons({super.key, required this.iconSize, });

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final player = MusicPlayer().player;
    return Row(
      children: [
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: iconSize,
                  height: iconSize,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: iconSize,
                  onPressed: () async {
                    await player.play();
                  },
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: iconSize,
                  onPressed: () async {
                    await player.pause();
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 64.0,
                  onPressed: () async {
                    await player.seek(Duration.zero, index: MusicPlayer().player.effectiveIndices!.first);
                  },
                );
              }
            }),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
              onPressed: () {
                player.hasNext ? player.seekToNext() : null;
              },
              icon: const Icon(Icons.skip_next_outlined)),
        )
      ],
    );
  }
}