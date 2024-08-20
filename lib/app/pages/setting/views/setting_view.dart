import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';
import 'package:lx_music_flutter/app/pages/setting/controllers/setting_controller.dart';
import 'package:lx_music_flutter/app/pages/setting/settings.dart';

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
            ElevatedButton(
                onPressed: () {
                  test();
                },
                child: const Text('清除缓存')),
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
        Widget buildRadio(String label, String source) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                Settings().musicSource = source;
              });
            },
            child: Container(
              child: Row(
                children: [
                  Radio(
                    value: source,
                    groupValue: Settings().musicSource,
                    onChanged: (value) {
                      setState(() {
                        Settings().musicSource = source;
                      });
                    },
                  ),
                  Text(label),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            buildRadio('测试接口', MusicSource.httpSourceTest),
            buildRadio('临时接口', MusicSource.httpSourceTemp),
            buildRadio('试听接口（这是最后的选择）', MusicSource.httpSourceDirect),
          ],
        );
      },
    );
  }

  void test() async {
    try {
      String ajvJS = await rootBundle.loadString("assets/sixyin-music-source-v1.0.7.js");
      final JavascriptRuntime javascriptRuntime = getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);
      var result = javascriptRuntime.evaluate(ajvJS + "");

      print('===>>>$result');
    } catch(e, s) {
      print('====>>> $e  $s');
    }

  }
}
