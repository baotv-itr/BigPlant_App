import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _agreed = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final t = AppLocalizations.of(context);
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty) {
      setState(() => _error = t.t('error_username_empty'));
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
    if (!_agreed) {
      setState(() => _error = t.t('error_checkbox'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.login(username: username, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.authHome);
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
      header: t.t('login_page'),
      showLanguageToggle: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          children: [
            appLogo(),
            const SizedBox(height: 24),
            AuthInput(
              controller: _usernameCtrl,
              hint: t.t('username_hint'),
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            AuthInput(
              controller: _passwordCtrl,
              hint: t.t('password_hint'),
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _agreed,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: Text(
                t.t('terms'),
                style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(t.t('login')),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.forgotPassword),
              child: Text(
                t.t('forgot_password'),
                style: const TextStyle(color: AppColors.mainColorPurple),
              ),
            ),
            const Divider(height: 28, color: AppColors.grey),
            OutlinedButton.icon(
              onPressed: () => showToast(context, t.t('google_coming_soon')),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(t.t('login_with_google')),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.t('dont_have_account')),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouter.register),
                  child: Text(t.t('register')),
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
