import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lx_music_flutter/app/pages/base/base_ui.dart';

import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends BaseStatefulWidget {
  const ProfileView({super.key, required super.title});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// class ProfileView extends GetView<ProfileController> {
//   const ProfileView({super.key, required this.title});
//
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'ProfileView is working',
//               style: TextStyle(fontSize: 20),
//             ),
//             const Hero(
//               tag: 'heroLogo',
//               child: FlutterLogo(),
//             ),
//             MaterialButton(
//               child: const Text('Show a test dialog'),
//               onPressed: () {
//                 //shows a dialog
//                 Get.defaultDialog(
//                   title: 'Test Dialog !!',
//                   barrierDismissible: true,
//                 );
//               },
//             ),
//             MaterialButton(
//               child: const Text('Show a test dialog in Home router outlet'),
//               onPressed: () {
//                 Get.defaultDialog(
//                   title: 'Test Dialog In Home Outlet !!',
//                   barrierDismissible: true,
//                   // id: Routes.home,
//                   // navigatorKey: Get.nestedKey(Routes.HOME),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
