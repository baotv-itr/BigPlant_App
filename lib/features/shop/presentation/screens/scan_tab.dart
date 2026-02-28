import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.leafGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  size: 44,
                  color: AppColors.leafGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.t('scan_placeholder_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.t('scan_placeholder_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.darkGrey, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
