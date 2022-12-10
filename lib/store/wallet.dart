import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../util/graphql.dart' as GraphQL;
import 'main.dart';
import 'authentication.dart';

class WalletStore extends Store {
  IO.Socket _socketChannel;
  bool? _topUpResult;

  WalletStore() :
    this._socketChannel = IO.io(FlutterConfig.get('HYPEGIENIC_API'), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    }),
    super();

  static Future<void> _logException(exception, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    return;
  }

  Future<String> requestTopUp(double amount) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'type': 'billplz',
        'amount': amount
      });
      request.fields['graphql'] = '''
        mutation {
          requestTopUp($parameter) {
            url
          }
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        final url = body['data']['requestTopUp']['url'];
        this.trigger();
        return url;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await WalletStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }
  void Function()? _unsubscribeTopUpResult;
  void subscribeTopUpResult(String userId) {
    this._topUpResult = null;
    this.trigger();
    final socket = this._socketChannel.connect();
    final subscribeTopUpResultListener = (data) {
      if(data['userId'] == userId) {
        this._topUpResult = data['paid'] == true;
        this.trigger();
      }
    };
    socket.on('payment-complete', subscribeTopUpResultListener);
    this._unsubscribeTopUpResult = () {
      socket.off('payment-complete', subscribeTopUpResultListener);
      socket.disconnect();
      this._unsubscribeTopUpResult = null;
    };
  }
  void unsubscribeTopUpResult() {
    this._topUpResult = null;
    this.trigger();
    if(this._unsubscribeTopUpResult != null) {
      this._unsubscribeTopUpResult!();
    }
  }

  bool? get topUpResult => this._topUpResult;
}

final StoreToken walletStoreToken = StoreToken(WalletStore());