import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/dish.dart';
import '../../../shared/models/dish_ingredient.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/repositories/dish_repository.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';
import '../../../features/auth/providers/auth_provider.dart';

class _PantryItem {
  final double quantity;
  final String unit;
  _PantryItem(this.quantity, this.unit);
}

class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  bool _showOnlyComplete = true;
  String? _highlightedDishId;
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
    final ingredientsAsync = ref.watch(ingredientsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suggestionsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: dishesAsync.when(
        data: (dishes) => ingredientsAsync.when(
          data: (ingredients) {
            final pantryMap = {
              for (final i in ingredients) 
                i.nameLowerCase: _PantryItem(i.quantity, i.unit)
            };
            
            final dishesWithAvailability = dishes.map((dish) {
              return _DishWithAvailability.calculate(dish, pantryMap);
            }).toList();

            var filtered = dishesWithAvailability.where((d) {
              if (_showOnlyComplete && !d.isComplete) {
                return false;
              }
              if (_searchQuery.isNotEmpty && 
                  !d.dish.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                return false;
              }
              return true;
            }).toList();

            filtered.sort((a, b) {
              if (_highlightedDishId != null) {
                if (a.dish.id == _highlightedDishId) return -1;
                if (b.dish.id == _highlightedDishId) return 1;
              }
              if (a.dish.isFavorite != b.dish.isFavorite) {
                return a.dish.isFavorite ? -1 : 1;
              }
              if (a.ratio != b.ratio) {
                return b.ratio.compareTo(a.ratio);
              }
              return b.dish.updatedAt.compareTo(a.dish.updatedAt);
            });

            return Column(
              children: [
                _buildFilters(context, ingredients),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(dishes.isEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _SuggestionCard(
                              data: filtered[index],
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(l10n.errorGeneric(error.toString()))),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric(error.toString()))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickRandom(context),
        icon: const Icon(Icons.casino),
        label: Text(l10n.suggestionsSurprise),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, List<Ingredient> ingredients) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
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
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                label: Text(l10n.suggestionsHaveAll),
                selected: _showOnlyComplete,
                onSelected: (value) {
                  setState(() => _showOnlyComplete = value);
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.suggestionsInPantry(ingredients.length),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool noDishes) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noDishes ? Icons.restaurant_menu : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            noDishes
                ? l10n.suggestionsNoDishesCreated
                : l10n.suggestionsNoFilterMatch,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (noDishes) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/dishes/add'),
              child: Text(l10n.suggestionsCreateFirst),
            ),
          ],
        ],
      ),
    );
  }

  void _pickRandom(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dishes = ref.read(dishesStreamProvider).valueOrNull ?? [];
    final ingredients = ref.read(ingredientsStreamProvider).valueOrNull ?? [];
    
    if (dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.suggestionsNoDishesCreated)),
      );
      return;
    }

    final pantryMap = {
      for (final i in ingredients) 
        i.nameLowerCase: _PantryItem(i.quantity, i.unit)
    };

    var filtered = dishes.where((dish) {
      if (_showOnlyComplete) {
        final data = _DishWithAvailability.calculate(dish, pantryMap);
        return data.isComplete;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.suggestionsNoFilterMatch)),
      );
      return;
    }

    final random = Random();
    final selectedDish = filtered[random.nextInt(filtered.length)];

    setState(() => _highlightedDishId = selectedDish.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.casino, color: Colors.amber),
            const SizedBox(width: 8),
            Text(l10n.suggestionsTodayCook),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedDish.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: selectedDish.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              selectedDish.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedDish.prepTimeDisplay} • ${AppConstants.localizedDifficulty(context, selectedDish.difficulty)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/dishes/${selectedDish.id}');
            },
            child: Text(l10n.suggestionsViewRecipe),
          ),
        ],
      ),
    );
  }
}

class _DishWithAvailability {
  final Dish dish;
  final Map<String, _PantryItem> pantryMap;
  final int requiredAvailable;
  final int requiredTotal;
  final int alternativeGroupsSatisfied;
  final int alternativeGroupsTotal;
  final int optionalAvailable;
  final int optionalTotal;

  _DishWithAvailability._({
    required this.dish,
    required this.pantryMap,
    required this.requiredAvailable,
    required this.requiredTotal,
    required this.alternativeGroupsSatisfied,
    required this.alternativeGroupsTotal,
    required this.optionalAvailable,
    required this.optionalTotal,
  });

