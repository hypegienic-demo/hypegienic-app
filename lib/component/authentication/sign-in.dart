import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../asset/graphic/illustration/hypegienic.dart';
import '../../asset/graphic/illustration/hypeguardian.dart';
import '../common/stripe.dart';
import '../common/button.dart';
import '../main.dart';
import './sign-in-mobile.dart';

class SignInPage extends StatefulWidget {
  SignInPage() {
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
  State<StatefulWidget> createState() => _SignInPageState();
}
class _SignInPageState extends State<SignInPage> {
  final double topHeight = 0;
  final double bottomHeight = 0;

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        widget.setBarStyle();
        return object;
      });
  }
  navigateToSignInMobile() {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => SignInMobilePage()
    ));
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
          children: <Widget?>[
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) + EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: width,
                  minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              HypegienicIllustration(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal:8),
                                    child: Text(
                                      '×',
                                      style: Theme.of(context).textTheme.headline1?.copyWith(
                                        fontWeight: FontWeight.w400
                                      )
                                    )
                                  ),
                                  HypeguardianIllustration(
                                    size: Size(80, 80)
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical:8),
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  shape: BeveledRectangleBorder(
                                    side: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      width: 0.75
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(6)
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top:1) +
                                          EdgeInsets.symmetric(vertical:1, horizontal:4),
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                        child: Text(
                                          'POWERED BY',
                                          style: TextStyle(
                                            fontFamily: 'Arimo',
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromRGBO(255, 255, 255, 1)
                                          )
                                        )
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom:2) +
                                          EdgeInsets.symmetric(horizontal:4),
                                        child: Text(
                                          'HYPEGUARDIAN',
                                          style: TextStyle(
                                            fontFamily: 'Arimo',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromRGBO(0, 0, 0, 1)
                                          )
                                        )
                                      )
                                    ]
                                  )
                                )
                              )
                            ]
                          )
                        )
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: [width, 420.0].reduce(math.min),
                          padding: EdgeInsets.all(24),
                          child: _HeaderBackground(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom:6),
                                    child: Text(
                                      'YOUR DIRTY SHOES DESERVES A SECOND CHANCE',
                                      style: Theme.of(context).textTheme.headline4?.copyWith(
                                        fontWeight: FontWeight.w700
                                      )
                                    )
                                  ),
                                  Material(
                                    clipBehavior: Clip.antiAlias,
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(6)
                                      ),
                                    ),
                                    child: Container(
                                      color: Theme.of(context).colorScheme.onBackground,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical:3, horizontal:8),
                                        child: Text(
                                          'GET THEM CLEANED TODAY',
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                            color: Theme.of(context).colorScheme.background,
                                            fontWeight: FontWeight.w700
                                          )
                                        )
                                      )
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        )
                      ]
                    ),
                    Column(
                      children: [
                        Container(
                          width: [width, 360.0].reduce(math.min),
                          padding: EdgeInsets.symmetric(horizontal:48, vertical:24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Button(
                                onTap: this.navigateToSignInMobile,
                                label: 'CONTINUE WITH PHONE'
                              )
                            ]
                          )
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:24),
                          child: RichText(
                            text: TextSpan(
                              text: "By signing up, I confirm to hypegienic's ",
                              style: Theme.of(context).textTheme.caption,
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'terms of service',
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    launch('https://www.hypegienic.com/terms-and-condition');
                                  },
                                  style: Theme.of(context).textTheme.caption?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.underline
                                  )
                                ),
                                TextSpan(text:'.')
                              ]
                            )
                          )
                        )
                      ]
                    )
                  ]
                )
              )
            ),
            top > 0? Positioned(
              top: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: top,
                width: width
              )
            ):null,
            bottom > 0? Positioned(
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: bottom + insetBottom,
                width: width
              )
            ):null
          ].whereType<Widget>().toList()
        )
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final Widget child;
  _HeaderBackground({
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top:16, bottom:-16, left:-16, right:16,
          child: MovingStripes(
            color: Theme.of(context).colorScheme.secondary
          )
        ),
        Positioned(
          top:0, bottom:0, left:0, right:0,
          child: Container(
            color: Theme.of(context).colorScheme.background
          )
        ),
        Positioned(
          top:0, bottom:0, left:0, right:0,
          child: CustomPaint(
            painter: _HeaderBackgroundBorder(
              color: Theme.of(context).colorScheme.onBackground
            )
          )
        ),
        child
      ]
    );
  }
}
class _HeaderBackgroundBorder extends CustomPainter {
  final Color color;
  _HeaderBackgroundBorder({
    Color? color
  }) :
    this.color = color?? Color.fromRGBO(0, 0, 0, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width - 12, size.height);
    path.lineTo(size.width, size.height - 12);
    path.lineTo(size.width, size.height / 2);
    canvas.drawPath(path, Paint()
      ..color = this.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
    );
  }

  @override
  bool shouldRepaint(_HeaderBackgroundBorder self) => false;
}