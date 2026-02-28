import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = t.t('error_email_empty'));
      return;
    }
    if (!Validators.isValidEmail(email)) {
      setState(() => _error = t.t('error_email_invalid'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.forgotPassword(email);
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRouter.forgotVerify, arguments: email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AuthLayout(
      header: t.t('forgot_password_page'),
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            const Icon(
              Icons.help_outline,
              color: AppColors.mainColorPurple,
              size: 128,
            ),
            const SizedBox(height: 10),
            Text(
              t.t('forgot_password_page'),
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t.t('reset_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 26),
            AuthInput(
              controller: _emailCtrl,
              hint: t.t('email_hint'),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(t.t('next')),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
