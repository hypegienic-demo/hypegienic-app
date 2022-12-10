import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../store/authentication.dart';
import '../../asset/graphic/icon/back.dart';
import '../../asset/graphic/icon/person.dart';
import '../../asset/graphic/icon/email.dart';
import '../common/stripe.dart';
import '../common/button.dart';
import '../common/touchable.dart';
import '../common/inline-error.dart';

class RegisterConfirmPage extends StatefulWidget {
  RegisterConfirmPage() {
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
  State<StatefulWidget> createState() => _RegisterConfirmPageState();
}
class _RegisterConfirmPageState extends State<RegisterConfirmPage> with StoreWatcherMixin<RegisterConfirmPage> {
  final double topHeight = 48;
  final double bottomHeight = 76;

  late AuthenticationStore authenticationStore;
  RegistrationDetail? registrationDetail;
  String? error;
  bool requesting;

  _RegisterConfirmPageState() :
    this.requesting = false,
    super();
  
  @override
  void initState() {
    super.initState();
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    this.registrationDetail = this.authenticationStore.registrationDetail;
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        widget.setBarStyle();
        return object;
      });
  }
  register(BuildContext context) {
    setState(() => this.requesting = true);
    final registrationName = this.registrationDetail?.name;
    final registrationEmail = this.registrationDetail?.email;
    if(registrationName != null && registrationEmail != null) {
      authenticationStore.registerMobile(
        registrationName,
        registrationEmail
      )
        .catchError((error) =>
          setError(error.message)
        )
        .whenComplete(() => 
          setState(() => this.requesting = false)
        );
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
    
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
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
                        child: Text(
                          'Please confirm the following details',
                          style: Theme.of(context).textTheme.headline3
                        )
                      ),
                      Table(
                        border: TableBorder.symmetric(
                          outside: borderSide
                        ),
                        columnWidths: {
                          0: FixedColumnWidth(34),
                          2: FixedColumnWidth(40),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          _FieldDetailData(
                            icon: PersonIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground),
                            label: 'Name',
                            value: this.registrationDetail?.name
                          ),
                          _FieldDetailData(
                            icon: EmailIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground),
                            label: 'Email Address',
                            value: this.registrationDetail?.email
                          )
                        ]
                        .asMap().entries
                        .expand((entry) {
                          final fieldDetailData = entry.value;
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
                                  padding: EdgeInsets.all(4) + EdgeInsets.only(top:12, left:8, right:4),
                                  child: fieldDetailData.icon
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:12),
                                  child: Text(
                                    fieldDetailData.label,
                                    style: Theme.of(context).textTheme.caption
                                  )
                                )
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
                                    fieldDetailData.value?? '',
                                    style: Theme.of(context).textTheme.headline5
                                  )
                                )
                              ]
                            )
                          ];
                        })
                        .toList()
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
                      '05/05',
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
class _FieldDetailData {
  Widget icon;
  String label;
  String? value;
  _FieldDetailData({
    required this.icon,
    required this.label,
    this.value,
  });
}