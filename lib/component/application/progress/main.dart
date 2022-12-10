import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide ExpandIcon;
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/authentication.dart';
import '../../../store/progress.dart';
import '../../../asset/graphic/illustration/empty.dart';
import '../../../asset/graphic/icon/shoe.dart';
import '../../../asset/graphic/icon/expand.dart';
import '../../common/stripe.dart';
import '../../common/loading.dart';
import '../../common/alert.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/dialog/notification-permission.dart';
import '../service/main.dart';
import '../../main.dart';
import './detail.dart';

class ProgressPage extends StatefulWidget {
  final void Function(String) navigateTab;
  ProgressPage({
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
  State<StatefulWidget> createState() => _ProgressPageState();
}
class _ProgressPageState extends State<ProgressPage> with StoreWatcherMixin<ProgressPage> {
  final double topHeight = 0;
  final double bottomHeight = 0;

  bool mount;
  late AuthenticationStore authenticationStore;
  late ProgressStore progressStore;
  List<ProgressSimple>? progresses;
  bool loading;

  _ProgressPageState() :
    this.mount = false,
    this.loading = true,
    super();

  @override
  void initState() {
    super.initState();
    this.mount = true;
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    progressStore = listenToStore(progressStoreToken, (store) {
      final progressStore = store as ProgressStore;
      setState(() {
        this.progresses = progressStore.progresses;
      });
    }) as ProgressStore;
    this.getProgresses();
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
  getProgresses() async {
    final progresses = await progressStore.getProgresses();
    setState(() => this.loading = false);
    if(progresses.length > 0) {
      this.checkNotificationPermission();
    }
  }
  checkNotificationPermission() async {
    try {
      final canRequest = await authenticationStore.checkCanRequestNotification();
      if(canRequest) {
        await showNotificationPermissionDialog(
          context: context
        );
      }
    } catch(error) {}
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && (
          object.toPath.contains('map') || object.toPath.contains('profile')
        )) {
          final path = object.toPath.firstWhere((path) => ['map', 'profile'].contains(path));
          widget.navigateTab(path);
        }
        if(object is NavigationPopResult && object.toPath.contains('progress') && object.refresh) {
          setState(() => this.loading = true);
          this.getProgresses();
        }
        widget.setBarStyle();
        return object;
      });
  }
  navigateToDetail(String progressId) {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => ProgressDetailPage(
        progressId: progressId
      )
    ));
  }
  navigateToService() {
    this.navigate<NavigationPopResult>(context, MaterialPageRoute(
      builder: (context) => ServicesPage()
    ));
  }
  navigateToMap() {
    widget.navigateTab('map');
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;

    final progresses = this.progresses
      ?..sort((progress1, progress2) =>
        (progress2.time?.millisecondsSinceEpoch?? 0) - (progress1.time?.millisecondsSinceEpoch?? 0)
      );
    final inProgresses = progresses
      ?.where((progress) => progress.status != 'retrieved-back')
      .toList();
    final retrievedProgresses = progresses
      ?.where((progress) => progress.status == 'retrieved-back')
      .toList();
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
                    child: (this.progresses?.length?? 0) > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical:24),
                              child: Text(
                                'PROGRESS',
                                style: Theme.of(context).textTheme.headline3
                              )
                            ),
                            ...(inProgresses?.length?? 0) > 0
                              ? [
                                  Padding(
                                    padding: EdgeInsets.only(bottom:24),
                                    child: Table(
                                      border: TableBorder.symmetric(
                                        outside: borderSide
                                      ),
                                      columnWidths: {
                                        0: FixedColumnWidth(34),
                                        2: FixedColumnWidth(40),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: inProgresses
                                        ?.asMap().entries
                                        .map((entry) {
                                          final progress = entry.value;
                                          final navigateToProgress = () => this.navigateToDetail(progress.id);
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
                                                  child: ShoeIcon(
                                                    size: Size.square(14),
                                                    color: Theme.of(context).colorScheme.onBackground
                                                  )
                                                ),
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:8),
                                                    child: Text(
                                                      progress.name,
                                                      style: Theme.of(context).textTheme.caption
                                                    )
                                                  )
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4) + EdgeInsets.only(top:8, left:6, right:14),
                                                    child: ProgressUpdate(
                                                      progress: progress
                                                    )
                                                  )
                                                )
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
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding:EdgeInsets.only(right:4),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          getProgressDescription(progress),
                                                          style: Theme.of(context).textTheme.headline5
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(vertical:8) +
                                                            EdgeInsets.only(bottom:4),
                                                          child: CustomPaint(
                                                            foregroundPainter: ProgressBarPainter(
                                                              color: Theme.of(context).colorScheme.secondary,
                                                              progress: getProgressPercentage(progress)?? 0
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical:1.3),
                                                              child: Container(
                                                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                                                                height: 2,
                                                              )
                                                            )
                                                          )
                                                        )
                                                      ]
                                                    )
                                                  )
                                                ),
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:8, left:4, right:8),
                                                    child: ExpandIcon(
                                                      size: Size.square(20),
                                                      color: Theme.of(context).colorScheme.onBackground
                                                    )
                                                  )
                                                )
                                              ]
                                            )
                                          ];
                                        })
                                        .expand((widgets) => widgets.whereType<TableRow>())
                                        .toList()?? []
                                    )
                                  )
                                ]
                              : [],
                            Padding(
                              padding: EdgeInsets.only(bottom:12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Button(
                                    label: 'SERVICES',
                                    onTap: navigateToService
                                  )
                                ]
                              )
                            ),
                            ...(retrievedProgresses?.length?? 0) > 0
                              ? [
                                  Padding(
                                    padding: EdgeInsets.only(top:12, bottom:8),
                                    child: Text(
                                      'History',
                                      style: Theme.of(context).textTheme.headline5
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom:12),
                                    child: Table(
                                      border: TableBorder.symmetric(
                                        outside: borderSide
                                      ),
                                      columnWidths: {
                                        0: FixedColumnWidth(34),
                                        2: FixedColumnWidth(40),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: retrievedProgresses
                                        ?.asMap().entries
                                        .map((entry) {
                                          final progress = entry.value;
                                          final navigateToProgress = () => this.navigateToDetail(progress.id);
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
                                                  child: ShoeIcon(
                                                    size: Size.square(14),
                                                    color: Theme.of(context).colorScheme.onBackground
                                                  )
                                                ),
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical:4) + EdgeInsets.only(top:8),
                                                    child: Text(
                                                      progress.name,
                                                      style: Theme.of(context).textTheme.caption
                                                    )
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
                                                          color: Theme.of(context).colorScheme.onBackground
                                                        )
                                                      )
                                                    )
                                                  )
                                                ),
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right:4, bottom:8),
                                                    child: Text(
                                                      getProgressDescription(progress),
                                                      style: Theme.of(context).textTheme.headline5
                                                    )
                                                  )
                                                ),
                                                GestureDetector(
                                                  onTap: navigateToProgress,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4) + EdgeInsets.only(bottom:8, left:4, right:8),
                                                    child: ExpandIcon(
                                                      size: Size.square(20),
                                                      color: Theme.of(context).colorScheme.onBackground
                                                    )
                                                  )
                                                )
                                              ]
                                            )
                                          ];
                                        })
                                        .expand((widgets) => widgets.whereType<TableRow>())
                                        .toList()?? []
                                    )
                                  )
                                ]
                              : []
                          ]
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
                          Container(
                            width: [width - 48, 192.0].reduce(math.min),
                            child: Button(
                              label: 'SERVICES',
                              onTap: navigateToService
                            )
                          ),
                          Touchable(
                            onTap: this.navigateToMap,
                            padding: EdgeInsets.symmetric(
                              vertical: Theme.of(context).buttonTheme.padding.vertical + 6,
                              horizontal: Theme.of(context).buttonTheme.padding.horizontal
                            ),
                            child: Center(
                              child: Text(
                                'Back to map',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.button?.copyWith(
                                  color: Theme.of(context).colorScheme.primaryVariant
                                )
                              )
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

String getProgressDescription(dynamic progress) {
  if(
    progress is ProgressSimple ||
    progress is ProgressEvent
  ) {
    switch(progress.type) {
    case 'locker': {
      switch(progress.status) {
      case 'opened-locker':
        return 'Opened locker at ${progress.openedAt?.name}';
      case 'deposited':
        return 'Dropped off at ${progress.openedAt?.name}';
      case 'retrieved-store':
        return 'On the way back to our store';
      case 'delivered-store':
        return 'Received and recorded in our physical store';
      case 'cleaned':
        return 'All cleaned up and prepared to be delivered';
      case 'delivered-back':
        return 'Delivered off to ${progress.depositedAt?.name} and ready to be retrieved';
      case 'retrieved-back':
        return 'Retrieved back';
      }
      break;
    }
    case 'physical': {
      switch(progress.status) {
      case 'deposited':
        return 'Dropped off in our store';
      case 'delivered-store':
        return 'Recorded in our physical store';
      case 'cleaned':
        return 'All cleaned up and ready to be retrieved';
      }
      break;
    }}
  }
  return '';
}
double? getProgressPercentage(ProgressSimple progress) {
  switch(progress.type) {
  case 'locker': {
    switch(progress.status) {
    case 'opened-locker':
      return 0.1;
    case 'deposited':
      return 0.3;
    case 'retrieved-store':
      return 0.4;
    case 'delivered-store':
      return 0.8;
    case 'cleaned':
      return 0.9;
    case 'delivered-back':
      return 1;
    }
    break;
  }
  case 'physical': {
    switch(progress.status) {
    case 'deposited':
      return 0.1;
    case 'delivered-store':
      return 0.2;
    case 'cleaned':
      return 1;
    }
    break;
  }}
  return null;
}

class ProgressUpdate extends StatefulWidget {
  final ProgressSimple progress;
  ProgressUpdate({
    required this.progress
  });

  @override
  State<StatefulWidget> createState() => _ProgressUpdateState();
}
class _ProgressUpdateState extends State<ProgressUpdate> {
  bool? showAlert;

  @override
  void initState() {
    super.initState();
    this.showAlert = widget.progress.update;
  }
  @override
  void didUpdateWidget(ProgressUpdate self) {
    super.didUpdateWidget(self);
    if(widget.progress.update != this.showAlert) {
      this.showAlert = widget.progress.update;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Alert(
      update: this.showAlert?? false
    );
  }
}
class ProgressBarPainter extends CustomPainter {
  final Color color;
  final double progress;
  ProgressBarPainter({
    required this.color,
    required this.progress
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = this.color;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * progress, 4),
      paint
    );
  }

  @override
  bool shouldRepaint(ProgressBarPainter self) {
    return self.progress != progress || self.color.toString() != color.toString();
  }
}