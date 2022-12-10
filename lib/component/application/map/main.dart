import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:app_settings/app_settings.dart';

import '../../../store/main.dart';
import '../../../store/locker.dart';
import '../../../util/geolocation.dart';
import '../../common/loading.dart';
import '../../common/button.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/dialog/location-permission.dart';
import '../../../asset/graphic/icon/fix-location.dart';
import '../../main.dart';
import './interact-locker.dart';

final interactDistance = 0.03;
class MapPage extends StatefulWidget {
  final void Function(String) navigateTab;
  MapPage({
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
  State<StatefulWidget> createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> with StoreWatcherMixin<MapPage>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final double topHeight = 0;
  final double bottomHeight = 0;
  GlobalKey _map = GlobalKey();
  GlobalKey _permissionDialog = GlobalKey();
  MapboxMapController? _controller;
  late AnimationController _lockController;
  late AnimationController _actionButtonController;

  bool mount;
  CameraPosition? camera;
  LatLng? position;
  bool lockedPosition;
  bool locationLoading;
  bool permissionGranted;
  late LockerStore lockerStore;
  List<Locker>? lockers;
  bool lockersLoading;
  List<Symbol>? lockerPointers;
  String? lockersError;
  Locker? nearbyLocker;
  _Hint? hint;

  _MapPageState() :
    this.mount = false,
    this.lockedPosition = true,
    this.locationLoading = true,
    this.permissionGranted = false,
    this.lockersLoading = true,
    super();

  @override
  void initState() {
    super.initState();
    this.mount = true;
    this._lockController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:600),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    this._actionButtonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    lockerStore = listenToStore(lockerStoreToken, (store) {
      final lockerStore = store as LockerStore;
      setState(() {
        this.lockers = lockerStore.lockers;
        if(!this.locationLoading) {
          this.addPointers();
          if(this.position != null) {
            this.showMapHint(this.position!);
          }
        }
      });
    }) as LockerStore;
    this.lockers = lockerStore.lockers;
    Future.wait([
      this.getLocation(), this.getLockers()
    ]).then((results) {
      if(this.position != null && this.lockers != null) {
        this.showMapHint(this.position!);
      }
    });
  }
  @override
  void dispose() {
    this.mount = false;
    lockerStore.unsubscribeLockersOnline();
    this._lockController.dispose();
    this._actionButtonController.dispose();
    super.dispose();
  }
  @override
  bool get wantKeepAlive => true;
  @override
  setState(void Function() fn) {
    if(this.mount) super.setState(fn);
  }
  Future getLocation({
    bool? retry
  }) async {
    try {
      if(retry == true) {
        this.setState(() {
          this.locationLoading = true;
        });
      }
      LocationPermission? permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied) {
        permission = await showLocationPermissionDialog(
          key: this._permissionDialog,
          context: context
        );
      } else if(retry == true && permission == LocationPermission.deniedForever) {
        await AppSettings.openLocationSettings();
      }
      if(![LocationPermission.whileInUse, LocationPermission.always].contains(permission)) {
        throw new ApplicationInterfaceError('Permission not granted');
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(minutes:1)
      );
      this.setState(() {
        this.position = LatLng(position.latitude, position.longitude);
        this.camera = CameraPosition(
          target: this.position!,
          zoom: 14.0
        );
        this.permissionGranted = true;
      });
    } catch(error) {
      this.setState(() {
        this.locationLoading = false; 
        this.permissionGranted = false;
      });
    }
  }
  Future getLockers() async {
    this.setState(() => this.lockersLoading = true);
    try {
      this.lockers = await lockerStore.getLockers();
      this.setState(() => this.lockersLoading = false);
      lockerStore.subscribeLockersOnline();
      if (this._controller != null) {
        await this.initializePointers();
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        this.setState(() {
          this.lockersLoading = false;
          this.lockersError = error.message;
        });
      } else {
        this.setState(() {
          this.lockersLoading = false;
          this.lockersError = 'Something went wrong with retrieving your informations';
        });
      }
    }
  }
  
