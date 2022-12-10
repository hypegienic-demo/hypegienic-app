import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import '../../../store/locker.dart';
import '../../common/button.dart';
import '../../common/touchable.dart';
import '../../common/inline-error.dart';
import '../../main.dart';
import './order-received.dart';
import './order-done.dart';

class ShowLockerPage extends StatefulWidget {
  final String lockerUnitId;
  final String? retrieveProgressId;
  ShowLockerPage({
    required this.lockerUnitId,
    this.retrieveProgressId
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
  State<StatefulWidget> createState() => _ShowLockerPageState();
}
class _ShowLockerPageState extends State<ShowLockerPage> with StoreWatcherMixin<ShowLockerPage> {
  final double topHeight = 0;
  
  late LockerStore lockerStore;
  List<Locker>? lockers;
  List<LockerUnit>? lockerUnits;
  bool loading;
  bool requesting;
  String? error;

  _ShowLockerPageState() :
    this.loading = false,
    this.requesting = false,
    super();
  
  @override
  void initState() {
    super.initState();
    lockerStore = listenToStore(lockerStoreToken, (store) {
      final lockerStore = store as LockerStore;
      setState(() {
        this.lockers = lockerStore.lockers;
        this.lockerUnits = lockerStore.lockerUnits;
      });
    }) as LockerStore;
    this.lockers = lockerStore.lockers;
    this.lockerUnits = lockerStore.lockerUnits;
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('show-locker')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }
  cancel(BuildContext context) async {
    final lockerUnit = this.lockerUnits?.firstWhere((lockerUnit) => lockerUnit.id == widget.lockerUnitId);
    final locker = lockerUnit?.locker;
    if(locker != null) {
      setState(() => this.requesting = true);
      lockerStore.cancelOrder(locker.id)
        .then((lockerUnit) =>
          Navigator.pop(context, NavigationPopResult(
            toPath: ['map']
          ))
        )
        .catchError((error) =>
          this.setError(error.message)
        )
        .whenComplete(() => 
          setState(() => this.requesting = false)
        );
    }
  }
  done(BuildContext context) async {
    final lockerUnit = this.lockerUnits?.firstWhere((lockerUnit) => lockerUnit.id == widget.lockerUnitId);
    final retrieveProgressId = widget.retrieveProgressId;
    if(retrieveProgressId == null) {
      final locker = lockerUnit?.locker;
      if(locker != null) {
        setState(() => this.requesting = true);
        lockerStore.confirmOrder(locker.id)
          .then((lockerUnit) =>
            this.navigate<NavigationPopResult>(context, MaterialPageRoute(
              builder: (context) => OrderReceivedPage()
            ))
          )
          .catchError((error) =>
            this.setError(error.message)
          )
          .whenComplete(() => 
            setState(() => this.requesting = false)
          );
      }
    } else {
      setState(() => this.requesting = true);
      lockerStore.confirmRetrieve(retrieveProgressId)
        .then((done) =>
          this.navigate<NavigationPopResult>(context, MaterialPageRoute(
            builder: (context) => OrderDonePage()
          ))
        )
        .catchError((error) =>
          this.setError(error.message)
        )
        .whenComplete(() => 
          setState(() => this.requesting = false)
        );
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

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetBottom = deviceData.viewInsets.bottom;
    final bottomHeight = widget.retrieveProgressId != null ? 76.0:120.0;
    
    final lockerUnit = this.lockerUnits?.firstWhere((lockerUnit) => lockerUnit.id == widget.lockerUnitId);
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
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical:16, horizontal:24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.retrieveProgressId == null
                              ? 'Place your shoe here'
                              : 'Retrieve your shoe here',
                            style: Theme.of(context).textTheme.headline3
                          ),
                          Text(
                            widget.retrieveProgressId == null
                              ? "Press 'Done' after you placed your shoe and close the locker unit"
                              : "Press 'Done' after you retrieved your shoe and close the locker unit",
                            style: Theme.of(context).textTheme.bodyText1
                          )
                        ]
                      )
                    ),
                    Container(
                      width: [width - 48, 480.0].reduce(math.min),
                      height: [width - 48, 480.0].reduce(math.min),
                      padding: EdgeInsets.symmetric(horizontal:32, vertical:16),
                      child: lockerUnit != null
                        ? LockerIllustration(
                            highlightUnit: lockerUnit,
                            lockerUnits: this.lockerUnits!,
                          )
                        : null
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.retrieveProgressId == null
                        ? '05/05'
                        : '03/03',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontSize: 18
                      )
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
                    child: Column(
                      children: [
                        widget.retrieveProgressId == null
                          ? Touchable(
                              onTap: () => this.cancel(context),
                              padding: EdgeInsets.only(bottom:8) +
                                EdgeInsets.symmetric(
                                  vertical: Theme.of(context).buttonTheme.padding.vertical,
                                  horizontal: Theme.of(context).buttonTheme.padding.horizontal
                                ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.button?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface
                                  )
                                )
                              )
                            )
                          : null,
                        Button(
                          onTap: () => this.done(context),
                          loading: this.loading || this.requesting,
                          label: 'DONE'
                        )
                      ].whereType<Widget>().toList()
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

class LockerIllustration extends StatefulWidget {
  final LockerUnit highlightUnit;
  final List<LockerUnit> lockerUnits;
  LockerIllustration({
    required this.highlightUnit,
    required this.lockerUnits
  });

