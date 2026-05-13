import 'package:flutter/material.dart';

import '../../features/auth/data/storage_service.dart';
import '../routing/app_router.dart';

class AuthSessionManager {
  AuthSessionManager._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _handlingUnauthorized = false;

  static Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    try {
      await StorageService.clearAuth();
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
      }
    } finally {
      _handlingUnauthorized = false;
    }
  }
}
