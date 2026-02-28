import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/storage_service.dart';
import '../widgets/auth_layout.dart';

class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await StorageService.clearAuth();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AuthLayout(
      header: t.t('session_title'),
      showBack: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user,
                color: AppColors.mainColorPurple,
                size: 110,
              ),
              const SizedBox(height: 10),
              Text(
                t.t('session_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: Text(t.t('logout')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