  factory _DishWithAvailability.calculate(Dish dish, Map<String, _PantryItem> pantryMap) {
    final required = dish.ingredients.where((i) => i.isRequired).toList();
    final optional = dish.ingredients.where((i) => i.isOptional).toList();
    final alternativeGroups = <String, List<DishIngredient>>{};
    
    for (final i in dish.ingredients) {
      if (i.alternativeGroupId != null) {
        alternativeGroups.putIfAbsent(i.alternativeGroupId!, () => []).add(i);
      }
    }

    int requiredAvailable = 0;
    for (final i in required) {
      if (_hasEnoughStatic(pantryMap, i.name, i.quantity, i.unit)) {
        requiredAvailable++;
      }
    }

    int alternativeGroupsSatisfied = 0;
    for (final group in alternativeGroups.values) {
      final anyAvailable = group.any((i) => _hasEnoughStatic(pantryMap, i.name, i.quantity, i.unit));
      if (anyAvailable) alternativeGroupsSatisfied++;
    }

    int optionalAvailable = 0;
    for (final i in optional) {
      if (_hasEnoughStatic(pantryMap, i.name, i.quantity, i.unit)) {
        optionalAvailable++;
      }
    }

    return _DishWithAvailability._(
      dish: dish,
      pantryMap: pantryMap,
      requiredAvailable: requiredAvailable,
      requiredTotal: required.length,
      alternativeGroupsSatisfied: alternativeGroupsSatisfied,
      alternativeGroupsTotal: alternativeGroups.length,
      optionalAvailable: optionalAvailable,
      optionalTotal: optional.length,
    );
  }

  static bool _hasEnoughStatic(Map<String, _PantryItem> pantryMap, String name, double needed, String neededUnit) {
    final pantryItem = pantryMap[name.toLowerCase().trim()];
    if (pantryItem == null) return false;
    
    if (UnitConverter.areCompatible(pantryItem.unit, neededUnit)) {
      final availableInNeededUnit = UnitConverter.convert(
        pantryItem.quantity, pantryItem.unit, neededUnit);
      return availableInNeededUnit >= needed - 0.05;
    } else {
      return pantryItem.quantity >= needed - 0.05;
    }
  }

  int get availableCount => requiredAvailable + alternativeGroupsSatisfied;
  int get totalCount => requiredTotal + alternativeGroupsTotal;
  
  double get ratio => totalCount == 0 ? 1.0 : availableCount / totalCount;
  bool get isComplete => requiredAvailable >= requiredTotal && alternativeGroupsSatisfied >= alternativeGroupsTotal;
  
  bool hasEnough(String ingredientName, double needed, String neededUnit) {
    return _hasEnoughStatic(pantryMap, ingredientName, needed, neededUnit);
  }
  
  double getAvailable(String ingredientName, String neededUnit) {
    final pantryItem = pantryMap[ingredientName.toLowerCase().trim()];
    if (pantryItem == null) return 0;
    
    if (UnitConverter.areCompatible(pantryItem.unit, neededUnit)) {
      return UnitConverter.convert(pantryItem.quantity, pantryItem.unit, neededUnit);
    }
    return pantryItem.quantity;
  }
}

class _SuggestionCard extends ConsumerWidget {
  final _DishWithAvailability data;

