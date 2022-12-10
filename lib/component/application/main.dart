import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../asset/graphic/icon/map.dart';
import '../../asset/graphic/icon/shoe.dart';
import '../../asset/graphic/icon/person.dart';
import '../../store/progress.dart';
import '../common/alert.dart';
import './map/main.dart';
import './progress/main.dart';
import './profile/main.dart';

class ApplicationPage extends StatefulWidget {
  final void Function(ApplicationAction)? getAction;
  ApplicationPage({
    this.getAction
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
  State<StatefulWidget> createState() => _ApplicationPageState();
}
class _ApplicationPageState extends State<ApplicationPage> with StoreWatcherMixin<ApplicationPage>, SingleTickerProviderStateMixin {
  late ProgressStore progressStore;
  late TabController _tabController;
  bool progressUpdate;

  _ApplicationPageState() :
    this.progressUpdate = false,
    super();

  @override
  void initState() {
    super.initState();
    this.progressStore = listenToStore(progressStoreToken, (store) {
      final progressStore = store as ProgressStore;
      setState(() {
        this.progressUpdate = progressStore.update;
      });
    }) as ProgressStore;
    this._tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0
    );
    this.getProgressUpdate();
    if(widget.getAction != null) {
      widget.getAction!(ApplicationAction(
        navigateTab: this.navigateTab
      ));
    }
  }
  @override
  void didUpdateWidget(ApplicationPage self) {
    super.didUpdateWidget(self);
    if(widget.getAction != self.getAction && widget.getAction != null) {
      widget.getAction!(ApplicationAction(
        navigateTab: this.navigateTab
      ));
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getProgressUpdate() async {
    await this.progressStore.getUpdate();
  }
  navigateTab(String tab) {
    switch(tab) {
    case 'map':
      this.goToPage(0);
      return;
    case 'progress':
      this.goToPage(1);
      return;
    case 'profile':
      this.goToPage(2);
      return;
    }
  }
  goToPage(int index) {
    this._tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;

    final tabs = [
      _TabIconData(
        icon: MapIcon(size:Size.square(32), color:Theme.of(context).colorScheme.onBackground),
        label: 'Navigate'
      ),
      _TabIconData(
        icon: ShoeIcon(size:Size.square(32), color:Theme.of(context).colorScheme.onBackground),
        label: 'Progress',
        update: this.progressUpdate
      ),
      _TabIconData(
        icon: PersonIcon(size:Size.square(32), color:Theme.of(context).colorScheme.onBackground),
        label: 'Profile'
      )
    ];
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: <Widget?>[
            TabBarView(
              controller: this._tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                MapPage(
                  navigateTab: this.navigateTab
                ),
                ProgressPage(
                  navigateTab: this.navigateTab
                ),
                ProfilePage(
                  navigateTab: this.navigateTab
                )
              ],
            ),
            top > 0? Positioned(
              top: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: top,
                width: width
              )
            ):null,
            Positioned(
              width: width,
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal:24) + EdgeInsets.only(bottom:bottom + insetBottom),
                child: Row(
                  children: tabs
                    .asMap().entries
                    .map((entry) {
                      final index = entry.key;
                      final tabIconData = entry.value;
                      final tabController = this._tabController;
                      final tabWidth = (width - 48) / tabs.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => this.goToPage(index),
                          child: AnimatedBuilder(
                            animation: tabController.animation?? Listenable.merge([]),
                            builder: (context, child) =>
                              ClipPath(
                                clipper: _TabIconClipper(),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 48,
                                      color: Colors.transparent,
                                    ),
                                    Positioned(
                                      top: tabController.animation != null &&
                                        [tabController.index, tabController.previousIndex].contains(index)
                                        ? 48.0 * math.min((tabController.animation!.value - index).abs(), 1) - 48.0
                                        : 0.0,
                                      height: 96,
                                      width: tabWidth,
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 96,
                                            color: Colors.transparent,
                                          ),
                                          Positioned(
                                            top: 0,
                                            height: 48,
                                            width: tabWidth,
                                            child: Center(
                                              child: tabIconData.icon
                                            )
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: (tabWidth - 48) / 2,
                                            child: Alert(
                                              update: tabIconData.update
                                            )
                                          ),
                                          Positioned(
                                            top: 48,
                                            height: 48,
                                            width: tabWidth,
                                            child: Center(
                                              child: Text(
                                                tabIconData.label,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.caption?.copyWith(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  fontWeight: FontWeight.w600
                                                )
                                              )
                                            )
                                          ),
                                          Positioned(
                                            top: 82,
                                            height: 6,
                                            width: tabWidth,
                                            child: Center(
                                              child: CustomPaint(
                                                painter: _Triangle(
                                                  color: Theme.of(context).colorScheme.secondary
                                                ),
                                                child: Container(width:9, height:6)
                                              )
                                            )
                                          )
                                        ]
                                      )
                                    )
                                  ]
                                )
                              )
                          )
                        )
                      );
                    }).toList(),
                )
              )
            )
          ].whereType<Widget>().toList()
        )
      )
    );
  }
}
class _TabIconData {
  Widget icon;
  String label;
  bool update;
  _TabIconData({
    required this.icon,
    required this.label,
    bool? update
  }) :
    this.update = update == true;
}
class _TabIconClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 8)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 8)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _Triangle extends CustomPainter {
  final Color color;
  _Triangle({
    required this.color
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_Triangle oldDelagate) =>
    this.color != oldDelagate.color;
}

class ApplicationAction {
  void Function(String)? navigateTab;
  ApplicationAction({
    this.navigateTab
  });
}
