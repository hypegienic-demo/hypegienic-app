import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../store/authentication.dart';
import '../../asset/graphic/icon/back.dart';
import '../common/input/field.dart';
import '../common/button.dart';
import '../common/touchable.dart';
import '../common/inline-error.dart';
import './main.dart';

class RegisterNamePage extends StatefulWidget {
  RegisterNamePage() {
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
  State<StatefulWidget> createState() => _RegisterNamePageState();
}
class _RegisterNamePageState extends State<RegisterNamePage> with StoreWatcherMixin<RegisterNamePage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late AuthenticationStore authenticationStore;
  String? name;
  String? error;
  
  @override
  void initState() {
    super.initState();
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
  }
  
  setName(String name) {
    setState(() => this.name = name);
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        widget.setBarStyle();
        return object;
      });
  }
  register(BuildContext context) {
    if(this.name != null) {
      authenticationStore.updateRegistrationDetail(name:this.name);
      this.navigate(
        context,
        navigateToRegistrationForm(authenticationStore)
      );
      return;
    } else {
      setError('Please make sure you keyed in your name');
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
                        "What's your name?",
                        style: Theme.of(context).textTheme.headline3
                      )
                    ),
                    Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:24, vertical:16),
                      child: InputField(
                        onChanged: this.setName,
                        onSubmitted: (value) => this.register(context),
                        autofocus: true,
                        style: Theme.of(context).textTheme.headline4,
                        textCapitalization: TextCapitalization.words,
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
                      '03/05',
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
                      onTap: () => this.register(context),
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
