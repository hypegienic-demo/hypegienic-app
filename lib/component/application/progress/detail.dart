import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/main.dart';
import '../../../store/progress.dart';
import '../../../store/locker.dart';
import '../../../util/date.dart';
import '../../../util/geolocation.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/image/transparent.dart';
import '../../common/image/lightbox.dart';
import '../../common/button.dart';
import '../../common/stripe.dart';
import '../../common/touchable.dart' hide Direction;
import '../../common/inline-error.dart';
import '../map/show-locker.dart';
import '../map/show-retrievable.dart';
import '../map/main.dart';
import '../../main.dart';
import './main.dart';
import './add-coupon.dart';

class ProgressDetailPage extends StatefulWidget {
  final String progressId;
  ProgressDetailPage({
    required this.progressId
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
  State<StatefulWidget> createState() => _ProgressDetailPageState();
}
class _ProgressDetailPageState extends State<ProgressDetailPage> with StoreWatcherMixin<ProgressDetailPage> {
  final double topHeight = 48;
  final double bottomHeight = 0;

  bool mount;
  late ProgressStore progressStore;
  late LockerStore lockerStore;
  Progress? progress;
  bool loading;
  String? error;
  bool actionLoading;
  List<_KeyedImage>? imagesBefore;
  List<_KeyedImage>? imagesAfter;

  _ProgressDetailPageState() :
    this.mount = false,
    this.loading = true,
    this.actionLoading = false,
    super();

  @override
  void initState() {
    super.initState();
    this.mount = true;
    progressStore = listenToStore(progressStoreToken, (store) {
      final progressStore = store as ProgressStore;
      setState(() {
        this.progress = progressStore.progress(widget.progressId);
        final imagesBefore = this.progress?.imagesBefore;
        this.imagesBefore = imagesBefore != null
          ? imagesBefore.map((image) =>
              _KeyedImage(id:image.id, url:image.url)
            ).toList()
          : null;
        final imagesAfter = this.progress?.imagesAfter;
        this.imagesAfter = imagesAfter != null
          ? imagesAfter.map((image) =>
              _KeyedImage(id:image.id, url:image.url)
            ).toList()
          : null;
      });
    }) as ProgressStore;
    lockerStore = listenToStore(lockerStoreToken) as LockerStore;
    this.getProgress();
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
  getProgress() async {
    await progressStore.getProgress(widget.progressId);
    await progressStore.markReadNotifications(widget.progressId);
    setState(() => this.loading = false);
  }

  _ProgressAction? getProgressAction(Progress progress) {
    switch(progress.status) {
    case 'opened-locker':
      return _ProgressAction(
        message: 'A locker unit is opened waiting for your deposit confirmation.',
        label: 'CONTINUE',
        function: () async {
          try {
            this.setState(() {
              this.actionLoading = true;
            });
            final lockerUnit = progress.openedUnitId != null
              ? await this.lockerStore.getLockerUnit(progress.openedUnitId?? '')
              : null;
            if(lockerUnit != null) {
              this.setState(() {
                this.actionLoading = false;
              });
              this.navigate<NavigationPopResult>(context, MaterialPageRoute(
                builder: (context) => ShowLockerPage(
                  lockerUnitId: lockerUnit.id,
                )
              ));
            } else {
              throw ApplicationInterfaceError('Locker unit is no longer available');
            }
          } catch(error) {
            this.setState(() {
              this.actionLoading = false;
            });
            if(error is ApplicationInterfaceError) {
              this.setError(error.message);
            }
          }
        }
      );
    case 'delivered-back':
      return _ProgressAction(
        message: 'Your order is currently pending for your collection.',
        label: 'CONTINUE',
        function: () async {
          try {
            this.setState(() {
              this.actionLoading = true;
            });
            LocationPermission permission = await Geolocator.checkPermission();
            if(![LocationPermission.whileInUse, LocationPermission.always].contains(permission)) {
              permission = await Geolocator.requestPermission();
            }
            if(![LocationPermission.whileInUse, LocationPermission.always].contains(permission)) {
              throw new ApplicationInterfaceError('Permission not granted');
            }
            final locker = progress.depositedAt;
            if(locker != null) {
              final position = await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
              final distance = getDistanceBetweenPoints(
                LatLng(position.latitude, position.longitude),
                LatLng(locker.latitude, locker.longitude)
              );
              if(distance < interactDistance) {
                this.setState(() {
                  this.actionLoading = false;
                });
                this.navigate<NavigationPopResult>(context, MaterialPageRoute(
                  builder: (context) => ShowRetrievablePage(
                    lockerId: locker.id,
                  )
                ));
              } else {
                throw new ApplicationInterfaceError('Please move nearer to the locker');
              }
            }
          } catch(error) {
            this.setState(() {
              this.actionLoading = false;
            });
            if(error is ApplicationInterfaceError) {
              this.setError(error.message);
            }
          }
        }
      );
    default:
      return null;
    }
  }
  
  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('progress-detail')) {
          Navigator.pop(context, object);
        }
        if(object is NavigationPopResult && object.toPath.contains('progress-detail') && object.refresh) {
          setState(() => this.loading = true);
          this.getProgress();
        }
        widget.setBarStyle();
        return object;
      });
  }
  goBack(BuildContext context) {
    Navigator.pop(context);
  }
  void navigateToAddCoupon() {
    final progress = this.progress;
    if(progress != null) {
      this.navigate<NavigationPopResult>(context, MaterialPageRoute(
        builder: (context) => AddCouponPage(
          requestId: progress.request,
          services: progress.services
        )
      ));
    }
  }

  Timer? _errorTimer;
  setError(String message) {
    setState(() => this.error = message);
    this._errorTimer?.cancel();
    this._errorTimer = Timer(Duration(milliseconds:8000), () {
      setState(() => this.error = null);
    });
  }

  pressOnImage(_KeyedImage image) {
    final rendered = image.key.currentContext?.findRenderObject();
    final translation = rendered?.getTransformTo(null).getTranslation();
    final paintBounds = rendered?.paintBounds;
    if (translation != null && paintBounds != null) {
      final bounds = paintBounds
        .shift(Offset(translation.x, translation.y));
      showImageDialog(
        context:context,
        x:bounds.left, y:bounds.top,
        width:bounds.width, height:bounds.height,
        url:image.url,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.onBackground
          )
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;

    final progress = this.progress;
    final progressAction = progress != null
      ? this.getProgressAction(progress)
      : null;

    final displaySubheading = (String label) =>
      Padding(
        padding: EdgeInsets.only(top:24, bottom:8) + EdgeInsets.symmetric(horizontal:32),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headline5
        )
      );
    final displayImages = (List<_KeyedImage> images) =>
      SizedBox(
        height: 100,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal:32),
          scrollDirection: Axis.horizontal,
          children: images
            .asMap().entries
            .map((entry) {
              final borderSide = BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.onBackground
              );
              final image = entry.value;
              return GestureDetector(
                onTap: () => this.pressOnImage(image),
                child: Container(
                  key: image.key,
                  decoration: BoxDecoration(
                    border: entry.key == 0
                      ? Border.fromBorderSide(borderSide)
                      : Border(
                          top: borderSide,
                          bottom: borderSide,
                          right: borderSide
                        )
                  ),
                  child: FadeInImage.memoryNetwork(
                    placeholder: transparentImage,
                    image: image.url,
                    height: 100, width: 140,
                    fit: BoxFit.cover
                  )
                )
              );
            })
            .toList()
        )
      );
    final borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).colorScheme.onBackground
    );
    final getServiceTypePoint = (ProgressService service) =>
      service.type == 'main'? 1:0;
    final services = progress?.services
      ?..sort((service1, service2) =>
        getServiceTypePoint(service2) - getServiceTypePoint(service1)
      );
    final couponApplied = services?.any((service) => service.discountedPrice != service.price);
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
                padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight) +
                  EdgeInsets.symmetric(vertical:24),
                child: ConstrainedBox(
                  constraints: new BoxConstraints(
                    minWidth: width,
                    minHeight: height - top - topHeight - bottom - bottomHeight - insetBottom - 48
                  ),
                  child: progress != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (() {
                          final time = progress.time;
                          final percentage = getProgressPercentage(progress);
                          final imagesBefore = this.imagesBefore;
                          final imagesAfter = this.imagesAfter;
                          return <Widget?>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal:32) + EdgeInsets.only(bottom:24),
                              child: Text(
                                progress.name,
                                style: Theme.of(context).textTheme.headline3
                              )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal:32),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.fromBorderSide(borderSide)
                                ),
                                padding: EdgeInsets.symmetric(vertical:8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    time != null
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(vertical:4, horizontal:12),
                                          child: Text(
                                            'Updated ${displayTimePassed(time)}',
                                            style: Theme.of(context).textTheme.caption
                                          )
                                        )
                                      : null,
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical:4, horizontal:12),
                                      child: Text(
                                        getProgressDescription(progress),
                                        style: Theme.of(context).textTheme.headline5
                                      )
                                    ),
                                    percentage != null
                                      ? Padding(
                                          padding: EdgeInsets.only(top:8) + EdgeInsets.symmetric(vertical:4, horizontal:12),
                                          child: CustomPaint(
                                            foregroundPainter: ProgressBarPainter(
                                              color: Theme.of(context).colorScheme.secondary,
                                              progress: percentage
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical:1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)
                                                ),
                                                height: 2,
                                              )
                                            )
                                          )
                                        )
                                      : null
                                  ].whereType<Widget>().toList()
                                )
                              )
                            ),
                            ...progressAction != null
                              ? [
                                  displaySubheading('Action required'),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal:32),
                                    child: Text(
                                      progressAction.message,
                                      style: Theme.of(context).textTheme.headline6
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical:3, horizontal:32),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Button(
                                          onTap: progressAction.function,
                                          label: progressAction.label,
                                          loading: this.actionLoading
                                        )
                                      ]
                                    )
                                  )
                                ]
                              : [],
                            ...imagesBefore != null && imagesBefore.length > 0
                              ? [
                                  displaySubheading('Before'),
                                  displayImages(imagesBefore)
                                ]
                              : [],
                            ...imagesAfter != null && imagesAfter.length > 0
                              ? [
                                  displaySubheading('After'),
                                  displayImages(imagesAfter)
                                ]
                              : [],
                            displaySubheading('Price'),
                            Container(
                              padding: EdgeInsets.symmetric(vertical:4, horizontal:32),
                              child: Table(
                                border: TableBorder.symmetric(
                                  outside: borderSide
                                ),
                                columnWidths: {
                                  0: IntrinsicColumnWidth(),
                                  1: IntrinsicColumnWidth(flex:1),
                                  2: IntrinsicColumnWidth()
                                },
                                children: [
                                  ...services
                                    !.asMap().entries
                                    .expand((entry) {
                                      final service = entry.value;
                                      final discounted = service.price != service.discountedPrice;
                                      final padding = (entry.key == 0? EdgeInsets.only(top:4):EdgeInsets.zero)
                                        + (entry.key == progress.services.length - 1? EdgeInsets.only(bottom:4):EdgeInsets.zero)
                                        + EdgeInsets.symmetric(horizontal:4)
                                        + (discounted? EdgeInsets.only(top:8, bottom:-4):EdgeInsets.symmetric(vertical:8));
                                      return [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: padding + EdgeInsets.only(left:8),
                                              child: Text(
                                                '${(entry.key + 1).toString()}.',
                                                style: Theme.of(context).textTheme.headline6
                                              )
                                            ),
                                            Padding(
                                              padding: padding,
                                              child: Text(
                                                service.name,
                                                style: Theme.of(context).textTheme.headline6
                                              )
                                            ),
                                            Padding(
                                              padding: padding + EdgeInsets.only(right:8),
                                              child: Text(
                                                'RM${service.price.toStringAsFixed(2)}',
                                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                                  decoration: discounted? TextDecoration.lineThrough:null,
                                                  color: discounted? Theme.of(context).textTheme.caption?.color:null,
                                                  fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                                ),
                                                textAlign: TextAlign.right,
                                              )
                                            )
                                          ]
                                        ),
                                        discounted
                                          ? TableRow(
                                              children: [
                                                Container(),
                                                Container(),
                                                Padding(
                                                  padding: EdgeInsets.all(4) + EdgeInsets.only(top:-4, bottom:8, right:8),
                                                  child: Text(
                                                    'RM${service.discountedPrice.toStringAsFixed(2)}',
                                                    style: Theme.of(context).textTheme.headline6?.copyWith(
                                                      fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  )
                                                )
                                              ]
                                            )
                                          : null
                                      ].whereType<TableRow>();
                                    })
                                    .toList(),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: borderSide
                                      )
                                    ),
                                    children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.fill,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical:12, horizontal:4)
                                            + EdgeInsets.only(left:8),
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
                                        padding:EdgeInsets.symmetric(vertical:12, horizontal:4),
                                        child: Text(
                                          'Total',
                                          style: Theme.of(context).textTheme.headline6
                                        )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical:12, horizontal:4)
                                          + EdgeInsets.only(right:8),
                                        child: Text(
                                          'RM${progress.services
                                            .fold<double>(0, (price, service) => price + service.discountedPrice)
                                            .toStringAsFixed(2)
                                          }',
                                          style: Theme.of(context).textTheme.headline6,
                                          textAlign: TextAlign.right,
                                        )
                                      )
                                    ]
                                  )
                                ]
                              )
                            ),
                            progress.type != 'locker' || ['retrieved-back', 'cancelled'].contains(progress.status)
                              ? null
                              : couponApplied!
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal:32, vertical:8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Coupon code applied',
                                        style: Theme.of(context).textTheme.caption
                                      )
                                    ]
                                  )
                                )
                              : Touchable(
                                  onTap: navigateToAddCoupon,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal:32, vertical:8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'I have a coupon code!',
                                          style: Theme.of(context).textTheme.caption?.copyWith(
                                            color: Theme.of(context).colorScheme.primary
                                          )
                                        )
                                      ]
                                    )
                                  )
                                ),
                            displaySubheading('History'),
                            Container(
                              padding: EdgeInsets.symmetric(vertical:4, horizontal:32),
                              child: Table(
                                border: TableBorder.symmetric(
                                  outside: borderSide
                                ),
                                columnWidths: {
                                  0: IntrinsicColumnWidth(),
                                  1: IntrinsicColumnWidth(flex:1),
                                  2: IntrinsicColumnWidth()
                                },
                                children: progress.events
                                  ?.asMap().entries
                                  .map((entry) {
                                    final event = entry.value;
                                    final padding = EdgeInsets.all(4) + EdgeInsets.symmetric(vertical:8);
                                    return TableRow(
                                      decoration: entry.key != 0
                                        ? BoxDecoration(
                                            border: Border(
                                              top: borderSide
                                            )
                                          )
                                        : null,
                                      children: [
                                        Padding(
                                          padding: padding + EdgeInsets.only(left:8),
                                          child: Text(
                                            '${(entry.key + 1).toString()}.',
                                            style: Theme.of(context).textTheme.headline6
                                          )
                                        ),
                                        Padding(
                                          padding: padding,
                                          child: Text(
                                            getProgressDescription(event),
                                            style: Theme.of(context).textTheme.headline6
                                          )
                                        ),
                                        Padding(
                                          padding: padding + EdgeInsets.only(right:8),
                                          child: Text(
                                            formatDate(event.time, format:'MMM d'),
                                            style: Theme.of(context).textTheme.headline6?.copyWith(
                                              fontWeight: Theme.of(context).textTheme.caption?.fontWeight
                                            ),
                                            textAlign: TextAlign.right,
                                          )
                                        )
                                      ]
                                    );
                                  })
                                  .toList()?? []
                              )
                            )
                          ].whereType<Widget>().toList();
                        })()
                      )
                  : null
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      )
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
              )
            ].whereType<Widget>().toList()
          )
        )
      )
    );
  }
}
class _ProgressAction {
  String message;
  String label;
  void Function() function;
  _ProgressAction({
    required this.message,
    required this.label,
    required this.function
  });
}
class _KeyedImage {
  GlobalKey key;
  String id;
  String url;
  _KeyedImage({
    required this.id,
    required this.url
  }) :
    this.key = GlobalKey();
}