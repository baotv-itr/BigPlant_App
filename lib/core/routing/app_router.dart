import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/forgot_new_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_verify_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/register_verify_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/success_screen.dart';
import '../../features/shop/presentation/screens/main_shell_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerVerify = '/register-verify';
  static const String forgotPassword = '/forgot-password';
  static const String forgotVerify = '/forgot-verify';
  static const String forgotNewPassword = '/forgot-new-password';
  static const String success = '/success';
  static const String authHome = '/auth-home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case registerVerify:
        return MaterialPageRoute(
          builder: (_) =>
              RegisterVerifyScreen(email: settings.arguments as String),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case forgotVerify:
        return MaterialPageRoute(
          builder: (_) =>
              ForgotVerifyScreen(email: settings.arguments as String),
        );
      case forgotNewPassword:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => ForgotNewPasswordScreen(
            email: args['email'] ?? '',
            otp: args['otp'] ?? '',
          ),
        );
      case success:
        final mode = settings.arguments as SuccessMode? ?? SuccessMode.verify;
        return MaterialPageRoute(builder: (_) => SuccessScreen(mode: mode));
      case authHome:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
