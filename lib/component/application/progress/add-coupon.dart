import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:hypegienic/asset/graphic/icon/service.dart';

import '../../../store/progress.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/input/field.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/inline-error.dart';
import '../../main.dart';
import './confirm-coupon.dart';

class AddCouponPage extends StatefulWidget {
  final String requestId;
  final List<ProgressService> services;

  AddCouponPage({
    required this.requestId,
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
  State<StatefulWidget> createState() => _AddCouponPageState();
}
class _AddCouponPageState extends State<AddCouponPage> with StoreWatcherMixin<AddCouponPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late ProgressStore progressStore;
  String? coupon;
  bool? loading;
  String? error;
  
  @override
  void initState() {
    super.initState();
    this.loading = false;
    progressStore = listenToStore(progressStoreToken) as ProgressStore;
  }

  setCoupon(String coupon) {
    setState(() {
      this.coupon = coupon;
    });
  }

  confirm(BuildContext context) async {
    if(coupon != null && coupon != '') {
      setState(() => this.loading = true);
      final serviceIds = widget.services.map((service) => service.id).toList();
      progressStore.previewCouponCode(serviceIds, coupon!)
        .then((services) {
          final couponApplicable = services.any((service) => service.discountedPrice != service.price);
          if(!couponApplicable) {
            this.setError('It seems like the coupon is not applicable to the services you requested');
          } else {
            this.navigateToConfirmCoupon(coupon!, services);
          }
        })
        .catchError((error) {
          this.setError(error.message);
        })
        .whenComplete(() => 
          setState(() => this.loading = false)
        );
    }
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('progress-add-coupon')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }
  goBack(BuildContext context) {
    Navigator.pop(context);
  }
  void navigateToConfirmCoupon(String coupon, List<ProgressServicePreview> services) {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => ConfirmCouponPage(
        requestId: widget.requestId,
        coupon: coupon,
        services: services
      )
    ));
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add a coupon code',
                            style: Theme.of(context).textTheme.headline3
                          )
                        ]
                      )
                    ),
                    Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16)
                        + EdgeInsets.only(bottom:24),
                      child: InputField(
                        onChanged: this.setCoupon,
                        onSubmitted: (value) => this.confirm(context),
                        autofocus: true,
                        style: Theme.of(context).textTheme.headline4,
                        scrollPadding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight),
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