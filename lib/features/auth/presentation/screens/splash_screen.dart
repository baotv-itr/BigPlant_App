import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../widgets/auth_layout.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.secondaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _SplashBlob(
                alignment: Alignment(-1.15, -1.1),
                color: Color(0x33BEEAD1),
                size: 320,
              ),
              const _SplashBlob(
                alignment: Alignment(1.2, 1.1),
                color: Color(0x26B1F0CE),
                size: 380,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.05),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const AuthLogoMark(size: 112),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.t('app_name'),
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppColors.primary,
                        backgroundColor: AppColors.secondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.t('auth_loading'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            letterSpacing: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashBlob extends StatelessWidget {
  const _SplashBlob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 90,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
