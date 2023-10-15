import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lx_music_flutter/app/app.dart';
import 'package:lx_music_flutter/utils/log/logger.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const App());
    },
    runZonedGuardedOnError,
    zoneSpecification: null,
  );
}

void runZonedGuardedOnError(Object exception, StackTrace stackTrace) {
  Logger.error('>>>>>>>>>>$exception    $stackTrace');
}
