import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:hypegienic/asset/graphic/icon/service.dart';

import '../../../store/progress.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/stripe.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/inline-error.dart';
import '../../main.dart';

class ConfirmCouponPage extends StatefulWidget {
  final String requestId;
  final String coupon;
  final List<ProgressServicePreview> services;

  ConfirmCouponPage({
    required this.requestId,
    required this.coupon,
    required this.services
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
  State<StatefulWidget> createState() => _ConfirmCouponPageState();
}
class _ConfirmCouponPageState extends State<ConfirmCouponPage> with StoreWatcherMixin<ConfirmCouponPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late ProgressStore progressStore;
  bool? loading;
  String? error;
  
  @override
  void initState() {
    super.initState();
    this.loading = false;
    progressStore = listenToStore(progressStoreToken) as ProgressStore;
  }

  confirm(BuildContext context) async {
    setState(() => this.loading = true);
    await progressStore.attachRequestCoupon(widget.requestId, widget.coupon);
    setState(() => this.loading = false);
    Navigator.pop(context, NavigationPopResult(
      toPath: ['progress-detail'],
      refresh: true
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
    
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
    );
    final getServiceTypePoint = (ProgressServicePreview service) =>
      service.type == 'main'? 1:0;
    final services = widget.services
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
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
                            "You won't be able to add another coupon code after this",
                            style: Theme.of(context).textTheme.bodyText1
                          )
                        ]
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:24),
                      child: Table(
                        border: TableBorder.symmetric(
                          outside: borderSide
                        ),
                        columnWidths: {
                          0: IntrinsicColumnWidth(),
                          1: IntrinsicColumnWidth(flex:1),
                          2: IntrinsicColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.top,
                        children: [
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
                                padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:12, left:4),
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
                            .expand((entry) {
                              final service = entry.value;
                              final discounted = service.price != service.discountedPrice;
                              final padding = (entry.key == services.length - 1? EdgeInsets.only(bottom:8):EdgeInsets.zero)
                                + EdgeInsets.symmetric(horizontal:4)
                                + (discounted? EdgeInsets.only(top:8, bottom:-8):EdgeInsets.symmetric(vertical:8));
                              return [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: padding + EdgeInsets.only(left:10),
                                      child: Text(
                                        '${(entry.key + 1).toString()}.',
                                        style: Theme.of(context).textTheme.headline6
                                      )
                                    ),
                                    Padding(
                                      padding: padding + EdgeInsets.only(right:4),
                                      child: Text(
                                        service.name,
                                        style: Theme.of(context).textTheme.headline6
                                      )
                                    ),
                                    Padding(
                                      padding: padding + EdgeInsets.only(left:4, right:8),
                                      child: Text(
                                        "RM${service.price.toStringAsFixed(2)}",
                                        style: Theme.of(context).textTheme.headline6?.copyWith(
                                          decoration: discounted? TextDecoration.lineThrough:null,
                                          color: discounted? Theme.of(context).textTheme.caption?.color:null,
                                          fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                        ),
                                        textAlign: TextAlign.right,
                                      )
                                    )
                                  ]
                                ),
                                discounted
                                  ? TableRow(
                                      children: [
                                        Container(),
                                        Container(),
                                        Padding(
                                          padding: EdgeInsets.all(4) + EdgeInsets.only(top:-4, bottom:8, right:8),
                                          child: Text(
                                            'RM${service.discountedPrice.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.headline6?.copyWith(
                                              fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                            ),
                                            textAlign: TextAlign.right,
                                          )
                                        )
                                      ]
                                    )
                                  : null
                              ].whereType<TableRow>();
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
                                  padding: EdgeInsets.all(4) + EdgeInsets.only(top:12, left:10, right:2, bottom:12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).colorScheme.primary
                                      )
                                    ),
                                    child: Stripes(
                                      color: Theme.of(context).colorScheme.primary,
                                      stripeSize: StripeSize(
                                        lineWidth: 1,
                                        gapWidth: 8
                                      )
                                    )
                                  )
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:16, left:4, right:4, bottom:16),
                                child: Text(
                                  'TOTAL',
                                  style: Theme.of(context).textTheme.headline6
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:16, left:4, right:12, bottom:16),
                                child: Text(
                                  "RM${services
                                    .fold<double>(0, (sum, service) => sum + service.discountedPrice)
                                    .toStringAsFixed(2)
                                  }",
                                  style: Theme.of(context).textTheme.headline6?.copyWith(
                                    fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                  ),
                                  textAlign: TextAlign.right,
                                )
                              )
                            ]
                          )
                        ]
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
                      loading: this.loading,
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