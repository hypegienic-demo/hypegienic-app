import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as HTTP;
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, PhoneAuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/graphql.dart' as GraphQL;
import '../util/device.dart' as Device;
import './main.dart';

class AuthenticationStore extends Store {
  bool? _authenticated;
  MobileVerification? _mobileVerification;
  RegistrationDetail? _registrationDetail;
  User? _profile;

  AuthenticationStore() : super() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if(user != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        final authenticated = preferences.getBool('authenticated');
        await this._setAuthenticated(authenticated == true);
      } else {
        await this._setAuthenticated(false);
      }
      this.trigger();
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      this.addUserDevice(token);
    });
  }

  static Future<void> _logException(exception, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    return;
  }

  Future<void> _setAuthenticated(bool authenticated) async {
    this._authenticated = authenticated;
    final user = FirebaseAuth.instance.currentUser;
    if(authenticated && user != null) {
      this._mobileVerification = null;
      this._registrationDetail = null;
    } else {
      this._profile = null;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('authenticated', this._authenticated!);
    try {
      if(authenticated && user != null) {
        final notificationSettings = await FirebaseMessaging.instance.getNotificationSettings();
        final authorizationStatus = notificationSettings.authorizationStatus;
        if([AuthorizationStatus.authorized, AuthorizationStatus.provisional].contains(authorizationStatus)) {
          final token = await FirebaseMessaging.instance.getToken();
          if(token != null) {
            await this.addUserDevice(token);
          }
        }
      }
    } catch(error) {}
    return;
  }

  Future<void> signInMobile(String mobileNumber) {
    Completer codeSentCompleter = Completer();
    Completer verificationCompleter = Completer();
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: mobileNumber,
      timeout: Duration(minutes:1),
      codeSent: (verificationId, [forceResendingToken]) {
        this._mobileVerification = MobileVerification(MobileVerificationType.mobile, verificationId, verificationCompleter.future);
        this.trigger();
        codeSentCompleter.complete();
      },
      verificationCompleted: (credential) {
        verificationCompleter.complete();
      },
      verificationFailed: (exception) async {
        await AuthenticationStore._logException(exception, StackTrace.current);
        codeSentCompleter.completeError(ApplicationInterfaceError(exception.message ??
          'Something went wrong with authenticating'
        ));
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
    return codeSentCompleter.future;
  }
  Future<void> signOut() async {
    try {
      await this.removeUserDevice();
    } catch(error) {}
    await FirebaseAuth.instance.signOut();
    return;
  }

  Future<void> submitPasscode(String passcode) async {
    if(this._mobileVerification != null) {
      final credential = PhoneAuthProvider.credential(verificationId:this._mobileVerification!.verificationId, smsCode:passcode);
      final result = await FirebaseAuth.instance.signInWithCredential(credential)
        .catchError((error) {
          throw ApplicationInterfaceError('The code you entered is invalid');
        });
      await this._checkAuthenticate(result.user);
      return;
    } else {
      throw ApplicationInterfaceError('Please attempt to sign in first');
    }
  }
  Future<void> _checkAuthenticate(Auth.User? user) async {
    try {
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      if(user != null) {
        request.headers['Authorization'] = await user.getIdToken();
      }
      request.fields['graphql'] = '''
        query {
          signIn {
            registered
            detail {
              displayName
              email
            }
          }
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      final data = body['data']['signIn'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else if(data['registered'] == true) {
        await this._setAuthenticated(true);
        this.trigger();
        return;
      } else {
        if(data['detail'] != null) {
          final detail = data['detail'];
          this._registrationDetail = RegistrationDetail(
            name: detail['displayName'],
            email: detail['email']
          );
          this.trigger();
        } else if(user?.displayName != null) {
          this._registrationDetail = RegistrationDetail(
            name: user!.displayName,
            email: user.email,
          );
          this.trigger();
        }
        throw ApplicationInterfaceError('Please register your account first');
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with registering');
      }
    }
  }

  void updateRegistrationDetail({String? name, String? email}) {
    if(this._registrationDetail != null) {
      this._registrationDetail!.name = name?? this._registrationDetail!.name;
      this._registrationDetail!.email = email?? this._registrationDetail!.email;
      this.trigger();
    } else {
      this._registrationDetail = RegistrationDetail(
        name: name,
        email: email
      );
      this.trigger();
    }
  }

  Future<User> registerMobile(String name, String email) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'displayName': name,
        'email': email
      });
      request.fields['graphql'] = '''
        mutation {
          registerMobile($parameter) {
            id
            displayName
            walletBalance
            mobileNumber
            email
            address
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
        final data = body['data']['registerMobile'];
        this._profile = User(data);
        this._setAuthenticated(true);
        this.trigger();
        return this._profile!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with saving your informations');
      }
    }
  }

  static Future<String> getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user != null) {
        try {
          return await user.getIdToken();
        } catch(error) {
          if(
            error is Auth.FirebaseAuthException &&
            error.message != null &&
            error.message!.contains('credential is no longer valid')
          ) {
            FirebaseAuth.instance.signOut();
            throw ApplicationInterfaceError('Please log in first');
          } else {
            rethrow;
          }
        }
      } else {
        throw ApplicationInterfaceError('Please log in first');
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your credentials');
      }
    }
  }

  Future<User> getUserProfile() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      request.fields['graphql'] = '''
        query {
          displayProfile {
            id
            displayName
            walletBalance
            mobileNumber
            email
            address
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
        final data = body['data']['displayProfile'];
        this._profile = User(data);
        this.trigger();
        return this._profile!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  Future<User> editUserProfile({
    String? displayName,
    String? email
  }) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'displayName': displayName,
        'email': email
      });
      request.fields['graphql'] = '''
        mutation {
          updateProfile($parameter) {
            id
            displayName
            walletBalance
            mobileNumber
            email
            address
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
        final data = body['data']['updateProfile'];
        this._profile = User(data);
        this.trigger();
        return this._profile!;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  Future<bool> checkCanRequestNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    final futures = await Future.wait([
      FirebaseMessaging.instance.getNotificationSettings(),
      SharedPreferences.getInstance()
    ]);
    final notificationSettings = futures[0] as NotificationSettings;
    final preferences = futures[1] as SharedPreferences;
    final saved = preferences.getString('notification');
    final canRequest = notificationSettings.authorizationStatus == AuthorizationStatus.notDetermined;
    if(user != null && saved != null) {
      final notification = json.decode(saved);
      if(notification['userId'] == user.uid) {
        return canRequest &&
          DateTime.now().millisecondsSinceEpoch -
          DateTime.parse(notification['date']).millisecondsSinceEpoch >
          30 * 86400000; // 30 days
      } else {
        return canRequest;
      }
    } else {
      return canRequest;
    }
  }
  Future<void> rejectRequestNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('notification', json.encode({
        'userId': user.uid,
        'date': DateTime.now().toIso8601String()
      }));
    }
  }
  Future<void> addUserDevice(String messagingToken) async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'uid': await Device.getDeviceUID(),
        'token': messagingToken
      });
      request.fields['graphql'] = '''
        mutation {
          addDevice($parameter)
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        return;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }
  Future<void> removeUserDevice() async {
    try {
      final token = await AuthenticationStore.getToken();
      final request = HTTP.MultipartRequest('POST', Uri.parse(FlutterConfig.get('HYPEGIENIC_API') + '/root'));
      request.headers['Authorization'] = token;
      final parameter = GraphQL.encode({
        'uid': await Device.getDeviceUID()
      });
      request.fields['graphql'] = '''
        mutation {
          removeDevice($parameter)
        }
      ''';
      final stream = await request.send();
      final response = await HTTP.Response.fromStream(stream);
      final body = json.decode(response.body);
      final errors = body['errors'];
      if((errors?? []).length > 0) {
        throw ApplicationInterfaceError(errors[0]);
      } else {
        return;
      }
    } catch(error) {
      if(error is ApplicationInterfaceError) {
        rethrow;
      } else {
        await AuthenticationStore._logException(error, StackTrace.current);
        throw ApplicationInterfaceError('Something went wrong with retrieving your informations');
      }
    }
  }

  bool? get authenticated => this._authenticated;
  MobileVerification? get mobileVerification => this._mobileVerification;
  RegistrationDetail? get registrationDetail => this._registrationDetail;
  User? get profile => this._profile;
}

class MobileVerification {
  MobileVerificationType type;
  String verificationId;
  Future<void> verificationFuture;

  MobileVerification(this.type, this.verificationId, this.verificationFuture);
}
enum MobileVerificationType {mobile, facebook}

class RegistrationDetail {
  String? name;
  String? email;

  RegistrationDetail({
    this.name,
    this.email
  });
}

class User {
  String id;
  String displayName;
  double walletBalance;
  String mobileNumber;
  String emailAddress;

  User(dynamic user) :
    this.id = user['id'],
    this.displayName = user['displayName'],
    this.walletBalance = user['walletBalance'] + 0.0,
    this.mobileNumber = user['mobileNumber'],
    this.emailAddress = user['email'];
}

final StoreToken authenticationStoreToken = StoreToken(AuthenticationStore());