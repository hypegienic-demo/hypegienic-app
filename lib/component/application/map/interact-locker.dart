import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../asset/graphic/icon/back.dart';
import '../../../asset/graphic/illustration/place-order.dart';
import '../../../asset/graphic/illustration/retrieve-order.dart';
import '../../common/button.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/inline-error.dart';
import '../../main.dart';
import 'place-main-order.dart';
import './show-retrievable.dart';

class InteractLockerPage extends StatefulWidget {
  final String lockerId;

  InteractLockerPage({
    required this.lockerId
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
  State<StatefulWidget> createState() => _InteractLockerPageState();
}
class _InteractLockerPageState extends State<InteractLockerPage> with StoreWatcherMixin<InteractLockerPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  String? selected;
  String? error;

  setSelected(String selected) {
    setState(() => this.selected = selected);
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('interact-locker')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }
  confirm(BuildContext context) {
    if(this.selected == 'place-order') {
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => PlaceMainOrderPage(
          lockerId: widget.lockerId
        )
      ));
    } else if(this.selected == 'retrieve-order') {
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => ShowRetrievablePage(
          lockerId: widget.lockerId,
        )
      ));
    } else {
      setError('Please select an option first');
    }
  }
  goBack(BuildContext context) {
    Navigator.pop(context);
  }

  Timer? _errorTimer;
  setError(String message) {
    setState(() => this.error = message);
    this._errorTimer?.cancel();
    this._errorTimer = Timer(Duration(milliseconds:8000), () {
      setState(() => this.error = null);
    });
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
              padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) + EdgeInsets.symmetric(vertical:24),
              child: ConstrainedBox(
                constraints: new BoxConstraints(
                  minWidth: width,
                  minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical:16, horizontal:48),
                      child: Text(
                        "What would you like to do?",
                        style: Theme.of(context).textTheme.headline3
                      )
                    ),
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: new BoxConstraints(
                          minWidth: width
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal:44),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ServiceButtonData(
                                label: 'Place',
                                key: 'place-order',
                                icon: PlaceOrderIllustration(
                                  color: Color.fromRGBO(0, 0, 0, 1.0)
                                )
                              ),
                              _ServiceButtonData(
                                label: 'Retrieve',
                                key: 'retrieve-order',
                                icon: RetrieveOrderIllustration(
                                  color: Color.fromRGBO(0, 0, 0, 1.0)
                                )
                              )
                            ].map((service) {
                              return Container(
                                width: 168.0,
                                padding: EdgeInsets.symmetric(vertical:8, horizontal:4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IllustrationButton(
                                      onTap: () => this.setSelected(service.key),
                                      selected: this.selected == service.key,
                                      child: service.icon
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical:8),
                                      child: Text(
                                        service.label,
                                        style: Theme.of(context).textTheme.headline3
                                      )
                                    )
                                  ]
                                )
                              );
                            }).toList(),
                          )
                        )
                      )
                    )
                  ],
                )
              )
            ),
            Positioned(
              top: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: top + topHeight,
                width: width,
                padding: EdgeInsets.only(top:top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Touchable(
                      child: Container(
                        height: 48,
                        width: 48,
                        padding: EdgeInsets.all(12),
                        color: Colors.transparent,
                        child: BackIcon(color:Theme.of(context).colorScheme.onSurface)
                      ),
                      onTap: () => this.goBack(context)
                    )
                  ],
                )
              )
            ),
            Positioned(
              width: width,
              bottom: bottom + bottomHeight,
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: InlineError(this.error)
                )
              )
            ),
            Positioned(
              width: width,
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: bottom + bottomHeight,
                padding: EdgeInsets.only(bottom:bottom),
                child: Center(
                  child: Container(
                    width: [width, 360.0].reduce(math.min),
                    padding: EdgeInsets.symmetric(horizontal:48, vertical:16),
                    child: Button(
                      onTap: () => this.confirm(context),
                      label: 'CONFIRM'
                    )
                  )
                )
              )
            )
          ]
        )
      ),
    );
  }
}

class _ServiceButtonData {
  String label;
  String key;
  Widget icon;
  _ServiceButtonData({
    required this.label,
    required this.key,
    required this.icon,
  });
}