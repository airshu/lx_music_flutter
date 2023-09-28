import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/setting/controllers/setting_controller.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';
import 'package:lx_music_flutter/app/pages/song_list/views/song_list_view.dart';

import '../../../app_const.dart';

class SettingView extends BaseStatefulWidget {
  SettingView({super.key, required super.title});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  late SettingController controller;

  @override
  void initState() {
    controller = Get.put(SettingController());
    super.initState();
  }

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
            // Text('SettingView'),
            // ElevatedButton(
            //   onPressed: () async {
            //     // Get.global(AppConst.navigatorKeySetting).currentState.push(route);
            //     Get.to(() => SongListView(), id: AppConst.navigatorKeySetting);
            //     // Get.to(() => ProfileView());
            //     // Get.keys[AppConst.navigatorKeySetting.toString()]?.to(() => ProfileView());
            //     // var xx = await Get.nestedKey(AppConst.navigatorKeySetting.toString())?.to(() => ProfileView());
            //     // print('======  ${Get.nestedKey(AppConst.navigatorKeySetting.toString())}   >>  $xx');
            //   },
            //   child: Text('nested navigator'),
            // ),
            buildBaseSettingWidget(),
            buildSourceWidget(),
            ElevatedButton(onPressed: () {}, child: const Text('清除缓存')),
          ],
        ),
      ),
    );
  }

  Widget buildBaseSettingWidget() {
    return Column(
      children: [
        Row(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Checkbox(
                  value: Settings().startupAutoPlay,
                  onChanged: (value) {
                    Settings().startupAutoPlay = value!;
                  },
                );
              },
            ),
            const Text('启动后自动播放音乐'),
          ],
        ),
      ],
    );
  }

  Widget buildSourceWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Radio(
              value: '测试接口',
              groupValue: Settings().musicSource,
              onChanged: (value) {
                setState(() {
                  Settings().musicSource = MusicSource.sourceTest;
                });
              },
            ),
            Radio(
              value: '临时接口',
              groupValue: Settings().musicSource,
              onChanged: (value) {
                setState(() {
                  Settings().musicSource = MusicSource.sourceTemp;
                });
              },
            ),
            Radio(
              value: '试听接口（这是最后的选择）',
              groupValue: Settings().musicSource,
              onChanged: (value) {
                setState(() {
                  Settings().musicSource = MusicSource.sourceDirect;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