  onMapCreated(MapboxMapController controller) async {
    this._controller = controller;
    if(Platform.isIOS) {
      await this.initializePointers();
    }
  }
  onMapLoaded() async {
    if(!Platform.isIOS) {
      await this.initializePointers();
    }
  }
  initializePointers() async {
    final cameraController = this._controller;
    if (cameraController != null) {
      final icons = [
        'locker-online',
        'locker-offline'
      ];
      await Future.wait(
        icons.map((icon) async {
          final bytes = await rootBundle.load('lib/asset/image/$icon.png');
          await cameraController.addImage(icon, bytes.buffer.asUint8List());
        })
      );
      this.addPointers();
      this.setState(() => this.locationLoading = false);
    }
  }
  addPointers() async {
    final cameraController = this._controller;
    if (this.lockerPointers != null) {
      await cameraController?.removeSymbols(this.lockerPointers!);
    }
    if (cameraController != null) {
      final pointerOptions = await this.getLockerPointers();
      this.lockerPointers = await cameraController.addSymbols(pointerOptions);
    }
  }
  showMapHint(LatLng position) {
    this.position = position;
    final getLatLng = (Locker locker) => LatLng(locker.latitude, locker.longitude);
    final nearestLocker = this.lockers?.fold<Locker?>(null, (nearestLocker, locker) =>
      nearestLocker == null ||
      getDistanceBetweenPoints(position, getLatLng(nearestLocker)) > getDistanceBetweenPoints(position, getLatLng(locker))
        ? locker
        : nearestLocker
    );
    final nextNearbyLocker = nearestLocker != null && getDistanceBetweenPoints(position, getLatLng(nearestLocker)) <= interactDistance
      ? nearestLocker : null;
    if(
      nextNearbyLocker?.id != nearbyLocker?.id ||
      nextNearbyLocker?.online != nearbyLocker?.online
    ) {
      this._actionButtonController.animateTo(
        nextNearbyLocker != null && nextNearbyLocker.online? 1:0
      );
      this.setState(() {
        this.hint = nextNearbyLocker == null
          ? _Hint(
              text: 'Move closer to a locker to interact with it...',
              color: Theme.of(context).colorScheme.secondary
            )
          : nextNearbyLocker.online
          ? _Hint(
              text: 'Interact with ${nextNearbyLocker.name}',
              color: Theme.of(context).colorScheme.secondary
            )
          : _Hint(
              text: 'Sorry...${nextNearbyLocker.name} is currently offline',
              color: Theme.of(context).colorScheme.error
            );
        this.nearbyLocker = nextNearbyLocker != null
          ? Locker.from(nextNearbyLocker)
          : null;
      });
    }
  }
  Future<List<SymbolOptions>> getLockerPointers() async {
    final haloColor = '#' + Theme.of(context).colorScheme.surface.value.toRadixString(16).substring(2, 8);
    final density = MediaQuery.of(context).devicePixelRatio;

    return this.lockers?.map((locker) {
      final color = locker.online
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.error;
      final colorCode = '#' + color.value.toRadixString(16).substring(2, 8);
      final opacity = locker.online? 1.0:0.8;
      return SymbolOptions(
        iconImage: locker.online? 'locker-online':'locker-offline',
        iconSize: (Platform.isIOS? 1:2.5) / density,
        iconAnchor: 'center',
        iconColor: colorCode,
        iconHaloColor: haloColor,
        iconHaloWidth: 3,
        iconOpacity: opacity,
        geometry: LatLng(locker.latitude, locker.longitude),
        textField: locker.name.toUpperCase(),
        textOffset: Offset(1 / density + 0.3, 0),
        textAnchor: 'left',
        textColor: colorCode,
        textHaloColor: haloColor,
        textHaloWidth: 1,
        textOpacity: opacity
      );
    }).toList()?? [];
  }

