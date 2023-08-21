import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/splash/controllers/splash_service.dart';
import 'package:lx_music_flutter/app/pages/splash/views/splash_view.dart';
import 'package:lx_music_flutter/app/routes/app_pages.dart';
import 'package:lx_music_flutter/services/app_service.dart';
import 'package:lx_music_flutter/services/music_player_service.dart';



class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return app();
  }


  Widget app() {
    return GetMaterialApp(
      title: "落雪音乐",
      routingCallback: (value) {
        print('routingCallback $value');
      },

      navigatorObservers: [],
      initialBinding: BindingsBuilder(() {
        Get.put(AppService());
        Get.put(MusicPlayerService());
        Get.put(SplashService());
      }),
      // binds: [
      //   Bind.put(SplashService()),
      //   Bind.put(AuthService()),
      // ],
      home: const SplashView(),
      // getPages: AppPages.routes,
      // initialRoute: AppPages.initial,
      // builder: (context, child) {
      //   print('====>>>>>$child');
      //   return child ?? Text('123');
      //   return FutureBuilder<void>(
      //     key: ValueKey('initFuture'),
      //     future: Get.find<SplashService>().init(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         return child ?? SizedBox.shrink();
      //       }
      //       return SplashView();
      //     },
      //   );
      // },
      // routeInformationParser: GetInformationParser(
      //     // initialRoute: Routes.HOME,
      //     ),
      // routerDelegate: GetDelegate(
      //   backButtonPopMode: PopMode.History,
      //   preventDuplicateHandlingMode:
      //       PreventDuplicateHandlingMode.ReorderRoutes,
      // ),
    );
  }

}

