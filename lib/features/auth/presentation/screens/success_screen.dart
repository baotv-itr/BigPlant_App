import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/auth_layout.dart';

enum SuccessMode { verify, password }

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({required this.mode, super.key});

  final SuccessMode mode;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isPassword = mode == SuccessMode.password;
    return AuthLayout(
      header: isPassword ? t.t('forgot_password_page') : t.t('register_page'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.mainColorPurple,
                size: 130,
              ),
              const SizedBox(height: 8),
              Text(
                t.t('verification_success'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mainColorPurple,
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const Icon(
                Icons.check_circle,
                color: AppColors.mainColorPurpleDark,
                size: 86,
              ),
              const SizedBox(height: 14),
              Text(
                isPassword
                    ? t.t('resetpassword_success')
                    : t.t('verification_success_detail'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.darkGrey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
                },
                child: Text(t.t('got_it')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