  lockPosition() {
    this.lockedPosition = true;
    this._lockController.animateTo(0.0);
    if(this.position != null) {
      this._controller?.animateCamera(CameraUpdate.newLatLngZoom(this.position!, 14.0));
    }
    Timer(Duration(milliseconds:300), () => 
      this._controller?.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking)
    );
  }
  unlockPosition() {
    this.lockedPosition = false;
    this._lockController.animateTo(1.0);
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && (
          object.toPath.contains('progress') || object.toPath.contains('profile')
        )) {
          final path = object.toPath.firstWhere((path) => ['progress', 'profile'].contains(path));
          widget.navigateTab(path);
        }
        if(object is NavigationPopResult && object.toPath.contains('map') && object.refresh) {
          this.setState(() => this.lockersLoading = true);
          this.getLockers();
        }
        widget.setBarStyle();
        return object;
      });
  }
  navigateToPlaceOrder() {
    if (this.nearbyLocker != null) {
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => InteractLockerPage(
          lockerId: this.nearbyLocker!.id
        )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetTop = deviceData.viewInsets.top;
    final insetBottom = deviceData.viewInsets.bottom;

    final loading = this.locationLoading || this.lockersLoading;
    super.build(context);
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: AnimatedBuilder(
          animation: Listenable.merge([this._lockController, this._actionButtonController]),
          child: AnimatedOpacity(
            key: this._map,
            opacity: !loading && this.permissionGranted == true && this.lockersError == null? 1:0,
            duration: Duration(milliseconds:300),
            child: this.camera != null
              ? MapboxMap(
                  onMapCreated: this.onMapCreated,
                  onStyleLoadedCallback: this.onMapLoaded,
                  styleString: 'mapbox://styles/chingyawhao/ckf15nxvm2ov31at0gch9sei9',
                  accessToken: FlutterConfig.get('MAPBOX_ACCESS_TOKEN'),
                  initialCameraPosition: this.camera!,
                  trackCameraPosition: true,
                  myLocationEnabled: true,
                  myLocationRenderMode: MyLocationRenderMode.NORMAL,
                  myLocationTrackingMode: this.lockedPosition
                    ? MyLocationTrackingMode.Tracking
                    : MyLocationTrackingMode.None,
                  onUserLocationUpdated: (location) => this.showMapHint(location.position),
                  onCameraTrackingDismissed: this.unlockPosition,
                  compassEnabled: true,
                  compassViewMargins: math.Point(8, top + insetTop + 8),
                  logoViewMargins: math.Point(8, bottom + insetBottom + 56),
                  attributionButtonMargins: math.Point(8, bottom + insetBottom + 56),
                )
              : null
          ),
          builder: (context, child) =>
            Stack(
              children: <Widget?>[
                AnimatedOpacity(
                  opacity: loading? 1:0,
                  duration: Duration(milliseconds:300),
                  child: Center(
                    child: LoadingText(),
                  )
                ),
                child,
                Positioned(
                  top: top + 32,
                  width: width,
                  child: Center(
                    child: Container(
                      width: [width, 360.0].reduce(math.min),
                      child: _MapHint(
                        hint: this.hint
                      )
                    )
                  ),
                ),
                Positioned(
                  left: Tween(begin:-76.0, end:12.0).evaluate(this._lockController),
                  bottom: bottom + 60 + 88,
                  height: 64,
                  width: 64,
                  child: MapButton(
                    onTap: this.lockPosition,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.8)
                      ),
                      child: Center(
                        child: FixLocationIcon(
                          size: Size.square(32),
                          color: Theme.of(context).colorScheme.onSurface
                        )
                      ),
                    )
                  )
                ),
                Positioned(
                  height: 44,
                  width: width,
                  bottom: Tween(begin:-60.0, end:bottom + 88.0).evaluate(this._actionButtonController),
                  child: Center(
                    child: Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:48),
                      child: Button(
                        onTap: this.navigateToPlaceOrder,
                        label: 'INTERACT'
                      )
                    )
                  )
                ),
                // Positioned(
                //   height: top + height + bottom,
                //   width: width,
                //   child: Container(
                //     width: [width, 360.0].reduce(math.min),
                //     padding: EdgeInsets.symmetric(horizontal:32, vertical:16),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           'Latitude: ${position?.latitude}\n' +
                //           'Longitude: ${position?.longitude}',
                //           textAlign: TextAlign.center,
                //           style: Theme.of(context).textTheme.headline5
                //         )
                //       ]
                //     )
                //   )
                // ),
                Positioned(
                  height: top + height + bottom,
                  width: width,
                  child: AnimatedOpacity(
                    opacity: !loading && (
                      this.permissionGranted == false || this.lockersError != null
                    )? 1:0,
                    duration: Duration(milliseconds:300),
                    child: Container(
                      width: [width, 360.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:32, vertical:16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            this.permissionGranted == false
                              ? 'hy{pe}gienic needs your location to find you a nearby locker'
                              : this.lockersError ?? '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5
                          ),
                          Touchable(
                            onTap: () => this.getLocation(retry:true),
                            padding: EdgeInsets.symmetric(
                              vertical: Theme.of(context).buttonTheme.padding.vertical,
                              horizontal: Theme.of(context).buttonTheme.padding.horizontal
                            ),
                            child: Center(
                              child: Text(
                                'Retry request permission',
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
                  )
                )
              ].whereType<Widget>().toList()
            ),
        )
      )
    );
  }
}

