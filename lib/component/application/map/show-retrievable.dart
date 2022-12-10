import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Checkbox;
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/authentication.dart';
import '../../../store/locker.dart';
import '../../../store/progress.dart';
import '../../../asset/graphic/illustration/empty.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/stripe.dart';
import '../../common/button.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/inline-error.dart';
import '../../common/input/checkbox.dart';
import '../../main.dart';
import './confirm-retrieve.dart';

class ShowRetrievablePage extends StatefulWidget {
  final String lockerId;
  ShowRetrievablePage({
    required this.lockerId
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
  State<StatefulWidget> createState() => _ShowRetrievablePageState();
}
class _ShowRetrievablePageState extends State<ShowRetrievablePage> with StoreWatcherMixin<ShowRetrievablePage> {
  final double topHeight = 48;

  late AuthenticationStore authenticationStore;
  late LockerStore lockerStore;
  late ProgressStore progressStore;
  List<ProgressSimple>? progresses;
  ProgressSimple? selected;
  String? error;
  bool loading;

  _ShowRetrievablePageState() :
    this.loading = true,
    super();

  @override
  void initState() {
    super.initState();
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    lockerStore = listenToStore(lockerStoreToken) as LockerStore;
    progressStore = listenToStore(progressStoreToken, (store) {
      final progressStore = store as ProgressStore;
      setState(() {
        this.progresses = progressStore.retrievableProgresses(widget.lockerId);
      });
    }) as ProgressStore;
    this.getProgresses();
  }
  @override
  dispose() {
    super.dispose();
  }
  getProgresses() async {
    await progressStore.getRetrievableProgress(widget.lockerId);
    this.setState(() => this.loading = false);
  }

  selectProgress(ProgressSimple progress) {
    this.setState(() => this.selected = progress);
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('show-retrievable')) {
          Navigator.pop(context, object);
        }
        if(object is NavigationPopResult && object.toPath.contains('show-retrievable') && object.refresh) {
          setState(() => this.loading = true);
          this.getProgresses();
        }
        widget.setBarStyle();
        return object;
      });
  }
  navigateToMap(BuildContext context) {
    Navigator.pop(context, NavigationPopResult(
      toPath: ['map']
    ));
  }

  confirm(BuildContext context) async {
    final selected = this.selected;
    if(selected != null) {
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => ConfirmRetrievePage(
          progress: selected
        )
      ));
    } else {
      setError('Please select an option');
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
    final blank = (this.progresses?.length ?? 0) == 0;
    final bottomHeight = blank? 0.0:76.0;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: AnimatedOpacity(
          opacity: this.loading? 0:1,
          duration: Duration(milliseconds:300),
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
                  child: !blank
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical:16, horizontal:24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom:24),
                              child: Text(
                                'Which one to retrieve?',
                                style: Theme.of(context).textTheme.headline3
                              )
                            ),
                            ...this.progresses
                              ?.asMap().entries
                              .map((entry) {
                                final progress = entry.value;
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical:4),
                                  child: Checkbox(
                                    checked: this.selected?.id == progress.id,
                                    onCheck: () => this.selectProgress(progress),
                                    label: progress.name,
                                  )
                                );
                              })
                              .toList()?? []
                          ]
                        )
                      )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: [width - 48, 192.0].reduce(math.min),
                          height: [width - 96, 144.0].reduce(math.min),
                          padding: EdgeInsets.symmetric(horizontal:24),
                          child: EmptyIllustration(
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ),
                        Container(
                          width: [width - 48, 192.0].reduce(math.min),
                          padding: EdgeInsets.only(bottom:16),
                          child: Text(
                            "It's empty here",
                            style: Theme.of(context).textTheme.headline5
                          )
                        ),
                        Container(
                          width: [width - 48, 192.0].reduce(math.min),
                          height: 40.0,
                          padding: EdgeInsets.only(bottom:8),
                          child: Stripes(
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ),
                        Container(
                          width: [width - 48, 192.0].reduce(math.min),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.onBackground,
                                width: 2
                              )
                            )
                          ),
                          padding: EdgeInsets.only(bottom:16),
                          child: Text(
                            "404 NOT FOUND",
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              fontSize: 12
                            )
                          )
                        ),
                        Touchable(
                          onTap: () => this.navigateToMap(context),
                          padding: EdgeInsets.symmetric(
                            vertical: Theme.of(context).buttonTheme.padding.vertical,
                            horizontal: Theme.of(context).buttonTheme.padding.horizontal
                          ),
                          child: Center(
                            child: Text(
                              'Back to map',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button?.copyWith(
                                color: Theme.of(context).colorScheme.primary
                              )
                            )
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
                        '01/03',
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
                        onTap: () => this.confirm(context),
                        label: 'CONFIRM'
                      )
                    )
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}