  const _SuggestionCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dish = data.dish;
    final isComplete = data.isComplete;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/dishes/${dish.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
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
                              if (dish.isFavorite)
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dish.prepTimeDisplay} • ${AppConstants.localizedDifficulty(context, dish.difficulty)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isComplete
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      size: 14,
                                      color: isComplete ? Colors.green : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${data.availableCount}/${data.totalCount} ing.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isComplete ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
              if (!isComplete && data.totalCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: dish.ingredients.map((ing) {
                      final hasIt = data.hasEnough(ing.name, ing.quantity, ing.unit);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasIt
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasIt
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          ing.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasIt ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isComplete ? () => _markAsCooked(context, ref) : null,
                    icon: const Icon(Icons.restaurant),
                    label: Text(isComplete ? l10n.dishCooked : l10n.dishMissingIngredients),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsCooked(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dish = data.dish;
    final pantryMap = data.pantryMap;
    int selectedServings = dish.servings;
    
    final required = dish.ingredients.where((i) => i.isRequired).toList();
    final optional = dish.ingredients.where((i) => i.isOptional).toList();
    final alternativeGroups = <String, List<DishIngredient>>{};
    for (final i in dish.ingredients) {
      if (i.alternativeGroupId != null) {
        alternativeGroups.putIfAbsent(i.alternativeGroupId!, () => []).add(i);
      }
    }
    
    final selectedAlternatives = <String, Set<String>>{};
    for (final entry in alternativeGroups.entries) {
      selectedAlternatives[entry.key] = {};
      for (final i in entry.value) {
        if (data.hasEnough(i.name, i.quantity, i.unit)) {
          selectedAlternatives[entry.key]!.add(i.name);
        }
      }
      if (selectedAlternatives[entry.key]!.isEmpty) {
        selectedAlternatives[entry.key]!.add(entry.value.first.name);
      }
    }
    
    final selectedOptionals = <String, bool>{};
    for (final opt in optional) {
      selectedOptionals[opt.name] = data.hasEnough(opt.name, opt.quantity, opt.unit);
    }
    
    String formatQuantity(double q) {
      return q == q.toInt() ? q.toInt().toString() : q.toStringAsFixed(1);
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final multiplier = selectedServings / dish.servings;
          
          List<DishIngredient> getIngredientsToSubtract() {
            final result = <DishIngredient>[];
            result.addAll(required);
            for (final entry in alternativeGroups.entries) {
              for (final i in entry.value) {
                if (selectedAlternatives[entry.key]?.contains(i.name) == true) {
                  result.add(i);
                }
              }
            }
            for (final opt in optional) {
              if (selectedOptionals[opt.name] == true) {
                result.add(opt);
              }
            }
            return result;
          }
          
          Widget buildIngredientRow(String name, double needed, String unit) {
            final available = data.getAvailable(name, unit);
            final hasEnough = available >= needed - 0.05;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(hasEnough ? Icons.check_circle : Icons.warning, size: 16, color: hasEnough ? Colors.green : Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('-${formatQuantity(needed)} $unit', style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
                      Text('${formatQuantity(available)} → ${formatQuantity((available - needed) < 0 ? 0 : (available - needed))}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            );
          }
          
          final dialogL10n = AppLocalizations.of(context)!;
          
          return AlertDialog(
            title: Text(dialogL10n.dishMarkCooked),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dialogL10n.dishServings),
                        IconButton(
                          onPressed: selectedServings > 1
                              ? () => setDialogState(() => selectedServings--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$selectedServings', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: () => setDialogState(() => selectedServings++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    if (selectedServings != dish.servings)
                      Center(
                        child: Text(
                          dialogL10n.dishRecipeServingsChange(dish.servings, selectedServings),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    if (required.isNotEmpty) ...[
                      Text(dialogL10n.dishRequired, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      ...required.map((ing) => buildIngredientRow(ing.name, ing.quantity * multiplier, ing.unit)),
                    ],
                    
                    for (final entry in alternativeGroups.entries) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(dialogL10n.dishAlternativesMin1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blue[700])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...entry.value.map((ing) {
                        final isSelected = selectedAlternatives[entry.key]?.contains(ing.name) == true;
                        final needed = ing.quantity * multiplier;
                        final available = data.getAvailable(ing.name, ing.unit);
                        final hasEnough = available >= needed - 0.05;
                        return InkWell(
                          onTap: () => setDialogState(() {
                            if (isSelected && selectedAlternatives[entry.key]!.length > 1) {
                              selectedAlternatives[entry.key]!.remove(ing.name);
                            } else if (!isSelected) {
                              selectedAlternatives[entry.key]!.add(ing.name);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => setDialogState(() {
                                    if (!v! && selectedAlternatives[entry.key]!.length > 1) {
                                      selectedAlternatives[entry.key]!.remove(ing.name);
                                    } else if (v) {
                                      selectedAlternatives[entry.key]!.add(ing.name);
                                    }
                                  }),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(ing.name, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : null)),
                                      const SizedBox(width: 4),
                                      if (!hasEnough) Icon(Icons.warning, size: 14, color: Colors.orange[700]),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('-${formatQuantity(needed)} ${ing.unit}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                                      Text('${formatQuantity(available)} → ${formatQuantity((available - needed) < 0 ? 0 : (available - needed))}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    if (optional.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(dialogL10n.dishOptionalsLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.orange[700])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...optional.map((ing) {
                        final isSelected = selectedOptionals[ing.name] == true;
                        final needed = ing.quantity * multiplier;
                        final available = data.getAvailable(ing.name, ing.unit);
                        final hasEnough = available >= needed - 0.05;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedOptionals[ing.name] = !isSelected),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.withValues(alpha: 0.1) : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => setDialogState(() => selectedOptionals[ing.name] = v!),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(ing.name, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : null)),
                                      const SizedBox(width: 4),
                                      if (!hasEnough) Icon(Icons.warning, size: 14, color: Colors.orange[700]),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('-${formatQuantity(needed)} ${ing.unit}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                                      Text('${formatQuantity(available)} → ${formatQuantity((available - needed) < 0 ? 0 : (available - needed))}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(dialogL10n.cancel),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  final user = ref.read(authStateProvider).valueOrNull;
                  if (user == null) return;
                  
                  try {
                    final toSubtract = getIngredientsToSubtract();
                    final ingredients = toSubtract
                        .map((i) => {
                              'name': i.name,
                              'quantity': i.quantity * multiplier,
                              'unit': i.unit,
                            })
                        .toList();
                    
                    await ref.read(ingredientRepositoryProvider).subtractIngredientsForDish(
                      user.uid,
                      ingredients,
                    );
                    
                    await ref.read(dishRepositoryProvider).markAsCooked(dish.id);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(dialogL10n.dishCookedSuccess(dish.name, selectedServings)),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(dialogL10n.errorGeneric(e.toString())),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check),
                label: Text(dialogL10n.dishCooked),
              ),
            ],
          );
        },
      ),
    );
  }
}
