import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/models/shopping_item.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';
import '../../../shared/repositories/shopping_repository.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingAsync = ref.watch(shoppingItemsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingTitle),
        actions: [
          shoppingAsync.whenOrNull(
            data: (items) {
              final hasChecked = items.any((i) => i.isChecked);
              if (!hasChecked) return null;
              return PopupMenuButton<String>(
                onSelected: (value) {
                  final user = ref.read(authStateProvider).valueOrNull;
                  if (user == null) return;

                  if (value == 'transfer') {
                    _transferToPantry(context, ref, user.uid);
                  } else if (value == 'delete') {
                    ref.read(shoppingRepositoryProvider).deleteAllChecked(user.uid);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'transfer',
                    child: Row(
                      children: [
                        const Icon(Icons.move_to_inbox),
                        const SizedBox(width: 8),
                        Text(l10n.shoppingTransferToPantry),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.shoppingDeleteChecked, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: shoppingAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.shoppingEmpty,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.shoppingAddWhat,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final unchecked = items.where((i) => !i.isChecked).toList();
          final checked = items.where((i) => i.isChecked).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unchecked.isNotEmpty) ...[
                Text(
                  l10n.shoppingToBuy,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...unchecked.map((item) => _ShoppingItemTile(item: item)),
              ],
              if (checked.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      l10n.shoppingBought,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        final user = ref.read(authStateProvider).valueOrNull;
                        if (user != null) {
                          _transferToPantry(context, ref, user.uid);
                        }
                      },
                      icon: const Icon(Icons.move_to_inbox, size: 18),
                      label: Text(l10n.shoppingToPantry),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...checked.map((item) => _ShoppingItemTile(item: item)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric(error.toString()))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.shoppingAddButton),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.read(ingredientsStreamProvider);
    
    ingredientsAsync.when(
      data: (pantryIngredients) {
        _showIngredientPicker(context, ref, pantryIngredients);
      },
      loading: () {},
      error: (_, __) {
        _showIngredientPicker(context, ref, []);
      },
    );
  }

  void _showIngredientPicker(BuildContext context, WidgetRef ref, List<Ingredient> pantryIngredients) {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          final filtered = pantryIngredients
              .where((i) => i.nameLowerCase.contains(searchQuery.toLowerCase()))
              .toList();
          
          return AlertDialog(
            title: Text(l10n.shoppingAddToList),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.addDishSearch,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setDialogState(() => searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      child: const Icon(Icons.add, color: Colors.green),
                    ),
                    title: Text(l10n.shoppingNewIngredient),
                    subtitle: Text(l10n.shoppingAddToPantryAndList),
                    onTap: () {
                      Navigator.pop(context);
                      _showNewIngredientDialog(context, ref);
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              pantryIngredients.isEmpty
                                  ? l10n.shoppingNoPantryIngredients
                                  : l10n.shoppingNoIngredientsFound,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final ingredient = filtered[index];
                              return ListTile(
                                title: Text(
                                  ingredient.name.substring(0, 1).toUpperCase() +
                                      ingredient.name.substring(1),
                                ),
                                subtitle: Text(
                                  l10n.shoppingInPantry(ingredient.displayText),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showQuantityDialog(context, ref, ingredient);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, WidgetRef ref, Ingredient ingredient) {
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = ingredient.unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(
              ingredient.name.substring(0, 1).toUpperCase() +
                  ingredient.name.substring(1),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.shoppingInPantry(ingredient.displayText),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: AppConstants.unitKeys.contains(selectedUnit) ? selectedUnit : 'unitats',
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
                  final user = ref.read(authStateProvider).valueOrNull;
                  if (user == null) return;

                  await ref.read(shoppingRepositoryProvider).createShoppingItem(
                    ShoppingItem(
                      id: '',
                      userId: user.uid,
                      name: ingredient.name,
                      quantity: double.tryParse(quantityController.text) ?? 1,
                      unit: selectedUnit,
                      isChecked: false,
                      createdAt: DateTime.now(),
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNewIngredientDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = AppConstants.unitKeys.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.addDishNewIngredient),
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

                    await ref.read(ingredientRepositoryProvider).createIngredient(
                      Ingredient(
                        id: '',
                        userId: user.uid,
                        name: nameController.text.trim().toLowerCase(),
                        quantity: 0,
                        unit: selectedUnit,
                        addedAt: DateTime.now(),
                      ),
                    );

                    await ref.read(shoppingRepositoryProvider).createShoppingItem(
                      ShoppingItem(
                        id: '',
                        userId: user.uid,
                        name: nameController.text.trim().toLowerCase(),
                        quantity: double.tryParse(quantityController.text) ?? 1,
                        unit: selectedUnit,
                        isChecked: false,
                        createdAt: DateTime.now(),
                      ),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _transferToPantry(BuildContext context, WidgetRef ref, String userId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.shoppingTransferTitle),
          content: Text(dialogL10n.shoppingTransferBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(shoppingRepositoryProvider).transferCheckedToPantry(userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.shoppingTransferSuccess),
                  ),
                );
              },
              child: Text(dialogL10n.shoppingTransfer),
            ),
          ],
        );
      },
    );
  }
}

class _ShoppingItemTile extends ConsumerWidget {
  final ShoppingItem item;

  const _ShoppingItemTile({required this.item});

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
              onPressed: (_) {
                ref.read(shoppingRepositoryProvider).deleteShoppingItem(item.id);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: Card(
          child: ListTile(
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (_) {
                ref.read(shoppingRepositoryProvider).toggleChecked(item);
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? Colors.grey : null,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: item.isChecked
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item.displayText,
                style: TextStyle(
                  color: item.isChecked
                      ? Colors.grey
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
}
