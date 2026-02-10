import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/dish_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';
import '../../../shared/repositories/shopping_repository.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pantryTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.pantrySearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: ingredientsAsync.when(
              data: (ingredients) {
                var filtered = ingredients
                    .where((i) => i.nameLowerCase.contains(_searchQuery))
                    .toList();

                filtered.sort((a, b) {
                  final aHasExpiry = a.expiryDate != null;
                  final bHasExpiry = b.expiryDate != null;
                  final aIsEmpty = a.quantity == 0;
                  final bIsEmpty = b.quantity == 0;

                  if (aIsEmpty && !bIsEmpty) return 1;
                  if (!aIsEmpty && bIsEmpty) return -1;
                  if (aIsEmpty && bIsEmpty) {
                    return b.updatedAt.compareTo(a.updatedAt);
                  }

                  if (aHasExpiry && !bHasExpiry) return -1;
                  if (!aHasExpiry && bHasExpiry) return 1;
                  if (aHasExpiry && bHasExpiry) {
                    return a.expiryDate!.compareTo(b.expiryDate!);
                  }

                  return b.updatedAt.compareTo(a.updatedAt);
                });

                final expiringSoonCount = filtered.where((i) => i.isExpiringSoon || i.isExpired).length;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? l10n.pantryEmpty
                              : l10n.pantryNoResults,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.pantryAddIngredients,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (expiringSoonCount > 0)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.pantryExpiringSoon(expiringSoonCount),
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ingredient = filtered[index];
                          return _IngredientTile(ingredient: ingredient);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.errorGeneric(error.toString()))),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'scan',
            onPressed: () => context.push('/pantry/scan'),
            child: const Icon(Icons.receipt_long),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => _showAddIngredientDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.pantryAddButton),
          ),
        ],
      ),
    );
  }

  void _showAddIngredientDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = AppConstants.unitKeys.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.pantryAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.name),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: l10n.quantity),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: AppConstants.unitKeys
                          .map((u) => DropdownMenuItem(value: u, child: Text(AppConstants.localizedUnit(context, u))))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedUnit = value!);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final user = ref.read(authStateProvider).valueOrNull;
                  if (user == null) return;

                  final existingIngredient = await ref
                      .read(ingredientRepositoryProvider)
                      .findIngredientByName(
                        user.uid,
                        nameController.text.trim(),
                      );

                  if (existingIngredient != null) {
                    await ref.read(ingredientRepositoryProvider).addQuantity(
                          existingIngredient,
                          double.tryParse(quantityController.text) ?? 1,
                        );
                  } else {
                    await ref.read(ingredientRepositoryProvider).createIngredient(
                          Ingredient(
                            id: '',
                            userId: user.uid,
                            name: nameController.text.trim().toLowerCase(),
                            quantity:
                                double.tryParse(quantityController.text) ?? 1,
                            unit: selectedUnit,
                            addedAt: DateTime.now(),
                          ),
                        );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientTile extends ConsumerWidget {
  final Ingredient ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _editIngredient(context, ref),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: l10n.edit,
            ),
            SlidableAction(
              onPressed: (_) => _deleteIngredient(context, ref),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: Card(
          color: ingredient.quantity == 0
              ? Colors.grey.withOpacity(0.1)
              : ingredient.isExpired 
                  ? Colors.red.withOpacity(0.1)
                  : ingredient.isExpiringSoon 
                      ? Colors.orange.withOpacity(0.1)
                      : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ingredient.quantity == 0
                  ? Colors.grey.withOpacity(0.2)
                  : ingredient.isExpired
                      ? Colors.red.withOpacity(0.2)
                      : ingredient.isExpiringSoon
                          ? Colors.orange.withOpacity(0.2)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                ingredient.quantity == 0
                    ? Icons.remove_shopping_cart
                    : ingredient.isExpired 
                        ? Icons.error_outline
                        : ingredient.isExpiringSoon 
                            ? Icons.warning_amber
                            : Icons.restaurant_menu,
                color: ingredient.quantity == 0
                    ? Colors.grey
                    : ingredient.isExpired
                        ? Colors.red
                        : ingredient.isExpiringSoon
                            ? Colors.orange
                            : Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              ingredient.name.substring(0, 1).toUpperCase() +
                  ingredient.name.substring(1),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ingredient.quantity == 0 ? Colors.grey : null,
              ),
            ),
            subtitle: _buildExpiryText(context),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ingredient.quantity == 0
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                ingredient.displayText,
                style: TextStyle(
                  color: ingredient.quantity == 0 
                      ? Colors.red 
                      : Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildExpiryText(BuildContext context) {
    if (ingredient.expiryDate == null) return null;
    final l10n = AppLocalizations.of(context)!;
    
    final days = ingredient.daysUntilExpiry!;
    String text;
    Color color;
    
    if (days < 0) {
      text = l10n.pantryExpiredDaysAgo(-days);
      color = Colors.red;
    } else if (days == 0) {
      text = l10n.pantryExpiresToday;
      color = Colors.red;
    } else if (days == 1) {
      text = l10n.pantryExpiresTomorrow;
      color = Colors.orange;
    } else if (days <= 3) {
      text = l10n.pantryExpiresInDays(days);
      color = Colors.orange;
    } else {
      text = l10n.pantryExpiresOn(DateFormat('dd/MM/yy').format(ingredient.expiryDate!));
      color = Colors.grey;
    }
    
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
    );
  }

  void _editIngredient(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quantityText = ingredient.quantity == ingredient.quantity.toInt()
        ? ingredient.quantity.toInt().toString()
        : ingredient.quantity.toString();
    final quantityController = TextEditingController(text: quantityText);
    String selectedUnit = ingredient.unit;
    DateTime? selectedExpiryDate = ingredient.expiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.pantryEditTitle(ingredient.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: l10n.quantity),
                      keyboardType: TextInputType.number,
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: AppConstants.unitKeys
                          .map((u) => DropdownMenuItem(value: u, child: Text(AppConstants.localizedUnit(context, u))))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedUnit = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    helpText: l10n.pantryExpiryDate,
                  );
                  if (date != null) {
                    setDialogState(() => selectedExpiryDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.pantryExpiry,
                    suffixIcon: selectedExpiryDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setDialogState(() => selectedExpiryDate = null);
                            },
                          )
                        : const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedExpiryDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedExpiryDate!)
                        : l10n.pantryNoDate,
                    style: TextStyle(
                      color: selectedExpiryDate != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newQuantity = double.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity >= 0) {
                  ref.read(ingredientRepositoryProvider).updateIngredient(
                        ingredient.copyWith(
                          quantity: newQuantity,
                          unit: selectedUnit,
                          expiryDate: selectedExpiryDate,
                          clearExpiryDate: selectedExpiryDate == null && ingredient.expiryDate != null,
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIngredient(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final dishesAsync = ref.read(dishesStreamProvider);
    final shoppingAsync = ref.read(shoppingItemsStreamProvider);
    
    final dishes = dishesAsync.valueOrNull ?? [];
    final shoppingItems = shoppingAsync.valueOrNull ?? [];
    
    final ingredientNameLower = ingredient.nameLowerCase;
    
    final dishesUsingIngredient = dishes
        .where((d) => d.ingredients.any(
            (i) => i.name.toLowerCase().trim() == ingredientNameLower))
        .toList();
    
    final shoppingItemsUsingIngredient = shoppingItems
        .where((s) => s.name.toLowerCase().trim() == ingredientNameLower)
        .toList();
    
    if (dishesUsingIngredient.isNotEmpty || shoppingItemsUsingIngredient.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.pantryCannotDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pantryUsedIn(ingredient.name),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              if (dishesUsingIngredient.isNotEmpty) ...[
                Text(l10n.pantryDishesLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...dishesUsingIngredient.map((d) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('• ${d.name}'),
                )),
                const SizedBox(height: 8),
              ],
              if (shoppingItemsUsingIngredient.isNotEmpty) ...[
                Text(l10n.pantryShoppingLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...shoppingItemsUsingIngredient.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('• ${s.displayText}'),
                )),
              ],
              const SizedBox(height: 12),
              Text(
                l10n.pantryDeleteFirst,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.pantryUnderstood),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pantryDeleteTitle),
        content: Text(l10n.pantryDeleteConfirm(ingredient.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(ingredientRepositoryProvider).deleteIngredient(ingredient.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
