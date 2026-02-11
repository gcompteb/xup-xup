import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/dish.dart';
import '../../../shared/repositories/dish_repository.dart';
import '../providers/dishes_provider.dart';

class DishesScreen extends ConsumerStatefulWidget {
  const DishesScreen({super.key});

  @override
  ConsumerState<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends ConsumerState<DishesScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(dishesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dishesTitle),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(dishFilterProvider) == 'favorites' 
                  ? Icons.star 
                  : Icons.star_border,
            ),
            onPressed: () {
              final current = ref.read(dishFilterProvider);
              ref.read(dishFilterProvider.notifier).state = 
                  current == 'favorites' ? 'all' : 'favorites';
            },
            tooltip: l10n.dishesFilterFavorites,
          ),
        ],
      ),
      body: dishesAsync.when(
        data: (dishes) {
          final filter = ref.watch(dishFilterProvider);
          final filteredDishes = _filterDishes(dishes, filter, _searchQuery);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.dishesSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: filteredDishes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? l10n.dishesNoMatch(_searchQuery)
                                  : filter == 'all'
                                      ? l10n.dishesEmpty
                                      : l10n.dishesEmptyFilter,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                l10n.dishesAddFirst,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDishes.length,
                        itemBuilder: (context, index) {
                          final dish = filteredDishes[index];
                          return _DishCard(dish: dish);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric(error.toString()))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/dishes/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.dishesNewDish),
      ),
    );
  }

  List<Dish> _filterDishes(List<Dish> dishes, String filter, String searchQuery) {
    var filtered = dishes.toList();
    if (filter == 'favorites') {
      filtered = filtered.where((d) => d.isFavorite).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((d) => 
        d.name.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }
}

class _DishCard extends ConsumerWidget {
  final Dish dish;

  const _DishCard({required this.dish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _toggleFavorite(ref),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              icon: dish.isFavorite ? Icons.star : Icons.star_border,
              label: dish.isFavorite ? l10n.dishesRemoveFav : l10n.dishesFavorite,
            ),
            SlidableAction(
              onPressed: (_) => _deleteDish(context, ref),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.go('/dishes/${dish.id}'),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: dish.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: dish.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dish.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (dish.healthLevel == 'healthy')
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            if (dish.healthLevel == 'unhealthy')
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                            if (dish.isFavorite)
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dish.prepTimeDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.signal_cellular_alt,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppConstants.localizedDifficulty(context, dish.difficulty),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.dishesIngCount(dish.ingredients.length),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.restaurant,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref) {
    ref.read(dishRepositoryProvider).toggleFavorite(dish);
  }

  void _deleteDish(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dishesDeleteTitle),
        content: Text(l10n.dishesDeleteConfirm(dish.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(dishRepositoryProvider).deleteDish(dish);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
