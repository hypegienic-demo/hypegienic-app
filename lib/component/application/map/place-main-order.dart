import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../store/service.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/button.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/inline-error.dart';
import '../../main.dart';
import './place-additional-order.dart';
import './assign-name.dart';

class PlaceMainOrderPage extends StatefulWidget {
  final String lockerId;

  PlaceMainOrderPage({
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
  State<StatefulWidget> createState() => _PlaceMainOrderPageState();
}
class _PlaceMainOrderPageState extends State<PlaceMainOrderPage> with StoreWatcherMixin<PlaceMainOrderPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late ServiceStore serviceStore;
  List<Service>? services;
  String? selected;
  bool loading;
  String? error;

  _PlaceMainOrderPageState() :
    this.loading = true,
    super();
  
  @override
  void initState() {
    super.initState();
    serviceStore = listenToStore(serviceStoreToken, (store) {
      final serviceStore = store as ServiceStore;
      setState(() {
        this.services = serviceStore.services;
      });
    }) as ServiceStore;
    this.services = serviceStore.services;
    this.getServices();
  }
  getServices() async {
    await serviceStore.getServices();
    setState(() {
      this.loading = false;
    });
  }

  setSelected(String selected) {
    setState(() => this.selected = selected);
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('place-main-order')) {
          Navigator.pop(context, object);
        }
        if(object is NavigationPopResult && object.toPath.contains('place-main-order') && object.refresh) {
          setState(() => this.loading = true);
          this.getServices();
        }
        widget.setBarStyle();
        return object;
      });
  }

  confirm(BuildContext context) async {
    final services = this.services;
    final selected = this.selected;
    if(services != null && selected != null) {
      final selectedService = services
        .firstWhere((service) => service.id == selected);
      final additionalServices = services
        .where((service) => service.type == 'additional')
        .toList();
      if(additionalServices.length > 0) {
        this.navigate<NavigationPopResult>(context, MaterialPageRoute(
          builder: (context) => PlaceAdditionalOrderPage(
            lockerId: widget.lockerId,
            mainServiceId: selected,
            services: this.services?? [],
            excluded: [
              ...this.services
                ?.where((service) => service.type == 'main')
                .map((service) => service.id)?? [],
              ...selectedService.exclude?? []
            ],
          )
        ));
      } else {
        this.navigate<NavigationPopResult>(context, MaterialPageRoute(
          builder: (context) => AssignNamePage(
            lockerId: widget.lockerId,
            serviceIds: [selected],
            services: this.services?? [],
          )
        ));
      }
    } else {
      setError('Please select an option');
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
        child: AnimatedOpacity(
          opacity: this.loading? 0:1,
          duration: Duration(milliseconds:300),
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
                          "Which service would you like?",
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
                              children: this.services
                                ?.where((service) => service.type == 'main')
                                .map((service) {
                                  return Container(
                                    width: 168.0,
                                    padding: EdgeInsets.symmetric(vertical:8, horizontal:4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IllustrationButton(
                                          onTap: () => this.setSelected(service.id),
                                          selected: this.selected == service.id,
                                          child: service.icon != null
                                            ? SvgPicture.network(
                                                service.icon?? '',
                                                placeholderBuilder: (BuildContext context) => Container(),
                                              )
                                            : Container(),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top:8),
                                          child: Text(
                                            service.name,
                                            style: Theme.of(context).textTheme.headline3
                                          )
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom:8),
                                          child: Text(
                                            "RM${service.price.toStringAsFixed(0)}",
                                            style: Theme.of(context).textTheme.headline6?.copyWith(
                                              color: Theme.of(context).colorScheme.onBackground
                                            )
                                          )
                                        )
                                      ]
                                    )
                                  );
                                })
                                .toList()
                                ?? [],
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
                        '01/05',
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
      ),
    );
  }
}
