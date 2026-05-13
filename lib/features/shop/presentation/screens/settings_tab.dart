import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../auth/data/storage_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final AuthService _authService = AuthService();
  bool _notifyDeals = true;
  bool _plantCareTips = true;
  String _displayName = 'User';
  String _displayEmail = '-';
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final fullName = (await StorageService.getFullName())?.trim() ?? '';
    final userName = (await StorageService.getUserName())?.trim() ?? '';
    final email = (await StorageService.getEmail())?.trim() ?? '';
    if (!mounted) return;
    setState(() {
      _displayName = fullName.isNotEmpty
          ? fullName
          : (userName.isNotEmpty ? userName : 'User');
      _displayEmail = email.isNotEmpty ? email : '-';
    });
  }

  Future<void> _logout(BuildContext context) async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    await _authService.logout();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
        children: [
          Text(
            t.t('settings_title'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.leafMint,
                  child: Icon(Icons.person_rounded, color: AppColors.leafGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _displayEmail,
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.darkGrey),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _notifyDeals,
                  activeThumbColor: AppColors.leafGreen,
                  activeTrackColor: AppColors.leafMint,
                  title: Text(t.t('notify_deals')),
                  onChanged: (value) => setState(() => _notifyDeals = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _plantCareTips,
                  activeThumbColor: AppColors.leafGreen,
                  activeTrackColor: AppColors.leafMint,
                  title: Text(t.t('notify_tips')),
                  onChanged: (value) => setState(() => _plantCareTips = value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(t.t('language')),
                  subtitle: Text(t.t('toggle_language')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loggingOut ? null : () => _logout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.soil,
              side: const BorderSide(color: AppColors.cardBorder),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: _loggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t.t('logout')),
          ),
        ],
      ),
    );
  }
}
