import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/data/storage_service.dart';
import '../../../scan/presentation/screens/camera_realtime_scan_screen.dart';
import '../../domain/local_shop_catalog.dart';
import '../../domain/models/shop_product.dart';
import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _pageSize = 8;

  String _selectedCategorySlug = 'all';
  int _currentPage = 0;
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final fullName = (await StorageService.getFullName())?.trim() ?? '';
    if (!mounted) return;
    setState(() => _fullName = fullName);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectCategory(String slug) {
    setState(() {
      _selectedCategorySlug = slug;
      _currentPage = 0;
    });
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() => _currentPage = page);
  }

  String get _headlineName {
    return AppLocalizations.of(context).t('home_greeting_friend');
  }

  String get _avatarInitial {
    if (_fullName.trim().isNotEmpty) {
      return _fullName.trim().substring(0, 1).toUpperCase();
    }
    return _headlineName.substring(0, 1).toUpperCase();
  }

  String _categoryLabel(AppLocalizations t, ProductCategory category) {
    switch (category.slug) {
      case 'indoor-plants':
        return t.t('category_indoor');
      case 'outdoor-plants':
        return t.t('category_outdoor');
      case 'cacti-succulents':
        return t.t('category_cactus');
      case 'ornamental-plants':
        return t.t('category_ornamental');
      case 'aquatic-plants':
        return t.t('category_hydro');
      default:
        return category.name;
    }
  }

  List<ShopProduct> get _pageItems => LocalShopCatalog.pageItems(
        categorySlug: _selectedCategorySlug,
        page: _currentPage,
        pageSize: _pageSize,
      );

  int get _totalPages => LocalShopCatalog.totalPages(
        categorySlug: _selectedCategorySlug,
        pageSize: _pageSize,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    final categoryOptions = [
      _HomeCategoryOption(slug: 'all', label: t.t('category_all')),
      for (final category in LocalShopCatalog.categories)
        _HomeCategoryOption(slug: category.slug, label: category.name),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => _showMessage(t.t('home_menu_coming_soon')),
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                ),
                Expanded(
                  child: Text(
                    t.t('home_brand_title'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 24,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showMessage(t.t('home_account_coming_soon')),
                  icon: const Icon(Icons.account_circle_outlined, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.t('home_greeting_prefix'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _headlineName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.blackLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.secondaryContainer, AppColors.primaryFixed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _avatarInitial,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.t('home_search_hint'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.outline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CameraRealtimeScanScreen()),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.center_focus_strong,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categoryOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = categoryOptions[index];
                  final selected = option.slug == _selectedCategorySlug;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.secondaryContainer,
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                    ),
                    onSelected: (_) => _selectCategory(option.slug),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.t('popular_plants'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.blackLight,
                      fontSize: 24,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _totalPages > 1 ? () => _changePage((_currentPage + 1) % _totalPages) : null,
                  label: Text(t.t('home_view_all')),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pageItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = _pageItems[index];
                return _ProductCard(
                  product: product,
                  categoryLabel: _categoryLabel(t, product.category),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                  onAdd: () => _showMessage(
                    t.t('product_added_to_cart').replaceFirst('{name}', product.name),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _PaginationRow(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageSelected: _changePage,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoryOption {
  const _HomeCategoryOption({required this.slug, required this.label});

  final String slug;
  final String label;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.categoryLabel,
    required this.onTap,
    required this.onAdd,
  });

  final ShopProduct product;
  final String categoryLabel;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = product.defaultVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    product.primaryImage.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.ratingAvg.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      categoryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.blackLight,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${variant.price.toStringAsFixed(2)}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: AppColors.white, size: 18),
                          ),
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
    );
  }
}

class _PaginationRow extends StatelessWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    final visiblePages = List.generate(totalPages, (index) => index).take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageArrow(
          icon: Icons.chevron_left,
          enabled: currentPage > 0,
          onTap: () => onPageSelected(currentPage - 1),
        ),
        const SizedBox(width: 8),
        for (final page in visiblePages) ...[
          _PageChip(
            label: '${page + 1}',
            selected: page == currentPage,
            onTap: () => onPageSelected(page),
          ),
          const SizedBox(width: 8),
        ],
        if (totalPages > 3) ...[
          Text(
            '...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          _PageChip(
            label: '$totalPages',
            selected: currentPage == totalPages - 1,
            onTap: () => onPageSelected(totalPages - 1),
          ),
          const SizedBox(width: 8),
        ],
        _PageArrow(
          icon: Icons.chevron_right,
          enabled: currentPage < totalPages - 1,
          onTap: () => onPageSelected(currentPage + 1),
        ),
      ],
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Icon(
        icon,
        color: enabled ? AppColors.primary : AppColors.outlineVariant,
      ),
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
