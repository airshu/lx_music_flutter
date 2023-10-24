import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/leader_board/views/leader_board_view.dart';
import 'package:lx_music_flutter/app/pages/search/controllers/search_song_controller.dart';
import 'package:lx_music_flutter/app/pages/search/views/search_view.dart';
import 'package:lx_music_flutter/app/pages/song_list/views/song_list_view.dart';

import '../../setting/views/setting_view.dart';
import '../controllers/home_controller.dart';

class HomeViews extends StatefulWidget {
  HomeViews({super.key});

  @override
  State<HomeViews> createState() => _HomeViewsState();
}

class _HomeViewsState extends State<HomeViews> {
  Map<int, BaseStatefulWidget> pages = {};

  late HomeController controller;

  @override
  void initState() {
    controller = Get.put(HomeController());
    super.initState();
  }

  BaseStatefulWidget getPage(int index) {
    if (pages[index] != null) {
      return pages[index]!;
    }
    switch (index) {
      case 0:
        pages[index] ??= SearchViewWidget(title: '搜索'.tr);
        break;
      case 1:
        pages[index] ??= SongListView(title: '歌单'.tr);
        break;
      case 2:
        pages[index] ??= LeaderBoardWidget(title: '排行榜'.tr);
        break;
      case 3:
        pages[index] ??= SettingView(title: '设置'.tr);
        break;
    }
    return pages[index]!;
  }

  List<Widget>? buildActions() {
    return [
      Obx(() {
        if (controller.currentIndex.value == 0) {
          return ElevatedButton(
            child: Text(
              '歌曲',
              style: TextStyle(
                  color: Get.find<SearchSongController>().searchType.value == SearchSongController.searchTypeSong ? Colors.black : null),
            ),
            onPressed: () {
              Get.find<SearchSongController>().searchType.value = SearchSongController.searchTypeSong;
            },
          );
        }
        return Container();
      }),
      Obx(() {
        if (controller.currentIndex.value == 0) {
          return ElevatedButton(
            child: Text(
              '歌单',
              style: TextStyle(
                color: Get.find<SearchSongController>().searchType.value == SearchSongController.searchTypeList ? Colors.black : null,
              ),
            ),
            onPressed: () {
              Get.find<SearchSongController>().searchType.value = SearchSongController.searchTypeList;
            },
          );
        }
        return Container();
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(getPage(controller.currentIndex.value).title)),
        actions: buildActions(),
      ),
      body: Obx(
        () => getPage(controller.currentIndex.value),
      ),
      drawer: buildDrawer(),
      // bottomNavigationBar: Obx(
      //   () => BottomNavigationBar(
      //     currentIndex: controller.currentIndex.value,
      //     onTap: (value) {
      //       controller.currentIndex.value = value;
      //     },
      //     items: const [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home),
      //         label: '主页',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.queue_music),
      //         label: '音乐榜',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.people),
      //         label: '我的',
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget buildDrawer() {
    return Builder(builder: (context) {
      return Drawer(
          child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Lx Music'),
          ),
          ListTile(
            title: Text('搜索'.tr),
            onTap: () {
              controller.currentIndex.value = 0;
              // Get.to(() => ProfileView());
              Scaffold.of(context).closeDrawer();
            },
          ),
          ListTile(
            title: Text('歌单'.tr),
            onTap: () {
              controller.currentIndex.value = 1;
              // Get.to(() => ProfileView());
              Scaffold.of(context).closeDrawer();
            },
          ),
          ListTile(
            title: Text('排行榜'.tr),
            onTap: () {
              controller.currentIndex.value = 2;
              Scaffold.of(context).closeDrawer();
              // Get.to(() => ProfileView());
            },
          ),
          ListTile(
            title: Text('设置'.tr),
            onTap: () {
              controller.currentIndex.value = 3;
              Scaffold.of(context).closeDrawer();
              // Get.to(() => SettingView());
            },
          ),
        ],
      ));
    });
  }
}
