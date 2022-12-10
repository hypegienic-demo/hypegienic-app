import 'dart:io';

import 'package:device_info/device_info.dart';

Future<String?> getDeviceUID() async {
  try {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      final android = await deviceInfoPlugin.androidInfo;
      return android.androidId;
    } else if(Platform.isIOS) {
      final ios = await deviceInfoPlugin.iosInfo;
      return ios.identifierForVendor;
    }
    return null;
  } catch(error) {
    return null;
  }
}