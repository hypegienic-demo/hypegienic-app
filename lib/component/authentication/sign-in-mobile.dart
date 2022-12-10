import 'dart:math' as math;
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../../store/authentication.dart';
import '../../asset/graphic/icon/back.dart';
import '../common/input/mobile-field.dart';
import '../common/button.dart';
import '../common/touchable.dart';
import '../common/inline-error.dart';
import '../common/dialog/app-tracking-permission.dart';
import '../main.dart';
import './one-time-passcode.dart';

class SignInMobilePage extends StatefulWidget {
  SignInMobilePage() {
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
  State<StatefulWidget> createState() => _SignInMobilePageState();
}
class _SignInMobilePageState extends State<SignInMobilePage> with StoreWatcherMixin<SignInMobilePage> {
  final double topHeight = 48;
  final double bottomHeight = 76;
  GlobalKey _permissionDialog = GlobalKey();

  late AuthenticationStore authenticationStore;
  String? mobileNum;
  String? error;
  bool requesting;

  _SignInMobilePageState() :
    this.requesting = false,
    super();
  
  @override
  void initState() {
    super.initState();
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    if(Platform.isIOS) {
      this.getAppTrackingPermission();
    }
  }

  getAppTrackingPermission() async {
    final appTrackingStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
    if(appTrackingStatus == TrackingStatus.notDetermined) {
      showAppTrackingPermissionDialog(
        key: this._permissionDialog,
        context: context
      );
    }
  }
  
  setMobileNum(String mobileNum) {
    setState(() => this.mobileNum = mobileNum);
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        widget.setBarStyle();
        return object;
      });
  }
  login(BuildContext context) {
    final mobileNum = this.mobileNum;
    if(mobileNum != null) {
      setState(() => this.requesting = true);
      authenticationStore.signInMobile(mobileNum)
        .then((value) {
          this.navigate<NavigationPopResult>(
            context,
            MaterialPageRoute(builder:(context) => OneTimePasscodePage(mobileNumber:this.mobileNum))
          );
          return;
        })
        .catchError((error) {
          setError(error.message);
        })
        .whenComplete(() => 
          setState(() => this.requesting = false)
        );
    } else {
      setError('Please make sure you keyed in the correct mobile number');
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
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
                      child: Text(
                        'What is your phone number?',
                        style: Theme.of(context).textTheme.headline3
                      )
                    ),
                    Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
                      child: MobileInputField(
                        onChanged: this.setMobileNum,
                        onSubmitted: (value) => this.login(context),
                        autofocus: true,
                        placeholder: '12 - 345 6789',
                        style: Theme.of(context).textTheme.headline4,
                        scrollPadding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight),
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
                      loading: this.requesting,
                      onTap: () => this.login(context),
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
