import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide ExpandIcon;
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/authentication.dart';
import '../../../store/service.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../../asset/graphic/icon/service.dart';
import '../../common/stripe.dart';
import '../../common/touchable.dart';
import '../../main.dart';

class ServicesPage extends StatefulWidget {
  ServicesPage() {
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
  State<StatefulWidget> createState() => _ServicesPageState();
}
class _ServicesPageState extends State<ServicesPage> with StoreWatcherMixin<ServicesPage> {
  final double topHeight = 48;
  final double bottomHeight = 0;

  bool mount;
  late AuthenticationStore authenticationStore;
  late ServiceStore serviceStore;
  List<Service>? services;
  bool loading;

  _ServicesPageState() :
    this.mount = false,
    this.loading = true,
    super();

  @override
  void initState() {
    super.initState();
    this.mount = true;
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    serviceStore = listenToStore(serviceStoreToken, (store) {
      final progressStore = store as ServiceStore;
      setState(() {
        this.services = progressStore.services;
      });
    }) as ServiceStore;
    this.getServices();
  }
  @override
  dispose() {
    this.mount = false;
    super.dispose();
  }
  @override
  setState(void Function() fn) {
    if(this.mount) super.setState(fn);
  }
  getServices() async {
    await serviceStore.getServices();
    setState(() => this.loading = false);
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && object.toPath.contains('service') && object.refresh) {
          setState(() => this.loading = true);
          this.getServices();
        }
        widget.setBarStyle();
        return object;
      });
  }
  goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;

    final mainServices = this.services
      ?.where((service) => service.type == 'main')
      .toList();
    final excludedServiceId = (mainServices
      ?.expand<String>((service) => service.exclude?? [])
      .toList())?? [];
    final additionalServices = this.services
      ?.where((service) => service.type != 'main')
      .where((service) => !excludedServiceId.contains(service.id))
      .toList();
    final services = mainServices != null && additionalServices != null
      ? [
          ...mainServices,
          ...additionalServices
        ]
      : null;
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
    );
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: this.loading? 0:1,
              duration: Duration(milliseconds:300),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) +
                  EdgeInsets.symmetric(vertical:24, horizontal:32),
                child: ConstrainedBox(
                  constraints: new BoxConstraints(
                    minWidth: width,
                    minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom:bottom + bottomHeight + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom:24),
                          child: Text(
                            'SERVICES',
                            style: Theme.of(context).textTheme.headline3
                          )
                        ),
                        Table(
                          border: TableBorder.symmetric(
                            outside: borderSide
                          ),
                          columnWidths: {
                            0: FixedColumnWidth(34),
                            1: IntrinsicColumnWidth(flex:1),
                            2: IntrinsicColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: services
                            ?.asMap().entries
                            .map((entry) {
                              final service = entry.value;
                              final descriptionRow = service.description != null;
                              return [
                                TableRow(
                                  decoration: entry.key != 0
                                    ? BoxDecoration(
                                        border: Border(
                                          top: borderSide
                                        )
                                      )
                                    : null,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(4) + EdgeInsets.only(top:8, left:8, right:4) +
                                        (!descriptionRow? EdgeInsets.only(bottom:8):EdgeInsets.zero),
                                      child: ServiceIcon(
                                        size: Size.square(14),
                                        color: Theme.of(context).colorScheme.onBackground
                                      )
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:8) +
                                        (!descriptionRow? EdgeInsets.only(bottom:8):EdgeInsets.zero),
                                      child: Text(
                                        service.name,
                                        style: Theme.of(context).textTheme.headline5
                                      )
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(4) + EdgeInsets.only(top:8, left:4, right:8) +
                                          (!descriptionRow? EdgeInsets.only(bottom:8):EdgeInsets.zero),
                                        child: Text(
                                          "RM${service.price.toStringAsFixed(0)}",
                                          style: Theme.of(context).textTheme.headline5
                                        )
                                      )
                                    )
                                  ]
                                ),
                                descriptionRow
                                  ? TableRow(
                                      children: [
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.fill,
                                          child: Padding(
                                            padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:8, left:8, right:4),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Theme.of(context).colorScheme.secondary
                                                )
                                              ),
                                              child: service.type == 'main'
                                                ? Stripes(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    stripeSize: StripeSize(
                                                      lineWidth: 1,
                                                      gapWidth: 8
                                                    )
                                                  )
                                                : null
                                            )
                                          )
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom:8, right:4),
                                          child: Text(
                                            service.description!,
                                            style: Theme.of(context).textTheme.bodyText1
                                          )
                                        ),
                                        Container()
                                      ]
                                    )
                                  : null
                              ];
                            })
                            .expand((widgets) => widgets.whereType<TableRow>())
                            .toList()?? []
                        )
                      ]
                    )
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
            )
          ]
        )
      )
    );
  }
}