  @override
  State<StatefulWidget> createState() => _LockerIllustrationState();
}
class _LockerIllustrationState extends State<LockerIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  double _progress;

  _LockerIllustrationState() :
    this._progress = 0,
    super();

  @override
  void initState() {
    super.initState();
    this._progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:1200),
      value: 0.0,
      lowerBound: 0,
      upperBound: 1
    );
    this._progressController.forward();
    this._progressController.addListener(() {
      setState(() {
        this._progress = this._progressController.value;
      });
    });
    this._progressController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        this._progressController.reset();
      } else if(status == AnimationStatus.dismissed) {
        this._progressController.forward();
      }
    });
  }
  @override
  void dispose() {
    this._progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LockerPainter(
        highlightUnit: widget.highlightUnit,
        lockerUnits: widget.lockerUnits,
        borderColor: Theme.of(context).colorScheme.onSurface,
        highlightColor: Theme.of(context).colorScheme.secondary,
        textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
          fontSize: 7,
          shadows: <BoxShadow>[
            BoxShadow(
              offset: Offset(0.2, 0),
              color: Theme.of(context).colorScheme.onSurface
            ),
            BoxShadow(
              offset: Offset(-0.2, 0),
              color: Theme.of(context).colorScheme.onSurface
            )
          ]
        ),
        progress: this._progress
      ),
      child: Container()
    );
  }
}
class LockerPainter extends CustomPainter {
  final LockerUnit highlightUnit;
  final List<LockerUnit> lockerUnits;
  final Color borderColor;
  final Color highlightColor;
  final TextStyle? textStyle;
  final double progress;
  LockerPainter({
    required this.highlightUnit,
    required this.lockerUnits,
    required this.borderColor,
    required this.highlightColor,
    this.textStyle,
    required this.progress
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final locker = this.highlightUnit.locker;
    final lockerUnitSize = Size(32, 24);
    final lockerSize = Size(locker.columns * lockerUnitSize.width, locker.rows * lockerUnitSize.height);
    final maxLockerSize = math.max(lockerSize.width, lockerSize.height);
    final scale = math.min(size.width, size.height) / maxLockerSize;
    final startX = (maxLockerSize - lockerSize.width) / 2;
    final startY = (maxLockerSize - lockerSize.height) / 2;

    canvas.translate(0.0, 0.0);
    canvas.scale(scale, scale);

    final sidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = this.borderColor
      ..strokeWidth = 0.8;
    canvas.drawPath(Path()
      ..moveTo(startX, startY)
      ..relativeLineTo(lockerSize.width, 0.0)
      ..relativeLineTo(0.0, lockerSize.height)
      ..relativeLineTo(- lockerSize.width, 0.0)
      ..close(),
      sidePaint
    );
    final middlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = this.borderColor
      ..strokeWidth = 0.8;
    for(var column = 1; column < locker.columns; column++) {
      final x = (maxLockerSize - lockerSize.width) / 2 + column * lockerUnitSize.width;
      canvas.drawPath(Path()
        ..moveTo(x, (maxLockerSize - lockerSize.height) / 2)
        ..relativeLineTo(0, lockerSize.height),
        middlePaint
      );
    }
    for(var row = 1; row < locker.rows; row++) {
      final y = (maxLockerSize - lockerSize.height) / 2 + row * lockerUnitSize.height;
      canvas.drawPath(Path()
        ..moveTo((maxLockerSize - lockerSize.width) / 2, y)
        ..relativeLineTo(lockerSize.width, 0),
        middlePaint
      );
    }

    final lineWidth = 5.0;
    final gapWidth = 2.0;
    final pulseWidth = lineWidth + gapWidth;
    final pulseRadius = math.sqrt(math.pow(lockerUnitSize.width, 2) + math.pow(lockerUnitSize.height, 2)) / 2;
    final pulseCenter = Offset(
      startX + (this.highlightUnit.column - 0.5) * lockerUnitSize.width,
      startY + (this.highlightUnit.row - 0.5) * lockerUnitSize.height
    );
    final pulseStart = (progress * pulseWidth - lineWidth) / pulseWidth;
    for(var i = pulseStart; i < pulseRadius / pulseWidth; i++) {
      final width = i * pulseWidth;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 - (width / pulseRadius) < 0.5
          ? lineWidth * 2 * (1 - (width / pulseRadius))
          : lineWidth
        ..color = this.highlightColor;
      if(width > lineWidth / 2) {
        canvas.drawCircle(pulseCenter, width, paint);
      } else {
        canvas.drawCircle(pulseCenter, width + lineWidth / 2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = this.highlightColor
        );
      }
    }
    // for(final index in [0, 1, 2]) {
    //   final currentProgress = this.progress <= 0.4 + index * 0.3
    //     ? math.max((this.progress - 0.2 - index * 0.3) / 0.2, 0.0)
    //     : 0.0;
    //   final paint = Paint()
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 15.0 * (1 - currentProgress)
    //     ..color = this.highlightColor;
    //   if (currentProgress > 0) {
    //     canvas.drawCircle(pulseCenter, currentProgress * pulseRadius, paint);
    //   }
    // }


    for(final unit in this.lockerUnits) {
      final text = TextPainter(
        text: TextSpan(
          text: unit.number.toString().padLeft(2, '0'),
          style: this.textStyle
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr
      );
      text.layout();
      text.paint(canvas, Offset(
        startX + (unit.column - 1) * lockerUnitSize.width + 5,
        startY + (unit.row - 1) * lockerUnitSize.height + 3
      ));
    }
  }

  @override
  bool shouldRepaint(LockerPainter self) {
    return self.highlightUnit != this.highlightUnit ||
      self.lockerUnits != this.lockerUnits ||
      self.progress != this.progress;
  }
}