import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
        children: [
          Text(
            t.t('cart_title'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const _CartItemTile(
            name: 'Monstera Deliciosa',
            variant: '18cm pot',
            price: 32.0,
            quantity: 1,
          ),
          const _CartItemTile(
            name: 'Ceramic Pot - Sand',
            variant: 'Medium',
            price: 15.0,
            quantity: 2,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: const [
                _PriceRow(label: 'Subtotal', value: '\$62.00'),
                SizedBox(height: 8),
                _PriceRow(label: 'Delivery', value: '\$4.00'),
                Divider(height: 24, color: AppColors.cardBorder),
                _PriceRow(label: 'Total', value: '\$66.00', isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.leafGreen,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(t.t('checkout_now')),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String variant;
  final double price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.leafGreenSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.spa_rounded, color: AppColors.leafGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(variant, style: const TextStyle(color: AppColors.darkGrey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.leafGreenDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text('x$quantity'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 15,
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
      color: isTotal ? AppColors.blackLight : AppColors.darkGrey,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}
