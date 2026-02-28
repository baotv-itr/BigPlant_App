import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final ok = await _authService.verifyExistingToken();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(ok ? AppRouter.authHome : AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9F62E2), AppColors.mainColorPurpleDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_rounded, color: AppColors.white, size: 130),
                const SizedBox(height: 16),
                Text(
                  t.t('app_name'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Grow your plant life beautifully',
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
                const SizedBox(height: 52),
                const SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: AppColors.loading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
