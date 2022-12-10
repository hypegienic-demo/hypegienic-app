import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../asset/graphic/icon/person.dart';
import '../../../asset/graphic/icon/wallet.dart';
import '../../../asset/graphic/icon/mobile.dart';
import '../../../asset/graphic/icon/email.dart';
import '../../../asset/graphic/icon/edit.dart';
import '../../../asset/graphic/icon/add.dart';
import '../../../store/authentication.dart';
import '../../common/input/mobile-field.dart';
import '../../common/loading.dart';
import '../../common/stripe.dart';
import '../../common/button.dart';
import '../../main.dart';
import './edit-name.dart';
import './edit-email.dart';
import './top-up-amount.dart';


class ProfilePage extends StatefulWidget {
  final void Function(String) navigateTab;
  ProfilePage({
    required this.navigateTab
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
  State<StatefulWidget> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> with StoreWatcherMixin<ProfilePage> {
  final double topHeight = 0;
  final double bottomHeight = 0;

  bool mount;
  late AuthenticationStore authenticationStore;
  User? profile;
  bool loading;

  _ProfilePageState() :
    this.mount = false,
    this.loading = true,
    super();

  @override
  void initState() {
    super.initState();
    this.mount = true;
    authenticationStore = listenToStore(authenticationStoreToken, (store) {
      final authenticationStore = store as AuthenticationStore;
      setState(() {
        this.profile = authenticationStore.profile;
      });
    }) as AuthenticationStore;
    this.getProfile();
  }
  @override
  dispose() {
    this.mount = false;
    super.dispose();
  }
  @override
  setState(void Function() fn) {
    if(this.mount) super.setState(fn);
  }
  getProfile() async {
    await authenticationStore.getUserProfile();
    setState(() => this.loading = false);
  }

  signOut() async {
    await authenticationStore.signOut();
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && (
          object.toPath.contains('map') || object.toPath.contains('progress')
        )) {
          final path = object.toPath.firstWhere((path) => ['map', 'progress'].contains(path));
          widget.navigateTab(path);
        }
        if(object is NavigationPopResult && object.toPath.contains('profile') && object.refresh) {
          setState(() => this.loading = true);
          this.getProfile();
        }
        widget.setBarStyle();
        return object;
      });
  }
  void navigateToEditName() {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => EditNamePage()
    ));
  }
  void navigateToEditEmail() {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => EditEmailPage()
    ));
  }
  void navigateToTopUpAmount() {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => TopUpAmountPage()
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

    final profile = this.profile;
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
    );
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: this.loading? 1:0,
              duration: Duration(milliseconds:300),
              child: Center(
                child: LoadingText(),
              )
            ),
            AnimatedOpacity(
              opacity: this.loading? 0:1,
              duration: Duration(milliseconds:300),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) +
                  EdgeInsets.symmetric(vertical:24, horizontal:32),
                child: ConstrainedBox(
                  constraints: new BoxConstraints(
                    minWidth: width,
                    minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom:bottom + bottomHeight + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical:24),
                          child: Text(
                            'PROFILE',
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
                              value: profile?.displayName,
                              onEdit: this.navigateToEditName
                            ),
                            _FieldDetailData(
                              icon: WalletIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground),
                              label: 'Wallet',
                              value: profile != null
                                ? 'RM${profile.walletBalance.toStringAsFixed(2)}'
                                : null,
                              onAdd: this.navigateToTopUpAmount
                            ),
                            _FieldDetailData(
                              icon: MobileIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground),
                              label: 'Mobile Number',
                              value: profile != null
                                ? '+60' + getConformedMobileNumber(profile.mobileNumber.replaceAll(RegExp('^\\+60'), ''))
                                : null
                            ),
                            _FieldDetailData(
                              icon: EmailIcon(size:Size.square(14), color:Theme.of(context).colorScheme.onBackground),
                              label: 'Email Address',
                              value: this.profile?.emailAddress,
                              onEdit: this.navigateToEditEmail
                            )
                          ]
                            .asMap().entries
                            .expand((entry) {
                              final fieldDetailData = entry.value;
                              final valueText = Padding(
                                padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(bottom:8),
                                child: Text(
                                  fieldDetailData.value?? '',
                                  style: Theme.of(context).textTheme.headline5
                                )
                              );
                              final action = fieldDetailData.onEdit ?? fieldDetailData.onAdd;
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
                                      padding: EdgeInsets.all(4) + EdgeInsets.only(top:8, left:8, right:4),
                                      child: fieldDetailData.icon
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:8),
                                      child: Text(
                                        fieldDetailData.label,
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
                                        padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:8, left:8, right:4),
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
                                    action != null
                                      ? GestureDetector(
                                          onTap: action,
                                          child: valueText
                                        )
                                      : valueText,
                                    action != null
                                      ? GestureDetector(
                                          onTap: action,
                                          child: Padding(
                                            padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:8, left:4, right:8),
                                            child: fieldDetailData.onEdit != null
                                              ? EditIcon(
                                                  size: Size.square(20),
                                                  color: Theme.of(context).colorScheme.onBackground
                                                )
                                              : AddIcon(
                                                  size: Size.square(20),
                                                  color: Theme.of(context).colorScheme.onBackground
                                                )
                                          )
                                        )
                                      : Container()
                                  ]
                                )
                              ];
                            })
                            .toList()
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical:24) + EdgeInsets.only(top:24),
                          child: Table(
                            children: [
                              TableRow(
                                children: [
                                  Button(
                                    onTap: () {
                                      launch('https://www.hypegienic.com/terms-and-condition');
                                    },
                                    label: 'Term of Use',
                                    sideBorders: ButtonSideBorders(
                                      right: ButtonSideBorder.bordered
                                    )
                                  ),
                                  Button(
                                    onTap: this.signOut,
                                    label: 'Log Out',
                                    highlightColor: Theme.of(context).colorScheme.onBackground,
                                    sideBorders: ButtonSideBorders(
                                      left: ButtonSideBorder.extruded
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
                )
              )
            )
          ]
        )
      )
    );
  }
}
class _FieldDetailData {
  Widget icon;
  String label;
  String? value;
  void Function()? onEdit;
  void Function()? onAdd;
  _FieldDetailData({
    required this.icon,
    required this.label,
    this.value,
    this.onEdit,
    this.onAdd
  });
}