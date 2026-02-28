import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_layout.dart';
import 'success_screen.dart';

class ForgotNewPasswordScreen extends StatefulWidget {
  const ForgotNewPasswordScreen({
    required this.email,
    required this.otp,
    super.key,
  });

  final String email;
  final String otp;

  @override
  State<ForgotNewPasswordScreen> createState() =>
      _ForgotNewPasswordScreenState();
}

class _ForgotNewPasswordScreenState extends State<ForgotNewPasswordScreen> {
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _rePasswordCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _rePasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final password = _passwordCtrl.text;
    final rePassword = _rePasswordCtrl.text;

    if (password.isEmpty) {
      setState(() => _error = t.t('error_password_empty'));
      return;
    }
    if (password.length < 8) {
      setState(() => _error = t.t('error_password_invalid'));
      return;
    }
    if (rePassword.isEmpty) {
      setState(() => _error = t.t('error_repassword_empty'));
      return;
    }
    if (rePassword != password) {
      setState(() => _error = t.t('error_repassword_invalid'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.resetForgotPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: password,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRouter.success,
        arguments: SuccessMode.password,
      );
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        child: Column(
          children: [
            const Icon(
              Icons.lock_reset,
              color: AppColors.mainColorPurple,
              size: 120,
            ),
            const SizedBox(height: 10),
            Text(
              t.t('create_new_pass'),
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t.t('enter_new_pass'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 28),
            AuthInput(
              controller: _passwordCtrl,
              hint: t.t('password_hint'),
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 18),
            AuthInput(
              controller: _rePasswordCtrl,
              hint: t.t('re_password_hint'),
              icon: Icons.lock_reset,
              obscureText: true,
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
