import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'package:collection/collection.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../util/graphql.dart' as GraphQL;
import './main.dart';
import './authentication.dart';
import './locker.dart';

class ProgressStore extends Store {
  List<ProgressUpdate>? _progressUpdates;
  List<ProgressSimple>? _progressSimples;
  List<Progress>? _progresses;
  Map<String, List<ProgressSimple>>? _retrievableProgresses;

  ProgressStore() : super() {
    FirebaseMessaging.onMessage.listen((message) {
      if(message.contentAvailable && message.data['type'] == 'order') {
        final processUpdate = (ProgressUpdate progress) {
          if(progress.id == message.data['order']) {
            progress.update = true;
          }
          return progress;
        };
        this._progressUpdates = this._progressUpdates?.map(processUpdate).toList();
        this._progressSimples = this._progressSimples?.map(processUpdate)
          .cast<ProgressSimple>().toList();
        this._progresses = this._progresses?.map(processUpdate)
          .cast<Progress>().toList();
        this.trigger();
      }
    });
  }

  static Future<void> _logException(exception, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    return;
  }

  Future<bool> getUpdate() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'statuses': ['delivered-store', 'cleaned', 'delivered-back']
      });
      request.fields['graphql'] = '''
        query {
          displayRequests($parameter) {
            id
            orders {
              ${ProgressUpdate.query}
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
        final progresses = body['data']['displayRequests'];
        this._progressUpdates = progresses != null
          ? progresses
              .expand((progress) =>
                (progress['orders'] as List<dynamic>).map((order) => {...order, 'request':progress['id']})
              )
              .map<ProgressUpdate>((progress) => ProgressUpdate(progress)).toList()
          : [];
        this.trigger();
        return this._progressUpdates!.fold<bool>(false, (update, next) => update || next.update);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }
  Future<List<ProgressSimple>> getProgresses() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'statuses': ['opened-locker', 'deposited', 'retrieved-store', 'delivered-store', 'cleaned', 'delivered-back', 'retrieved-back']
      });
      request.fields['graphql'] = '''
        query {
          displayRequests($parameter) {
            id
            orders {
              ${ProgressSimple.query}
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
        final progresses = body['data']['displayRequests'];
        this._progressSimples = progresses != null
          ? progresses
              .expand((progress) =>
                (progress['orders'] as List<dynamic>).map((order) => {...order, 'request':progress['id']})
              )
              .map<ProgressSimple>((progress) => ProgressSimple(progress)).toList()
          : [];
        this.trigger();
        return this._progressSimples!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }
  Future<Progress?> getProgress(String progressId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'orderId': progressId
      });
      request.fields['graphql'] = '''
        query {
          displayRequests($parameter) {
            id
            orders {
              ${Progress.query}
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
        final progresses = body['data']['displayRequests'];
        final progress = progresses?[0] != null
          ? {...progresses[0]['orders']?[0], 'request':progresses[0]['id']}
          : null;
        this._progresses = progress != null
          ? [
              ...this._progresses?.where((progress) => progress.id != progressId)?? [],
              Progress(progress)
            ]
          : this._progresses;
        this.trigger();
        return this._progresses?.firstWhereOrNull((progress) => progress.id == progressId);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }
  Future<List<ProgressSimple>> getRetrievableProgress(String lockerId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'lockerId': lockerId,
        'statuses': ['delivered-back']
      });
      request.fields['graphql'] = '''
        query {
          displayRequests($parameter) {
            id
            orders {
              ${ProgressSimple.query}
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
        final progresses = body['data']['displayRequests'];
        this._retrievableProgresses = progresses != null
          ? {
              ...this._retrievableProgresses?? {},
              lockerId: progresses
                .expand((progress) =>
                  (progress['orders'] as List<dynamic>).map((order) => {...order, 'request':progress['id']})
                )
                .map<ProgressSimple>((progress) => ProgressSimple(progress)).toList()
            }
          : this._retrievableProgresses;
        this.trigger();
        return this._retrievableProgresses![lockerId]!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  Future<List<ProgressServicePreview>> previewCouponCode(List<String> services, String coupon) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'services': services.map((service) => ({
          'id': service
        })).toList(),
        'coupon': coupon
      });
      print(parameter);
      request.fields['graphql'] = '''
        query {
          previewDiscountedServices($parameter) {
            ${ProgressServicePreview.query}
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
        final services = body['data']['previewDiscountedServices'];
        return services
          .map<ProgressServicePreview>((service) => ProgressServicePreview(service))
          .toList();
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  Future<Progress?> attachRequestCoupon(String requestId, String coupon) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'requestId': requestId,
        'coupon': coupon
      });
      print(parameter);
      request.fields['graphql'] = '''
        mutation {
          addRequestCoupon($parameter) {
            id
            orders {
              ${Progress.query}
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
        final progresses = body['data']['addRequestCoupon'];
        final progress = progresses?[0] != null
          ? {...progresses[0]['orders']?[0], 'request':progresses[0]['id']}
          : null;
        this._progresses = progress != null
          ? [
              ...this._progresses?.where((progress) => progress.request != requestId)?? [],
              Progress(progress)
            ]
          : this._progresses;
        this.trigger();
        return this._progresses?.firstWhereOrNull((progress) => progress.request == requestId);
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  Future<void> markReadNotifications(String progressId) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'type': 'order',
        'orderId': progressId
      });
      request.fields['graphql'] = '''
        mutation {
          markReadNotifications($parameter)
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        final processUpdate = (ProgressUpdate progress) {
          if(progress.id == progressId) {
            progress.update = false;
          }
          return progress;
        };
        this._progressUpdates = this._progressUpdates?.map(processUpdate).toList();
        this._progressSimples = this._progressSimples?.map(processUpdate)
          .cast<ProgressSimple>().toList();
        this._progresses = this._progresses?.map(processUpdate)
          .cast<Progress>().toList();
        this.trigger();
        return;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ProgressStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  bool get update => this._progressUpdates?.fold<bool>(false, (update, next) => update || next.update)?? false;
  List<ProgressSimple>? get progresses => this._progressSimples;
  Progress? progress(String progressId) => this._progresses?.firstWhereOrNull((progress) => progress.id == progressId);
  List<ProgressSimple>? retrievableProgresses(String lockerId) => this._retrievableProgresses?[lockerId];
}

class ProgressUpdate {
  String id;
  String request;
  bool update;

  ProgressUpdate(dynamic progress) :
    this.id = progress['id'],
    this.request = progress['request'],
    this.update = progress['update'];

  
  static final query = '''
    id
    update
  ''';
}
class ProgressSimple extends ProgressUpdate {
  DateTime? time;
  String type;
  String status;
  String name;
  List<ProgressService> services;
  String? openedUnitId;
  Locker? openedAt;
  String? depositedUnitId;
  Locker? depositedAt;

  ProgressSimple(dynamic progress) :
    this.time = DateTime.parse(progress['time']).toLocal(),
    this.type = progress['type'],
    this.status = progress['status'],
    this.name = progress['name'],
    this.services = List.from(progress['services'])
      .map<ProgressService>((service) => ProgressService(service))
      .toList(),
    this.openedUnitId = progress['lockerUnitOpened'] != null
      ? progress['lockerUnitOpened']['id']
      : null,
    this.openedAt = progress['lockerUnitOpened'] != null
      ? Locker(progress['lockerUnitOpened']['locker'])
      : null,
    this.depositedUnitId = progress['lockerUnitDelivered'] != null
      ? progress['lockerUnitDelivered']['id']
      : null,
    this.depositedAt = progress['lockerUnitDelivered'] != null
      ? Locker(progress['lockerUnitDelivered']['locker'])
      : null,
    super(progress);

  static final query = '''
    ${ProgressUpdate.query}
    time
    type
    status
    name
    services {
      ${ProgressService.query}
    }
    lockerUnitOpened {
      id
      locker {
        id
        name
        latitude
        longitude
      }
    }
    lockerUnitDelivered {
      id
      locker {
        id
        name
        latitude
        longitude
      }
    }
  ''';
}
class Progress extends ProgressSimple {
  List<File>? imagesBefore;
  List<File>? imagesAfter;
  List<ProgressEvent>? events;

  Progress(dynamic progress) :
    this.imagesBefore = progress['imagesBefore'] != null
      ? List.from(progress['imagesBefore']).map<File>((image) => File(image)).toList()
      : null,
    this.imagesAfter = progress['imagesAfter'] != null
      ? List.from(progress['imagesAfter']).map<File>((image) => File(image)).toList()
      : null,
    this.events = (() {
      if(progress['events'] != null) {
        final events = List.from(progress['events'])
          .map<ProgressEvent>((event) => ProgressEvent(event))
          .toList();
        final sortedEvents = events
          ..sort((event1, event2) => event1.time.microsecondsSinceEpoch - event2.time.microsecondsSinceEpoch);
        final populatedEvents = sortedEvents
          .asMap().entries
          .where((entry) {
            final event = entry.value;
            final nextEvent = entry.key >= 0 && entry.key < sortedEvents.length - 1
              ? sortedEvents[entry.key + 1]
              : null;
            return nextEvent == null ||
              nextEvent.status != event.status;
          })
          .map((entry)  => entry.value)
          .toList();
        return populatedEvents;
      } else {
        return null;
      }
    })(),
    super(progress);

  static final query = '''
    ${ProgressSimple.query}
    imagesBefore {
      id
      type
      url
    }
    imagesAfter {
      id
      type
      url
    }
    events {
      ${ProgressEvent.query}
    }
  ''';
}
class ProgressService {
  String id;
  String type;
  String name;
  double price;
  double discountedPrice;

  ProgressService(dynamic service) :
    this.id = service['id'],
    this.type = service['type'],
    this.name = service['name'],
    this.price = service['assignedPrice'] * 1.0,
    this.discountedPrice = service['discountedPrice'] * 1.0;

  static final query = '''
    id
    type
    name
    assignedPrice
    discountedPrice
  ''';
}
class ProgressEvent {
  DateTime time;
  String type;
  String status;
  String name;
  List<String>? services;
  Locker? openedAt;
  Locker? depositedAt;

  ProgressEvent(dynamic event) :
    this.time = DateTime.parse(event['time']).toLocal(),
    this.type = event['_type'],
    this.status = event['_status'],
    this.name = event['_name'],
    this.services = event['_services'] != null
      ? List.from(event['_services']).map<String>((service) => service['name']).toList()
      : null,
    this.openedAt = event['_lockerUnitOpened'] != null
      ? Locker(event['_lockerUnitOpened']['locker'])
      : null,
    this.depositedAt = event['_lockerUnitDelivered'] != null
      ? Locker(event['_lockerUnitDelivered']['locker'])
      : null;

  static final query = '''
    type
    time
    _name
    _type
    _status
    _lockerUnitOpened {
      locker {
        name
      }
    }
    _lockerUnitDelivered {
      locker {
        name
      }
    }
    _services {
      name
    }
  ''';
}

class ProgressServicePreview {
  String id;
  String type;
  String name;
  double price;
  double discountedPrice;

  ProgressServicePreview(dynamic service) :
    this.id = service['id'],
    this.type = service['type'],
    this.name = service['name'],
    this.price = service['assignedPrice'] * 1.0,
    this.discountedPrice = service['discountedPrice'] * 1.0;

  static final query = '''
    id
    type
    name
    assignedPrice
    discountedPrice
  ''';
}

final StoreToken progressStoreToken = StoreToken(ProgressStore());