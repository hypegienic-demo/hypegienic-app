import 'package:flutter/material.dart';

import '../../store/authentication.dart';
import '../main.dart';
import './register-name.dart';
import './register-email.dart';
import './register-confirm.dart';

Route<NavigationPopResult> navigateToRegistrationForm(AuthenticationStore authenticationStore) {
  final registrationDetail = authenticationStore.registrationDetail;
  if (registrationDetail?.name == null) {
    return MaterialPageRoute(builder:(context) => 
      RegisterNamePage()
    );
  } else if (registrationDetail?.email == null) {
    return MaterialPageRoute(builder:(context) => 
      RegisterEmailPage()
    );
  } else {
    return MaterialPageRoute(builder:(context) => 
      RegisterConfirmPage()
    );
  }
}