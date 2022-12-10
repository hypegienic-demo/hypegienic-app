import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../button.dart';
import './simple.dart';

Future<TrackingStatus?> showAppTrackingPermissionDialog({
  Key? key,
  required BuildContext context
}) =>
  showSimpleDialog<TrackingStatus>(
    key: key,
    context: context,
    child: _AppTrackingPermissionDialog()
  );

class _AppTrackingPermissionDialog extends StatelessWidget {
  requestAppTrackingPermission(BuildContext context) async {
    final permission = await AppTrackingTransparency.requestTrackingAuthorization();
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
            'Enable app tracking permission?',
            style: Theme.of(context).textTheme.headline4
          )
        ),
        Padding(
          padding: EdgeInsets.only(bottom:24),
          child: Text(
            'Only with sharing your information with our physical store, hy{pe}gienic will be able to register the ownership of the items sent to us for cleaning.',
            style: Theme.of(context).textTheme.bodyText1
          )
        ),
        Button(
          onTap: () => this.requestAppTrackingPermission(context),
          label: 'CONTINUE'
        )
      ]
    );
  }
}