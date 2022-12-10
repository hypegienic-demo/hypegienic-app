import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../store/main.dart';
import '../../store/authentication.dart';
import '../../asset/graphic/icon/back.dart';
import '../common/input/mobile-field.dart';
import '../common/input/passcode-field.dart';
import '../common/button.dart';
import '../common/touchable.dart';
import '../common/inline-error.dart';
import './main.dart';

class OneTimePasscodePage extends StatefulWidget {
  final String? mobileNumber;

  OneTimePasscodePage({this.mobileNumber}) {
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
  State<StatefulWidget> createState() => _OneTimePasscodePageState();
}
class _OneTimePasscodePageState extends State<OneTimePasscodePage> with StoreWatcherMixin<OneTimePasscodePage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late AuthenticationStore authenticationStore;
  String? passcode;
  String? error;
  bool? requesting;
  
  @override
  void initState() {
    super.initState();
    this.requesting = false;
    this.authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
  }

  setPasscode(String passcode) {
    setState(() {
      this.passcode = passcode;
    });
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        widget.setBarStyle();
        return object;
      });
  }
  login(BuildContext context) {
    if(this.passcode != null) {
      setState(() => this.requesting = true);
      authenticationStore.submitPasscode(this.passcode!)
        .catchError((error) =>
          this.handleError(context, error)
        )
        .whenComplete(() => 
          setState(() => this.requesting = false)
        );
    } else {
      setError('Please make sure you complete the passcode');
    }
  }
  handleError(BuildContext context, ApplicationInterfaceError error) {
    if(error.message.contains('register your account first')) {
      this.navigate(
        context,
        navigateToRegistrationForm(this.authenticationStore)
      );
    } else {
      this.setError(error.message);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter 6-digit code below',
                            style: Theme.of(context).textTheme.headline3
                          ),
                          widget.mobileNumber != null? Text(
                            'We sent a sms with a code to\n${
                              '+60' + getConformedMobileNumber(widget.mobileNumber!.replaceFirst(RegExp(r'^\+60'), ''))
                            }',
                            style: Theme.of(context).textTheme.bodyText1
                          ) : null
                        ].whereType<Widget>().toList()
                      )
                    ),
                    Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
                      child: PasscodeField(
                        onChanged: this.setPasscode,
                        onSubmitted: (value) => this.login(context),
                        digit: 6,
                        autofocus: true,
                        placeholder: '000000',
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
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: bottom + bottomHeight,
                width: width,
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

