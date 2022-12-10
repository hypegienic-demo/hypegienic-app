import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart' show FirebaseDynamicLinks;

import '../store/authentication.dart';
import './authentication/sign-in.dart';
import './application/main.dart';
import './common/loading.dart';

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ApplicationState();
}
class _ApplicationState extends State<Application> with StoreWatcherMixin<Application> {
  BuildContext? childContext;
  late AuthenticationStore authenticationStore;
  bool? authenticated;
  void Function(String)? navigateTab;

  @override
  void initState() {
    super.initState();
    this.authenticationStore = listenToStore(authenticationStoreToken, this.authenticationChange) as AuthenticationStore;
    this.authenticated = this.authenticationStore.authenticated;
  }
  void authenticationChange(Store store) {
    final authenticationStore = store as AuthenticationStore;
    if(authenticationStore.authenticated != this.authenticated) {
      this.authenticated = authenticationStore.authenticated;
      Navigator.pushAndRemoveUntil(
        this.childContext?? this.context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) {
            this.childContext = context;
            if(this.authenticated != true) {
              return SignInPage();
            } else {
              if(this.initialLink != null) {
                Timer(Duration.zero, () {
                  this.navigate(this.initialLink!);
                  this.initialLink = null;
                });
              }
              return ApplicationPage(
                getAction: (action) {
                  this.navigateTab = action.navigateTab;
                },
              );
            }
          },
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(
              opacity: Tween(begin:0.0, end:1.0).animate(
                CurvedAnimation(parent:animation1, curve:Curves.easeInOut)
              ),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds:600)
        ),
        (route) => false
      );
    }
  }
  Uri? initialLink;
  void listenDynamicLink() async {
    FirebaseDynamicLinks.instance.onLink.listen(
      (dynamicLink) async {
        final link = dynamicLink.link;
        this.navigate(link);
      }
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.getInitialLink();
    final link = dynamicLink?.link;
    if(link != null) {
      this.initialLink = link;
    }
  }
  void navigate(Uri link) {
    print(link);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hy{pe}gienic',
      theme: ThemeData(
        fontFamily: 'Arimo',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(0, 0, 0, 1)
          ),
          headline2: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          headline3: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          headline4: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 21,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          headline5: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          headline6: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          bodyText1: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            color: Color.fromRGBO(33, 33, 33, 1)
          ),
          bodyText2: TextStyle(
            fontFamily: 'Exan',
            fontSize: 14,
            color: Color.fromRGBO(33, 33, 33, 1),
            shadows: <BoxShadow>[
              BoxShadow(
                offset: Offset(0.3, 0),
                color: Color.fromRGBO(33, 33, 33, 1)
              ),
              BoxShadow(
                offset: Offset(-0.3, 0),
                color: Color.fromRGBO(33, 33, 33, 1)
              )
            ]
          ),
          caption: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color.fromRGBO(88, 89, 91, 1)
          ),
          button: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(255, 255, 255, 1)
          )
        ),
        colorScheme: ColorScheme.light(
          primary: Color.fromRGBO(79, 139, 108, 1),
          primaryVariant: Color.fromRGBO(110, 165, 113, 1),
          secondary: Color.fromRGBO(60, 176, 228, 1),
          surface: Color.fromRGBO(255, 255, 255, 1),
          onSurface: Color.fromRGBO(33, 33, 33, 1),
          onBackground: Color.fromRGBO(88, 89, 91, 1),
          error: Color.fromRGBO(131, 24, 24, 1),
          onError: Color.fromRGBO(242, 212, 105, 1),
        ),
        buttonTheme: ButtonThemeData(
          padding: EdgeInsets.symmetric(horizontal:16, vertical:4)
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 2,
          activeTrackColor: Color.fromRGBO(110, 165, 113, 1),
          inactiveTrackColor: Color.fromRGBO(102, 102, 102, 0.3),
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 8,
            elevation: 0,
            pressedElevation: 0
          )
        )
      ),
      home: Builder(
        builder: (BuildContext context) {
          this.childContext = context;
          final deviceData = MediaQuery.of(context);
          final width = deviceData.size.width;
          final height = deviceData.size.height;
          
          return Container(
            height: height,
            width: width,
            color: Colors.white,
            child: Center(
              child: LoadingText()
            )
          );
        }
      )
    );
  }
}

class NavigationPopResult {
  final List<String> toPath;
  final bool refresh;

  NavigationPopResult({
    required this.toPath,
    bool? refresh
  }):
    this.refresh = refresh == true;
}