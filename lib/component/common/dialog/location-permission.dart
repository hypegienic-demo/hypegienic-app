import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../button.dart';
import './simple.dart';

Future<LocationPermission?> showLocationPermissionDialog({
  Key? key,
  required BuildContext context
}) =>
  showSimpleDialog<LocationPermission>(
    key: key,
    context: context,
    child: _LocationPermissionDialog()
  );

class _LocationPermissionDialog extends StatelessWidget {
  requestLocationPermission(BuildContext context) async {
    final permission = await Geolocator.requestPermission();
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
            'Enable location permission?',
            style: Theme.of(context).textTheme.headline4
          )
        ),
        Padding(
          padding: EdgeInsets.only(bottom:24),
          child: Text(
            'Only with your location permission turned on, hy{pe}gienic will be able to display the nearest lockers and allow you to interact with them.',
            style: Theme.of(context).textTheme.bodyText1
          )
        ),
        Button(
          onTap: () => this.requestLocationPermission(context),
          label: 'CONTINUE'
        )
      ]
    );
  }
}