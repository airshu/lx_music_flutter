import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/search/views/search_view.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';
import 'package:lx_music_flutter/utils/overlay_dragger.dart';

class SongListView extends StatelessWidget {
  const SongListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('SongListView'),
          ElevatedButton(onPressed: (){
            Get.to(SearchView());
          }, child: Text('搜索')),
        ],
      ),
    );
  }
}
