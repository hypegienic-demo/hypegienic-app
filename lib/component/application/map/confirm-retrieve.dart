import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:hypegienic/asset/graphic/icon/service.dart';

import '../../../store/authentication.dart';
import '../../../store/progress.dart';
import '../../../store/locker.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../../asset/graphic/icon/shoe.dart';
import '../../common/stripe.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/inline-error.dart';
import '../../main.dart';
import '../profile/top-up-amount.dart';
import './show-locker.dart';

class ConfirmRetrievePage extends StatefulWidget {
  final ProgressSimple progress;

  ConfirmRetrievePage({
    required this.progress
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
  State<StatefulWidget> createState() => _ConfirmRetrievePageState();
}
class _ConfirmRetrievePageState extends State<ConfirmRetrievePage> with StoreWatcherMixin<ConfirmRetrievePage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late AuthenticationStore authenticationStore;
  late LockerStore lockerStore;
  bool? requesting;
  String? error;
  
  @override
  void initState() {
    super.initState();
    this.requesting = false;
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    lockerStore = listenToStore(lockerStoreToken) as LockerStore;
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('confirm-deposit')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }

  confirm(BuildContext context) async {
    setState(() => this.requesting = true);
    lockerStore.retrieveOrder(widget.progress.id)
      .then((lockerUnit) => 
        this.navigate<NavigationPopResult>(context, MaterialPageRoute(
          builder: (context) => ShowLockerPage(
            lockerUnitId: lockerUnit.id,
            retrieveProgressId: widget.progress.id
          )
        ))
      )
      .catchError((error) async {
        if(error.message == "User don't have enough funds in the wallet") {
          final user = await authenticationStore.getUserProfile();
          this.navigate<NavigationPopResult>(context, MaterialPageRoute(
            builder: (context) => TopUpAmountPage(
              amount: widget.progress.services
                .fold<double>(0, (sum, service) => sum + service.price) -
                user.walletBalance
            )
          ));
        } else {
          this.setError(error.message);
        }
      })
      .whenComplete(() => 
        setState(() => this.requesting = false)
      );
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
    
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
    );
    final getServiceTypePoint = (ProgressService service) =>
      service.type == 'main'? 1:0;
    final services = widget.progress.services
      ..sort((service1, service2) =>
        getServiceTypePoint(service2) - getServiceTypePoint(service1)
      );
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom:24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom:8),
                              child: Text(
                                'Please confirm the following detail',
                                style: Theme.of(context).textTheme.headline3
                              )
                            ),
                            Text(
                              "The following amount will be deducted from your wallet",
                              style: Theme.of(context).textTheme.bodyText1
                            )
                          ]
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
                        defaultVerticalAlignment: TableCellVerticalAlignment.top,
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(4) + EdgeInsets.only(top:12, left:8, right:4),
                                child: ShoeIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground)
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:12),
                                child: Text(
                                  'Name',
                                  style: Theme.of(context).textTheme.caption
                                )
                              ),
                              Container()
                            ]
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.fill,
                                child: Padding(
                                  padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:12, left:8, right:4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).colorScheme.secondary
                                      )
                                    ),
                                    child: Stripes(
                                      color: Theme.of(context).colorScheme.secondary,
                                      stripeSize: StripeSize(
                                        lineWidth: 1,
                                        gapWidth: 8
                                      )
                                    )
                                  )
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(bottom:12),
                                child: Text(
                                  widget.progress.name,
                                  style: Theme.of(context).textTheme.headline5
                                )
                              ),
                              Container()
                            ]
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                top: borderSide
                              )
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(4) + EdgeInsets.only(top:12, left:8, right:4),
                                child: ServiceIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground)
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:12),
                                child: Text(
                                  'Services',
                                  style: Theme.of(context).textTheme.caption
                                )
                              ),
                              Container()
                            ]
                          ),
                          ...services
                            .asMap().entries
                            .map((entry) {
                              final service = entry.value;
                              final stripeSide = BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.onBackground
                              );
                              return TableRow(
                                children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.fill,
                                    child: Padding(
                                      padding: (entry.key == 0
                                        ? EdgeInsets.only(top:4)
                                        : EdgeInsets.zero
                                      ) + (entry.key == services.length - 1
                                        ? EdgeInsets.only(bottom:16)
                                        : EdgeInsets.zero
                                      ) + EdgeInsets.only(left:12, right:8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: entry.key == 0
                                              ? stripeSide
                                              : BorderSide.none,
                                            bottom: entry.key == services.length - 1
                                              ? stripeSide
                                              : BorderSide.none,
                                            left: stripeSide,
                                            right: stripeSide
                                          )
                                        )
                                      )
                                    )
                                  ),
                                  Padding(
                                    padding: (entry.key == 0
                                      ? EdgeInsets.only(top:4)
                                      : EdgeInsets.zero
                                    ) + (entry.key == services.length - 1
                                      ? EdgeInsets.only(bottom:16)
                                      : EdgeInsets.zero
                                    ) + EdgeInsets.only(right:4),
                                    child: Text(
                                      service.name,
                                      style: Theme.of(context).textTheme.headline5
                                    )
                                  ),
                                  Padding(
                                    padding: (entry.key == 0
                                      ? EdgeInsets.only(top:4)
                                      : EdgeInsets.zero
                                    ) + (entry.key == services.length - 1
                                      ? EdgeInsets.only(bottom:16)
                                      : EdgeInsets.zero
                                    ) + EdgeInsets.only(left:4, right:12),
                                    child: Text(
                                      "RM${service.price.toStringAsFixed(0)}",
                                      style: Theme.of(context).textTheme.headline5?.copyWith(
                                        fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                      ),
                                      textAlign: TextAlign.right,
                                    )
                                  )
                                ]
                              );
                            }),
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                top: borderSide
                              )
                            ),
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.fill,
                                child: Padding(
                                  padding: EdgeInsets.all(4) + EdgeInsets.only(top:12, left:8, right:4, bottom:12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).colorScheme.primaryVariant
                                      )
                                    ),
                                    child: Stripes(
                                      color: Theme.of(context).colorScheme.primaryVariant,
                                      stripeSize: StripeSize(
                                        lineWidth: 1,
                                        gapWidth: 8
                                      )
                                    )
                                  )
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:16, right:4, bottom:16),
                                child: Text(
                                  'TOTAL',
                                  style: Theme.of(context).textTheme.headline5
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:16, left:4, right:12, bottom:16),
                                child: Text(
                                  "RM${services
                                    .fold<double>(0, (sum, service) => sum + service.price)
                                    .toStringAsFixed(0)
                                  }",
                                  style: Theme.of(context).textTheme.headline5?.copyWith(
                                    fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                  ),
                                  textAlign: TextAlign.right,
                                )
                              )
                            ]
                          )
                        ]
                      )
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
                      '02/03',
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
                      loading: this.requesting,
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