import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../common/button.dart';
import '../../main.dart';

class OrderDonePage extends StatefulWidget {
  OrderDonePage() {
    this.setBarStyle();
  }
  setBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark
    ));
  }

  @override
  State<StatefulWidget> createState() => _OrderDonePageState();
}
class _OrderDonePageState extends State<OrderDonePage> with StoreWatcherMixin<OrderDonePage> {
  final double topHeight = 0;
  final double bottomHeight = 0;
  
  goBack(BuildContext context) {
    Navigator.pop(context, NavigationPopResult(
      toPath: ['map']
    ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;
    
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) + EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: new BoxConstraints(
                  minWidth: width,
                  minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical:16, horizontal:24),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical:8),
                            child: Text(
                              'Thank you for using hy{pe}gienic',
                              style: Theme.of(context).textTheme.headline3
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical:8),
                            child: Text(
                              'Have a great day and we hope you enjoyed our service',
                              style: Theme.of(context).textTheme.headline6
                            )
                          )
                        ]
                      )
                    ),
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      child: Button(
                        onTap: () => this.goBack(context),
                        label: 'GO BACK'
                      )
                    ),
                  ]
                )
              )
            ),
            Positioned(
              top: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: top + topHeight,
                width: width,
                padding: EdgeInsets.only(top:top)
              )
            ),
            Positioned(
              width: width,
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: bottom + bottomHeight,
                padding: EdgeInsets.only(bottom:bottom)
              )
            )
          ]
        )
      ),
    );
  }
}