class MapButton extends StatefulWidget {
  final Key? key;
  final void Function()? onTap;
  final Widget child;
  MapButton({
    this.key,
    this.onTap,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _MapButtonState();
}
class _MapButtonState extends State<MapButton> with SingleTickerProviderStateMixin {
  late AnimationController tapController;

  @override
  void initState() {
    super.initState();
    this.tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    this.tapController.addListener(() =>
      setState(() {})
    );
  }
  @override
  void dispose() {
    this.tapController.dispose();
    super.dispose();
  }

  bool _tapped = false;
  void onTap(Direction direction) {
    if(direction == Direction.Down) {
      final complete = this.tapController.animateTo(1);
      this._tapped = true;
      complete.then((_) {
        if(!this._tapped) this.tapController.animateTo(0);
        else this._tapped = false;
      });
    } else {
      if(this._tapped) this._tapped = false;
      else this.tapController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.key,
      onTapDown: (event) => this.onTap(Direction.Down),
      onTapUp: (event) => this.onTap(Direction.Up),
      onTapCancel: () => this.onTap(Direction.Up),
      onTap: widget.onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            Tween(begin:1.0, end:0.8).evaluate(this.tapController)
          ),
        child: widget.child
      )
    );
  }
}

class _Hint {
  String text;
  Color color;
  _Hint({
    required this.text,
    required this.color
  });
}
class _MapHint extends StatefulWidget {
  final Key? key;
  final _Hint? hint;
  _MapHint({
    this.key,
    this.hint,
  });

  @override
  State<StatefulWidget> createState() => _MapHintState();
}
class _MapHintState extends State<_MapHint> with TickerProviderStateMixin {
  late AnimationController textController;

  final duration = Duration(milliseconds:600);
  _Hint? hint;
  _Hint? previousHint;
  TickerFuture? currentAnimation;

  @override
  void initState() {
    super.initState();
    this.textController = AnimationController(
      vsync: this,
      duration: this.duration,
      value: 1.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    this.textController.addListener(() =>
      setState(() {})
    );
    this.hint = widget.hint;
  }
  @override
  void didUpdateWidget(_MapHint self) {
    super.didUpdateWidget(self);
    if(widget.hint?.text != self.hint?.text) {
      final previousHint = self.hint;
      final hint = widget.hint;
      (this.currentAnimation?? Future.value()).whenComplete(() {
        setState(() {
          this.textController.value = 0;
          this.previousHint = previousHint;
          this.hint = hint;
        });
        this.currentAnimation = this.textController.animateTo(1);
      });
    }
  }
  @override
  void dispose() {
    this.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildText = (String? text, TextStyle? style) =>
      Container(
        padding: EdgeInsets.symmetric(vertical:16),
        child: Text(
          text?? '',
          textAlign: TextAlign.center,
          style: style
        )
      );
    return ClipPath(
      clipper: _MapHintClipper(),
      child: AnimatedSize(
        vsync: this,
        duration: this.duration,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(),
            Opacity(
              opacity: 0,
              child: buildText(
                this.hint?.text,
                Theme.of(context).textTheme.headline5
              )
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buildPositioned = (double top, Widget child) =>
                    Positioned(
                      top: top,
                      left: 0, right: 0,
                      child: child
                    );
                  final outlineStyle = Theme.of(context).textTheme.headline5?.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Color.fromRGBO(255, 255, 255, 1)
                  );
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      buildPositioned(
                        - constraints.biggest.height * this.textController.value,
                        buildText(
                          this.previousHint?.text,
                          outlineStyle
                        )
                      ),
                      buildPositioned(
                        constraints.biggest.height * Tween(begin:1.0, end:0.0).evaluate(this.textController),
                        buildText(
                          this.hint?.text,
                          outlineStyle
                        )
                      ),
                      buildPositioned(
                        - constraints.biggest.height * this.textController.value,
                        buildText(
                          this.previousHint?.text,
                          Theme.of(context).textTheme.headline5?.copyWith(
                            color: this.previousHint?.color
                          )
                        )
                      ),
                      buildPositioned(
                        constraints.biggest.height * Tween(begin:1.0, end:0.0).evaluate(this.textController),
                        buildText(
                          this.hint?.text,
                          Theme.of(context).textTheme.headline5?.copyWith(
                            color: this.hint?.color
                          )
                        )
                      )
                    ]
                  );
                }
              )
            )
          ]
        )
      )
    );
  }
}
class _MapHintClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 16)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 16)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}