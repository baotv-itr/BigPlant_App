import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../widgets/auth_layout.dart';

class ForgotVerifyScreen extends StatefulWidget {
  const ForgotVerifyScreen({required this.email, super.key});

  final String email;

  @override
  State<ForgotVerifyScreen> createState() => _ForgotVerifyScreenState();
}

class _ForgotVerifyScreenState extends State<ForgotVerifyScreen> {
  final TextEditingController _otpCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final t = AppLocalizations.of(context);
    final otp = _otpCtrl.text.trim();
    if (otp.length != 4) {
      setState(() => _error = t.t('error_otp_invalid'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.verifyForgotOtp(email: widget.email, otp: otp);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.forgotNewPassword,
        arguments: {'email': widget.email, 'otp': otp},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final t = AppLocalizations.of(context);
    try {
      await _authService.forgotPassword(widget.email);
      if (!mounted) return;
      showToast(context, t.t('toast_success_default'));
    } catch (e) {
      if (!mounted) return;
      showToast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AuthLayout(
      header: t.t('forgot_password_page'),
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        child: Column(
          children: [
            const Icon(
              Icons.email_outlined,
              color: AppColors.mainColorPurple,
              size: 120,
            ),
            const SizedBox(height: 10),
            Text(
              t.t('verify_email'),
              style: const TextStyle(
                color: AppColors.mainColorPurple,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.t('verify_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkGrey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(
                color: AppColors.mainColorPurpleDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 8),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '0000',
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.t('didnt_get_email')),
                TextButton(onPressed: _resend, child: Text(t.t('resend'))),
              ],
            ),
            if (_error != null)
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.red),
              ),
          ],
        ),
      ),
    );
  }
}
