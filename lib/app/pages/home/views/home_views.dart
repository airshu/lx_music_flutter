import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/kw/main/kw_view.dart';
import 'package:lx_music_flutter/app/pages/profile/views/profile_view.dart';
import 'package:lx_music_flutter/app/pages/song_list/views/song_list_view.dart';

import '../../setting/views/setting_view.dart';
import '../controllers/home_controller.dart';

class HomeViews extends StatefulWidget {
  HomeViews({super.key});

  @override
  State<HomeViews> createState() => _HomeViewsState();
}

class _HomeViewsState extends State<HomeViews> {
  Map<int, Widget> pages = {};

  late HomeController controller;

  @override
  void initState() {
    controller = Get.put(HomeController());
    super.initState();
  }

  Widget getPage(int index) {
    if (pages[index] != null) {
      return pages[index]!;
    }
    switch (index) {
      case 0:
        pages[index] ??= const SongListView();
        break;
      case 1:
        pages[index] ??= const KWView();
        break;
      case 2:
        pages[index] ??= const ProfileView();
        break;
      case 3:
        pages[index] ??= const Text('333');
        break;
    }
    return pages[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => getPage(controller.currentIndex.value),
      ),
      drawer: getDrawer(),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (value) {
            controller.currentIndex.value = value;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '主页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.queue_music),
              label: '音乐榜',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  Widget getDrawer() {
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
            title: const Text('Search'),
            onTap: () {
              Get.to(() => ProfileView());
            },
          ),
          ListTile(
            title: const Text('Song List'),
            onTap: () {
              Get.to(() => ProfileView());
            },
          ),
          ListTile(
            title: const Text('Setting'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Get.to(() => SettingView());
            },
          ),
        ],
      ));
    });
  }
}
