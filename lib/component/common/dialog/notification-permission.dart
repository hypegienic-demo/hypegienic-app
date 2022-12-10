import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/authentication.dart';
import '../button.dart';
import './simple.dart';

Future<AuthorizationStatus?> showNotificationPermissionDialog({
  Key? key,
  required BuildContext context
}) =>
  showSimpleDialog<AuthorizationStatus>(
    key: key,
    context: context,
    child: _NotificationPermissionDialog()
  );

class _NotificationPermissionDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationPermissionDialogState();
}
class _NotificationPermissionDialogState extends State<_NotificationPermissionDialog> with StoreWatcherMixin<_NotificationPermissionDialog> {
  late AuthenticationStore authenticationStore;

  @override
  void initState() {
    super.initState();
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
  }

  requestNotificationPermission(BuildContext context) async {
    final notificationSettings = await FirebaseMessaging.instance.requestPermission();
    final permission = notificationSettings.authorizationStatus;
    if([AuthorizationStatus.authorized, AuthorizationStatus.provisional].contains(permission)) {
      final token = await FirebaseMessaging.instance.getToken();
      if(token != null) {
        this.authenticationStore.addUserDevice(token);
      }
    }
    Navigator.pop(context, permission);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom:8),
          child: Text(
            'Enable push notification?',
            style: Theme.of(context).textTheme.headline4
          )
        ),
        Padding(
          padding: EdgeInsets.only(bottom:24),
          child: Text(
            'With push notification, hy{pe}gienic will be able to notify you for any progress made with the cleaning of your shoes.',
            style: Theme.of(context).textTheme.bodyText1
          )
        ),
        Button(
          onTap: () => this.requestNotificationPermission(context),
          label: 'CONTINUE'
        )
      ]
    );
  }
}