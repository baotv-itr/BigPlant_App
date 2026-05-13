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
    return AuthScaffold(
      child: Column(
        children: [
          AuthTopBar(
            showBack: true,
            title: t.t('forgot_password_page'),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 432),
                  child: AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t.t('auth_forgot_desc'),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        AuthInput(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'Ví dụ: name@example.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          fillColor: AppColors.surfaceBright,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 18),
                          AuthErrorBanner(message: _error!),
                        ],
                        const SizedBox(height: 28),
                        AuthPrimaryButton(
                          label: t.t('auth_continue'),
                          loading: _loading,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 28),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.keyboard_return_rounded),
                          label: Text(t.t('auth_return_login')),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
