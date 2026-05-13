import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _rePasswordCtrl = TextEditingController();

  final AuthService _authService = AuthService();
  bool _agreed = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _rePasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final t = AppLocalizations.of(context);
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final rePassword = _rePasswordCtrl.text;

    if (username.isEmpty) {
      setState(() => _error = t.t('error_username_empty'));
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = t.t('error_email_empty'));
      return;
    }
    if (!Validators.isValidEmail(email)) {
      setState(() => _error = t.t('error_email_invalid'));
      return;
    }
    if (phone.isNotEmpty && !Validators.isPhoneNumber(phone)) {
      setState(
        () => _error =
            'Phone number should start with 0 and contain 10-11 digits',
      );
      return;
    }
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
    if (password != rePassword) {
      setState(() => _error = t.t('error_repassword_invalid'));
      return;
    }
    if (!_agreed) {
      setState(() => _error = t.t('error_checkbox'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.register(
        username: username,
        email: email,
        phone: phone,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamed(AppRouter.registerVerify, arguments: email);
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
          const AuthTopBar(showBack: true, backFilled: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 432),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.t('auth_register_title'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.t('auth_register_subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      AuthCard(
                        shadowOpacity: 0.04,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthInput(
                              controller: _usernameCtrl,
                              label: 'Username',
                              hint: t.t('register_username_hint'),
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 20),
                            AuthInput(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: t.t('email_hint'),
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            AuthInput(
                              controller: _phoneCtrl,
                              label:
                                  '${t.t('auth_phone_label')} (${t.t('auth_phone_optional')})',
                              hint: t.t('phone_hint'),
                              icon: Icons.phone_iphone_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            AuthInput(
                              controller: _passwordCtrl,
                              label: 'Password',
                              hint: t.t('password_hint'),
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            AuthInput(
                              controller: _rePasswordCtrl,
                              label: t.t('auth_confirm_password_label'),
                              hint: t.t('re_password_hint'),
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreed,
                                    activeColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.outlineVariant,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (value) => setState(
                                      () => _agreed = value ?? false,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.t('register_terms'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 18),
                              AuthErrorBanner(message: _error!),
                            ],
                            const SizedBox(height: 24),
                            AuthPrimaryButton(
                              label: t.t('register'),
                              loading: _loading,
                              icon: Icons.arrow_forward_rounded,
                              radius: 12,
                              onPressed: _register,
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${t.t('have_account')} ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(t.t('login')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
