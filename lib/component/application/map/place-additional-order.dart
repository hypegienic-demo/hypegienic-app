import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Checkbox;
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/service.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/button.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/inline-error.dart';
import '../../common/input/checkbox.dart';
import '../../main.dart';
import './assign-name.dart';

class PlaceAdditionalOrderPage extends StatefulWidget {
  final String lockerId;
  final String mainServiceId;
  final List<Service> services;
  final List<String> excluded;

  PlaceAdditionalOrderPage({
    required this.lockerId,
    required this.mainServiceId,
    required this.services,
    required this.excluded
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
  State<StatefulWidget> createState() => _PlaceAdditionalOrderPageState();
}
class _PlaceAdditionalOrderPageState extends State<PlaceAdditionalOrderPage> with StoreWatcherMixin<PlaceAdditionalOrderPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  List<String> selected;
  String? error;

  _PlaceAdditionalOrderPageState() :
    this.selected = [],
    super();

  @override
  void initState() {
    super.initState();
  }

  selectService(String service) {
    this.setState(() {
      if(this.selected.contains(service)) {
        this.selected = this.selected.where((selected) => selected != service).toList();
      } else {
        this.selected = [...this.selected, service];
      }
    });
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('place-additional-order')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }

  confirm(BuildContext context) async {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => AssignNamePage(
        lockerId: widget.lockerId,
        serviceIds: [widget.mainServiceId, ...this.selected],
        services: widget.services
      )
    ));
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
              padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) + EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: new BoxConstraints(
                  minWidth: width,
                  minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical:16, horizontal:24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom:24),
                        child: Text(
                          'Do you want to add-on other services?',
                          style: Theme.of(context).textTheme.headline3
                        )
                      ),
                      ...widget.services
                        .asMap().entries
                        .where((entry) => !widget.excluded.contains(entry.value.id))
                        .map((entry) {
                          final service = entry.value;
                          return Container(
                            padding: EdgeInsets.symmetric(vertical:4),
                            child: Checkbox(
                              checked: this.selected.contains(service.id),
                              onCheck: () => this.selectService(service.id),
                              label: service.name,
                              description: "RM${service.price.toStringAsFixed(0)}",
                            )
                          );
                        })
                        .toList()
                    ]
                  )
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ),
                    Text(
                      '02/05',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontSize: 18
                      )
                    ),
                    Container(height:48, width:48)
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
                      label: 'CONTINUE'
                    )
                  )
                )
              )
            )
          ]
        )
      )
    );
  }
}
