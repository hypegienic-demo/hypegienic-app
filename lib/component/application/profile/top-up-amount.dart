import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/main.dart';
import '../../../store/wallet.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../../asset/graphic/icon/add.dart';
import '../../../asset/graphic/icon/minus.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/inline-error.dart';
import '../../main.dart';
import './top-up-site.dart';

class TopUpAmountPage extends StatefulWidget {
  final double? amount;
  TopUpAmountPage({
    double? amount
  }) :
    this.amount = amount,
    super() {
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
  State<StatefulWidget> createState() => _TopUpAmountPageState();
}
final minimumAmount = 19.0;
final maximumAmount = 399.0;
class _TopUpAmountPageState extends State<TopUpAmountPage> with StoreWatcherMixin<TopUpAmountPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late WalletStore walletStore;
  late double amount;
  bool loading;
  String? error;

  _TopUpAmountPageState() :
    this.loading = false,
    super();
  
  @override
  void initState() {
    super.initState();
    walletStore = listenToStore(walletStoreToken) as WalletStore;
    this.amount = widget.amount ?? 69;
  }
  
  setAmount(double amount) {
    setState(() => this.amount = amount);
  }
  increaseAmount() {
    if(this.amount < maximumAmount) {
      setState(() => this.amount += 1);
    }
  }
  decreaseAmount() {
    if(this.amount > minimumAmount) {
      setState(() => this.amount -= 1);
    }
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('top-up-amount')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }
  update(BuildContext context) async {
    this.setState(() => this.loading = true);
    try {
      final url = await walletStore.requestTopUp(this.amount);
      this.setState(() => this.loading = false);
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => TopUpSitePage(
          url: url,
        )
      ));
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        setError(error.message);
      } else {
        setError('Something went wrong with updating');
      }
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
                      padding: EdgeInsets.symmetric(vertical:16, horizontal:24),
                      child: Text(
                        'How much would you like to top up?',
                        style: Theme.of(context).textTheme.headline3
                      )
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:24) +
                            EdgeInsets.only(bottom:24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RM${this.amount.toStringAsFixed(0)}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline2
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal:6),
                                    child: Touchable(
                                      onTap: this.decreaseAmount,
                                      disabled: this.amount == minimumAmount,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Theme.of(context).colorScheme.onBackground
                                          ),
                                          borderRadius: BorderRadius.circular(18)
                                        ),
                                        padding: EdgeInsets.all(3),
                                        child: MinusIcon(
                                          size: Size.square(24),
                                          color: Theme.of(context).colorScheme.onSurface,
                                        )
                                      )
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal:6),
                                    child: Touchable(
                                      onTap: this.increaseAmount,
                                      disabled: this.amount == maximumAmount,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Theme.of(context).colorScheme.onBackground
                                          ),
                                          borderRadius: BorderRadius.circular(18)
                                        ),
                                        padding: EdgeInsets.all(3),
                                        child: AddIcon(
                                          size: Size.square(24),
                                          color: Theme.of(context).colorScheme.onSurface,
                                        )
                                      )
                                    )
                                  )
                                ],
                              )
                            ]
                          )
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 56
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Slider(
                                value: this.amount,
                                onChanged: this.setAmount,
                                divisions: 36,
                                min: minimumAmount,
                                max: maximumAmount
                              )
                            ),
                            Positioned(
                              bottom: 0,
                              left: 24,
                              right: 24,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    minimumAmount.toStringAsFixed(0),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.caption
                                  ),
                                  Text(
                                    maximumAmount.toStringAsFixed(0),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.caption
                                  )
                                ]
                              )
                            )
                          ],
                        )
                      ]
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
                      onTap: () => this.update(context),
                      loading: this.loading,
                      label: 'CONTINUE'
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
