import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:collection/collection.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../util/graphql.dart' as GraphQL;
import './main.dart';
import './authentication.dart';

class LockerStore extends Store {
  IO.Socket _socketChannel;
  List<Locker>? _lockers;
  List<LockerUnit>? _lockerUnits;

  LockerStore():
    this._socketChannel = IO.io(FlutterConfig.get('HYPEGIENIC_API'), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    }),
    super();

  static Future<void> _logException(exception, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    return;
  }

  Future<List<Locker>> getLockers() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      request.fields['graphql'] = '''
        query {
          displayLockers {
            ${Locker.query}
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
        final lockers = body['data']['displayLockers'];
        this._lockers = lockers?.map<Locker>((locker) => Locker(locker)).toList()?? [];
        this.trigger();
        return this._lockers!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  void Function()? _unsubscribeLockerOnline;
  void subscribeLockersOnline() {
    final socket = this._socketChannel.connect();
    final subscribeOnlineListener = (data) {
      final lockers = this._lockers?? [];
      if(lockers.any((locker) => locker.id == data['lockerId'])) {
        this._lockers = lockers.map((locker) {
          if(locker.id == data['lockerId']) {
            locker.online = true;
          }
          return locker;
        }).toList();
        this.trigger();
      }
    };
    final subscribeOfflineListener = (data) {
      final lockers = this._lockers?? [];
      if(lockers.any((locker) => locker.id == data['lockerId'])) {
        this._lockers = lockers.map((locker) {
          if(locker.id == data['lockerId']) {
            locker.online = false;
          }
          return locker;
        }).toList();
        this.trigger();
      }
    };
    socket.on('locker-online', subscribeOnlineListener);
    socket.on('locker-offline', subscribeOfflineListener);
    this._unsubscribeLockerOnline = () {
      socket.off('locker-online', subscribeOnlineListener);
      socket.off('locker-offline', subscribeOfflineListener);
      socket.disconnect();
      this._unsubscribeLockerOnline = null;
    };
  }
  void unsubscribeLockersOnline() {
    if(this._unsubscribeLockerOnline != null) {
      this._unsubscribeLockerOnline!();
    }
  }
  Future<LockerUnit?> getLockerUnit(String lockerUnitId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'lockerUnitId': lockerUnitId
      });
      request.fields['graphql'] = '''
        query {
          displayLockers($parameter) {
            ${Locker.query}
            units {
              ${LockerUnit.query}
            }
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
        final lockers = body['data']['displayLockers'];
        final locker = lockers?[0] != null
          ? Locker(lockers[0])
          : null;
        this._lockers = locker != null
          ? [
              ...this._lockers?.where((locker) => locker.id != lockers[0]['id'])?? [],
              locker
            ]
          : this._lockers;
        final lockerUnits = lockers?[0] != null
          ? List.from(lockers[0]['units']).map((lockerUnit) => LockerUnit({
              ...lockerUnit as Map,
              'locker': lockers[0]
            })).toList()
          : [];
        final lockerUnitIds = lockerUnits.map((lockerUnit) => lockerUnit.id).toList();
        this._lockerUnits = [
          ...this._lockerUnits?.where((lockerUnit) => !lockerUnitIds.contains(lockerUnit.id))?? [],
          ...lockerUnits
        ];
        this.trigger();
        return this._lockerUnits?.firstWhereOrNull((lockerUnit) => lockerUnit.id == lockerUnitId);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }
  Future<LockerUnit> placeOrder(String lockerId, List<String> serviceIds, String assignName) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'lockerId': lockerId,
        'serviceIds': serviceIds,
        'name': assignName
      });
      request.fields['graphql'] = '''
        mutation {
          requestLocker($parameter) {
            ${LockerUnit.query}
            locker {
              ${Locker.query}
              units {
                ${LockerUnit.query}
              }
            }
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
        final lockerUnit = body['data']['requestLocker'];
        this._lockers = [
          ...this._lockers?.where((locker) => locker.id != lockerUnit['locker']['id'])?? [],
          Locker(lockerUnit['locker'])
        ];
        final lockerUnitId = lockerUnit['id'];
        this._lockerUnits = [
          ...this._lockerUnits?.where((lockerUnit) => lockerUnit.id != lockerUnitId)?? [],
          ...lockerUnit['locker']['units'] != null
            ? List.from(lockerUnit['locker']['units'])
                .map<LockerUnit>((unit) =>
                  LockerUnit({
                    ...unit as Map,
                    'locker': lockerUnit['locker']
                  })
                )
                .toList()
            : []
        ];
        this.trigger();
        return this._lockerUnits!.firstWhere((lockerUnit) => lockerUnit.id == lockerUnitId);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }
  Future<bool> confirmOrder(String lockerId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'lockerId': lockerId
      });
      request.fields['graphql'] = '''
        mutation {
          confirmDeposit($parameter)
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        return body['data']['confirmDeposit'];
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }
  Future<bool> cancelOrder(String lockerId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'lockerId': lockerId
      });
      request.fields['graphql'] = '''
        mutation {
          cancelLocker($parameter)
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        return body['data']['cancelLocker'];
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }
  Future<LockerUnit> retrieveOrder(String progressId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'orderId': progressId
      });
      request.fields['graphql'] = '''
        mutation {
          requestRetrieveBack($parameter) {
            ${LockerUnit.query}
            locker {
              ${Locker.query}
              units {
                ${LockerUnit.query}
              }
            }
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
        final lockerUnit = body['data']['requestRetrieveBack'];
        this._lockers = [
          ...this._lockers?.where((locker) => locker.id != lockerUnit['locker']['id'])?? [],
          Locker(lockerUnit['locker'])
        ];
        final lockerUnitId = lockerUnit['id'];
        this._lockerUnits = [
          ...this._lockerUnits?.where((lockerUnit) => lockerUnit.id != lockerUnitId)?? [],
          ...lockerUnit['locker']['units'] != null
            ? List.from(lockerUnit['locker']['units'])
                .map<LockerUnit>((unit) =>
                  LockerUnit({
                    ...unit as Map,
                    'locker': lockerUnit['locker']
                  })
                )
                .toList()
            : []
        ];
        this.trigger();
        return this._lockerUnits!.firstWhere((lockerUnit) => lockerUnit.id == lockerUnitId);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }
  Future<bool> confirmRetrieve(String progressId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'orderId': progressId
      });
      request.fields['graphql'] = '''
        mutation {
          confirmRetrieve($parameter) {
            id
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
        return body['data']['confirmRetrieve']['id'] is String;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await LockerStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with modifying your informations');
      }
    }
  }

  List<Locker>? get lockers => this._lockers;
  List<LockerUnit>? get lockerUnits => this._lockerUnits;
}

class Locker {
  String id;
  String name;
  double latitude;
  double longitude;
  bool online;
  int rows;
  int columns;

  Locker(dynamic locker) :
    this.id = locker['id'],
    this.name = locker['name'],
    this.latitude = locker['latitude'],
    this.longitude = locker['longitude'],
    this.online = locker['online'],
    this.rows = locker['rows'],
    this.columns = locker['columns'];
  
  static from(Locker locker) {
    return new Locker({
      'id': locker.id,
      'name': locker.name,
      'latitude': locker.latitude,
      'longitude': locker.longitude,
      'online': locker.online,
      'rows': locker.rows,
      'columns': locker.columns
    });
  }
  
  static final query = '''
    id
    name
    latitude
    longitude
    online
    rows
    columns
  ''';
}
class LockerStatusHandler {
  dynamic Function(dynamic) online;
  dynamic Function(dynamic) offline;

  LockerStatusHandler({
    required this.online,
    required this.offline
  });
}

class LockerUnit {
  String id;
  int number;
  int row;
  int column;
  Locker locker;

  LockerUnit(dynamic lockerUnit) :
    this.id = lockerUnit['id'],
    this.number = lockerUnit['number'],
    this.row = lockerUnit['row'],
    this.column = lockerUnit['column'],
    this.locker = Locker(lockerUnit['locker']);

  static final query = '''
    id
    number
    row
    column
  ''';
}

final StoreToken lockerStoreToken = StoreToken(LockerStore());