import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/auth_service.dart';
import '../widgets/auth_layout.dart';
import 'success_screen.dart';

class RegisterVerifyScreen extends StatefulWidget {
  const RegisterVerifyScreen({required this.email, super.key});

  final String email;

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
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
      await _authService.verifyRegisterOtp(email: widget.email, otp: otp);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRouter.success, arguments: SuccessMode.verify);
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
      await _authService.resendRegisterOtp(widget.email);
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
    return AuthScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 432),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AuthBackButton(size: 48, filled: true),
                ),
                const SizedBox(height: 40),
                AuthCard(
                  shadowOpacity: 0.04,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color:
                              AppColors.secondaryContainer.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.t('verify_email'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.t('auth_register_otp_desc'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 28),
                      AuthOtpInput(
                        controller: _otpCtrl,
                        hasError: _error != null,
                        boxSize: 58,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_rounded,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        label: t.t('verify_email'),
                        loading: _loading,
                        radius: 12,
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${t.t('didnt_get_email')} ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                          TextButton(
                            onPressed: _resend,
                            child: Text(t.t('auth_resend_timer')),
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
    );
  }
}
