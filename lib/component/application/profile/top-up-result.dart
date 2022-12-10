import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../asset/graphic/illustration/success.dart';
import '../../../asset/graphic/illustration/fail.dart';
import '../../common/stripe.dart';
import '../../common/button.dart';
import '../../main.dart';

class TopUpResultPage extends StatefulWidget {
  final bool success;
  TopUpResultPage({
    required this.success
  }) {
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
  State<StatefulWidget> createState() => _TopUpResultPageState();
}
class _TopUpResultPageState extends State<TopUpResultPage> with StoreWatcherMixin<TopUpResultPage> {
  final double topHeight = 0;
  final double bottomHeight = 0;
  
  goBack(BuildContext context) {
    Navigator.pop(context, NavigationPopResult(
      toPath: ['profile', 'show-retrievable'],
      refresh: true
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      height: [width - 96, 144.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:24),
                      child: widget.success
                        ? SuccessIllustration(
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        : FailIllustration(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      padding: EdgeInsets.only(bottom:16),
                      child: Text(
                        widget.success
                          ? 'Your top up request is successful'
                          : 'Your top up request failed',
                        style: Theme.of(context).textTheme.headline5
                      )
                    ),
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      height: 40.0,
                      padding: EdgeInsets.only(bottom:8),
                      child: Stripes(
                        color: widget.success
                          ? Theme.of(context).colorScheme.primaryVariant
                          : Theme.of(context).colorScheme.error,
                      )
                    ),
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.onBackground,
                            width: 2
                          )
                        )
                      ),
                      padding: EdgeInsets.only(bottom:16),
                      child: Text(
                        widget.success
                          ? '200 SUCCESS'
                          : '500 ERROR',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 12
                        )
                      )
                    ),
                    Container(
                      width: [width - 48, 192.0].reduce(math.min),
                      child: Button(
                        onTap: () => this.goBack(context),
                        label: 'GO BACK'
                      )
                    )
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
