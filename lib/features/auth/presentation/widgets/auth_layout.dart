import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_globals.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.header,
    required this.body,
    this.showBack = false,
    this.onBack,
    this.showLanguageToggle = true,
    super.key,
  });

  final String header;
  final Widget body;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showLanguageToggle;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 74,
                width: double.infinity,
                color: AppColors.mainColorPurple,
                child: Stack(
                  children: [
                    if (showBack)
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed:
                              onBack ?? () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        header,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showLanguageToggle)
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: TextButton(
                          onPressed: () => LocaleScope.of(context).toggle(),
                          child: Text(
                            t.t('toggle_language'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: body),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  t.t('copyright'),
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Widget appLogo() {
  return Column(
    children: [
      Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33111111),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: AppColors.mainColorPurple,
          size: 64,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        AppGlobals.appName,
        style: const TextStyle(
          color: AppColors.mainColorPurple,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
