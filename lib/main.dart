import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import './component/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait<void>([
    FlutterConfig.loadEnvVariables(),
    () async {
      await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      if(kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }
    }()
  ]);
  runApp(Application());
}
