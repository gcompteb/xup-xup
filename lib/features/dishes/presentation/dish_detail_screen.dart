import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/dish.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/dish_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';

class DishDetailScreen extends ConsumerWidget {
  final String dishId;

  const DishDetailScreen({super.key, required this.dishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(dishesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return dishesAsync.when(
      data: (dishes) {
        final dish = dishes.where((d) => d.id == dishId).firstOrNull;
        if (dish == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.dishNotFound)),
          );
        }
        return _DishDetailContent(dish: dish);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorGeneric(error.toString()))),
      ),
    );
  }
}

class _DishDetailContent extends ConsumerWidget {
  final Dish dish;

  const _DishDetailContent({required this.dish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                dish.name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: dish.imageUrl != null
                  ? GestureDetector(
                      onTap: () => _showFullScreenImage(context, dish.imageUrl!),
                      child: CachedNetworkImage(
                        imageUrl: dish.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey[300],
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 60),
                        ),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  dish.isFavorite ? Icons.star : Icons.star_border,
                  color: dish.isFavorite ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  ref.read(dishRepositoryProvider).toggleFavorite(dish);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.go('/dishes/${dish.id}/edit');
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(l10n.dishEdit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.people,
                        label: l10n.dishPersons(dish.servings),
                      ),
                      _InfoChip(
                        icon: Icons.timer,
                        label: dish.prepTimeDisplay,
                      ),
                      _InfoChip(
                        icon: Icons.signal_cellular_alt,
                        label: AppConstants.localizedDifficulty(context, dish.difficulty),
                      ),
                      if (dish.isHealthy)
                        _InfoChip(
                          icon: Icons.eco,
                          label: l10n.addDishHealthy,
                          color: Colors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.dishIngredients,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildIngredientsSection(context),
                  if (dish.steps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.dishSteps,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dish.steps.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(dish.steps[index]),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _markAsCooked(context, ref),
        icon: const Icon(Icons.restaurant),
        label: Text(l10n.dishCooked),
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final required = dish.ingredients.where((i) => i.isRequired).toList();
    final optional = dish.ingredients.where((i) => i.isOptional).toList();
    final alternativeGroups = <String, List<dynamic>>{};
    
    for (final i in dish.ingredients) {
      if (i.alternativeGroupId != null) {
        alternativeGroups.putIfAbsent(i.alternativeGroupId!, () => []).add(i);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required.isNotEmpty)
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: required.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final ingredient = required[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(ingredient.name),
                  trailing: Text(ingredient.displayText, style: TextStyle(color: Colors.grey[600])),
                );
              },
            ),
          ),
        for (final entry in alternativeGroups.entries) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.blue.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        l10n.dishAlternativesNeed1,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entry.value.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ingredient = entry.value[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        child: const Icon(Icons.swap_horiz, color: Colors.blue),
                      ),
                      title: Text(ingredient.name),
                      trailing: Text(ingredient.displayText, style: TextStyle(color: Colors.grey[600])),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        if (optional.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.orange.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        l10n.dishOptionals,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: optional.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ingredient = optional[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        child: const Icon(Icons.add_circle_outline, color: Colors.orange),
                      ),
                      title: Text(ingredient.name),
                      trailing: Text(ingredient.displayText, style: TextStyle(color: Colors.grey[600])),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _markAsCooked(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ingredientsAsync = ref.read(ingredientsStreamProvider);
    final pantryMap = <String, Map<String, dynamic>>{};
    
    ingredientsAsync.whenData((ingredients) {
      for (final i in ingredients) {
        pantryMap[i.nameLowerCase] = {'quantity': i.quantity, 'unit': i.unit};
      }
    });
    
    double getAvailable(String name, String neededUnit) {
      final item = pantryMap[name.toLowerCase().trim()];
      if (item == null) return 0;
      final qty = item['quantity'] as double;
      final unit = item['unit'] as String;
      if (UnitConverter.areCompatible(unit, neededUnit)) {
        return UnitConverter.convert(qty, unit, neededUnit);
      }
      return qty;
    }
    
    int selectedServings = dish.servings;
    
    final required = dish.ingredients.where((i) => i.isRequired).toList();
    final optional = dish.ingredients.where((i) => i.isOptional).toList();
    final alternativeGroups = <String, List<dynamic>>{};
    for (final i in dish.ingredients) {
      if (i.alternativeGroupId != null) {
        alternativeGroups.putIfAbsent(i.alternativeGroupId!, () => []).add(i);
      }
    }
    
    final selectedAlternatives = <String, Set<String>>{};
    for (final entry in alternativeGroups.entries) {
      selectedAlternatives[entry.key] = {};
      for (final i in entry.value) {
        if (getAvailable(i.name, i.unit) >= i.quantity - 0.05) {
          selectedAlternatives[entry.key]!.add(i.name);
        }
      }
      if (selectedAlternatives[entry.key]!.isEmpty) {
        selectedAlternatives[entry.key]!.add(entry.value.first.name);
      }
    }
    
    final selectedOptionals = <String, bool>{};
    for (final opt in optional) {
      selectedOptionals[opt.name] = getAvailable(opt.name, opt.unit) >= opt.quantity - 0.05;
    }
    
    String formatQuantity(double q) {
      return q == q.toInt() ? q.toInt().toString() : q.toStringAsFixed(1);
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final multiplier = selectedServings / dish.servings;
          
          List<dynamic> getIngredientsToSubtract() {
            final result = <dynamic>[];
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
          
          return AlertDialog(
            title: Text(l10n.dishMarkCooked),
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
                        Text(l10n.dishServings),
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
                          child: Text(
                            '$selectedServings',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
                          l10n.dishRecipeServingsChange(dish.servings, selectedServings),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    if (required.isNotEmpty) ...[
                      Text(l10n.dishRequired, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      ...required.map((ing) {
                        final needed = ing.quantity * multiplier;
                        final available = getAvailable(ing.name, ing.unit);
                        final hasEnough = available >= needed - 0.05;
                        return _buildIngredientRow(ing.name, needed, ing.unit, available, hasEnough, formatQuantity);
                      }),
                    ],
                    
                    for (final entry in alternativeGroups.entries) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(l10n.dishAlternativesMin1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blue[700])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...entry.value.map((ing) {
                        final isSelected = selectedAlternatives[entry.key]?.contains(ing.name) == true;
                        final needed = ing.quantity * multiplier;
                        final available = getAvailable(ing.name, ing.unit);
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
                          Text(l10n.dishOptionalsLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.orange[700])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...optional.map((ing) {
                        final isSelected = selectedOptionals[ing.name] == true;
                        final needed = ing.quantity * multiplier;
                        final available = getAvailable(ing.name, ing.unit);
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
                child: Text(l10n.cancel),
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
                          content: Text(l10n.dishCookedSuccess(dish.name, selectedServings)),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.errorGeneric(e.toString())),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.dishCooked),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIngredientRow(String name, double needed, String unit, double available, bool hasEnough, String Function(double) formatQuantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasEnough ? Icons.check_circle : Icons.warning,
            size: 16,
            color: hasEnough ? Colors.green : Colors.orange,
          ),
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black87,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
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
              context.go('/dishes');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
