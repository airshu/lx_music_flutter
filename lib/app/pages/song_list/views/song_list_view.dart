import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/search/views/search_view.dart';
import 'package:lx_music_flutter/app/respository/kw/kw_song_list.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/overlay_dragger.dart';

class SongListView extends StatelessWidget {
  const SongListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('SongListView122'),
          ElevatedButton(onPressed: () async {
            // Get.to(SearchView());

            // await KWSongList.getToken();
            await KWSongList.getSearch('爱', 1, 20);

          }, child: Text('搜索11111')),
        ],
      ),
    );
  }
}
