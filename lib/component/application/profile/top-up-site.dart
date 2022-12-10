import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../store/authentication.dart';
import '../../../store/wallet.dart';
import '../../../asset/graphic/icon/back.dart';
import '../../common/touchable.dart';
import '../../main.dart';
import './top-up-result.dart';

class TopUpSitePage extends StatefulWidget {
  final String url;
  TopUpSitePage({
    required this.url
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
  State<StatefulWidget> createState() => _TopUpSitePageState();
}
class _TopUpSitePageState extends State<TopUpSitePage> with StoreWatcherMixin<TopUpSitePage> {
  final double topHeight = 48;
  final double bottomHeight = 0;

  late AuthenticationStore authenticationStore;
  late WalletStore walletStore;
  late WebViewController webViewController;
  
  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    walletStore = listenToStore(walletStoreToken, (store) {
      final walletStore = store as WalletStore;
      final topUpResult = walletStore.topUpResult;
      if(topUpResult != null) {
        this.navigate<NavigationPopResult>(context, MaterialPageRoute(
          builder: (context) => TopUpResultPage(
            success: topUpResult
          )
        ));
      }
    }) as WalletStore;
    authenticationStore = listenToStore(authenticationStoreToken) as AuthenticationStore;
    final profile = authenticationStore.profile;
    if(profile != null) {
      walletStore.subscribeTopUpResult(profile.id);
    }
  }
  @override
  void dispose() {
    walletStore.unsubscribeTopUpResult();
    super.dispose();
  }

  Future<T?> navigate<T extends Object>(BuildContext context, Route<T> route) {
    return Navigator.push(context, route)
      .then((object) {
        if(object is NavigationPopResult && !object.toPath.contains('top-up-site')) {
          Navigator.pop(context, object);
        }
        widget.setBarStyle();
        return object;
      });
  }
  isSamePath(String url1, String url2) {
    final regexp = RegExp(r'^https://[a-zA-Z\-\.]+');
    return regexp.firstMatch(url1)?.group(0) == regexp.firstMatch(url2)?.group(0);
  }
  goBack(BuildContext context) async {
    final canGoBack = await webViewController.canGoBack();
    if(canGoBack) {
      await webViewController.goBack();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top:top + topHeight, bottom:bottom + bottomHeight),
              child: WebView(
                onWebViewCreated: (controller) {
                  this.webViewController = controller;
                },
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (route) => NavigationDecision.navigate
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
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                height: bottom + bottomHeight,
                padding: EdgeInsets.only(bottom:bottom)
              )
            )
          ]
        )
      ),
    );
  }
}
