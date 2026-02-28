import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const plants = [
      _PlantItem(
        name: 'Monstera Deliciosa',
        category: 'Indoor',
        price: 32.0,
        rating: 4.8,
        icon: Icons.spa_rounded,
      ),
      _PlantItem(
        name: 'Golden Pothos',
        category: 'Air Purifier',
        price: 18.5,
        rating: 4.6,
        icon: Icons.local_florist_rounded,
      ),
      _PlantItem(
        name: 'Fiddle Leaf Fig',
        category: 'Living Room',
        price: 45.0,
        rating: 4.9,
        icon: Icons.park_rounded,
      ),
      _PlantItem(
        name: 'Ceramic Pot - Sand',
        category: 'Pot',
        price: 15.0,
        rating: 4.5,
        icon: Icons.yard_rounded,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4FBF7), Color(0xFFFDFEFD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          children: [
            Text(
              t.t('home_title'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.blackLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.t('home_subtitle'),
              style: const TextStyle(color: AppColors.darkGrey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: t.t('home_search_hint'),
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.leafGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(t.t('category_indoor'), true),
                  _chip(t.t('category_outdoor'), false),
                  _chip(t.t('category_pot'), false),
                  _chip(t.t('category_air'), false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.t('popular_plants'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.blackLight,
              ),
            ),
            const SizedBox(height: 14),
            ...plants.map((plant) => _PlantCard(item: plant)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.leafGreen : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.leafGreen : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.blackLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.item});

  final _PlantItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.leafGreenSoft, AppColors.leafMint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: AppColors.leafGreenDark, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(color: AppColors.darkGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB648), size: 18),
                    const SizedBox(width: 4),
                    Text('${item.rating}'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.leafGreenDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.leafGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.add, color: AppColors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlantItem {
  const _PlantItem({
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
  });

  final String name;
  final String category;
  final double price;
  final double rating;
  final IconData icon;
}
