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

    return AuthLayout(
      header: t.t('register_page'),
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          children: [
            appLogo(),
            const SizedBox(height: 22),
            AuthInput(
              controller: _usernameCtrl,
              hint: t.t('register_username_hint'),
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            AuthInput(
              controller: _emailCtrl,
              hint: t.t('email_hint'),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthInput(
              controller: _phoneCtrl,
              hint: t.t('phone_hint'),
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AuthInput(
              controller: _passwordCtrl,
              hint: t.t('password_hint'),
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AuthInput(
              controller: _rePasswordCtrl,
              hint: t.t('re_password_hint'),
              icon: Icons.lock_reset,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agreed,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: Text(
                t.t('register_terms'),
                style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(t.t('register')),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.t('have_account')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.t('login')),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
