import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../util/graphql.dart' as GraphQL;
import './main.dart';
import './authentication.dart';

class ServiceStore extends Store {
  List<Service>? _services;

  static Future<void> _logException(exception, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    return;
  }

  Future<List<Service>> getServices() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'priceType': 'fixed'
      });
      request.fields['graphql'] = '''
        query {
          displayServices($parameter) {
            ${Service.query}
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
        final services = body['data']['displayServices'];
        this._services = services?.map<Service>((service) => Service(service)).toList()?? [];
        this.trigger();
        return this._services!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await ServiceStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  List<Service>? get services => this._services;
}

class Service {
  String id;
  String type;
  String name;
  double price;
  String? icon;
  String? description;
  List<String>? exclude;

  Service(dynamic service) :
    this.id = service['id'],
    this.type = service['type'],
    this.name = service['name'],
    this.price = service['price']['amount'] * 1.0,
    this.icon = service['icon'] != null
      ? FlutterConfig.get('HYPEGIENIC_API') + service['icon']
      : null,
    this.description = service['description'],
    this.exclude = service['exclude'] != null
      ? List.from(service['exclude']).map<String>((service) => service['id']).toList()
      : null;
    
  static final query = '''
    id
    type
    name
    description
    price {
      type
      amount
    }
    icon
    exclude {
      id
    }
  ''';
}

final StoreToken serviceStoreToken = StoreToken(ServiceStore());