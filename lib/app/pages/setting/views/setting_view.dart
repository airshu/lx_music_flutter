import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/song_list/views/song_list_view.dart';

import '../../../app_const.dart';

class SettingView extends StatelessWidget {
  SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(AppConst.navigatorKeySetting),
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
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('SettingView'),
            ElevatedButton(
                onPressed: () async {
                  // Get.global(AppConst.navigatorKeySetting).currentState.push(route);
                  Get.to(() => SongListView(), id: AppConst.navigatorKeySetting);
                  // Get.to(() => ProfileView());
                  // Get.keys[AppConst.navigatorKeySetting.toString()]?.to(() => ProfileView());
                  // var xx = await Get.nestedKey(AppConst.navigatorKeySetting.toString())?.to(() => ProfileView());
                  // print('======  ${Get.nestedKey(AppConst.navigatorKeySetting.toString())}   >>  $xx');
                },
                child: Text('nested navigator')),
          ],
        ),
      ),
    );
  }
}
