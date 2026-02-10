import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/dish.dart';
import '../../../shared/models/dish_ingredient.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/dish_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';

class AddDishScreen extends ConsumerStatefulWidget {
  final String? editDishId;

  const AddDishScreen({super.key, this.editDishId});

  @override
  ConsumerState<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends ConsumerState<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController(text: '2');
  final _prepTimeController = TextEditingController();
  
  String _selectedDifficulty = AppConstants.difficultyKeys[1];
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _existingImageUrl;
  List<DishIngredient> _ingredients = [];
  List<String> _steps = [];
  bool _isLoading = false;
  bool _isEditing = false;
  Dish? _existingDish;

  @override
  void initState() {
    super.initState();
    if (widget.editDishId != null) {
      _isEditing = true;
      _loadExistingDish();
    }
  }

  Future<void> _loadExistingDish() async {
    setState(() => _isLoading = true);
    final dish = await ref.read(dishRepositoryProvider).getDish(widget.editDishId!);
    if (dish != null && mounted) {
      setState(() {
        _existingDish = dish;
        _nameController.text = dish.name;
        _servingsController.text = dish.servings.toString();
        _prepTimeController.text = dish.prepTimeMinutes.toString();
        _selectedDifficulty = AppConstants.normalizeDifficultyKey(dish.difficulty);
        _existingImageUrl = dish.imageUrl;
        _ingredients = List.from(dish.ingredients);
        _steps = List.from(dish.steps);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.addDishCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.addDishGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  void _addIngredient() {
    final l10n = AppLocalizations.of(context)!;
    final ingredientsAsync = ref.read(ingredientsStreamProvider);
    
    ingredientsAsync.when(
      data: (pantryIngredients) {
        final alreadyAdded = _ingredients.map((i) => i.name.toLowerCase().trim()).toSet();
        final available = pantryIngredients
            .where((i) => !alreadyAdded.contains(i.nameLowerCase))
            .toList();
        
        if (available.isEmpty && pantryIngredients.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addDishFirstAddPantry)),
          );
          return;
        }
        
        if (available.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addDishAllAdded)),
          );
          return;
        }
        
        _showIngredientPicker(available);
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _showIngredientPicker(List<Ingredient> available) {
    final l10n = AppLocalizations.of(context)!;
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = available
              .where((i) => i.nameLowerCase.contains(searchQuery.toLowerCase()))
              .toList();
          
          return AlertDialog(
            title: Text(l10n.addDishSelectIngredient),
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
                    title: Text(l10n.addDishCreateNew),
                    subtitle: Text(l10n.addDishAddToPantry),
                    onTap: () {
                      Navigator.pop(context);
                      _showNewIngredientForDishDialog();
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              available.isEmpty
                                  ? l10n.addDishNoPantryIngredients
                                  : l10n.addDishNoIngredientsFound,
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
                                  l10n.addDishAvailable(ingredient.displayText),
                                  style: TextStyle(
                                    color: ingredient.quantity > 0
                                        ? Colors.green[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showQuantityDialog(ingredient);
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

  void _showNewIngredientForDishDialog() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = AppConstants.unitKeys.first;
    bool isOptional = false;
    String? alternativeGroupId;

    final existingGroups = _ingredients
        .where((i) => i.alternativeGroupId != null)
        .map((i) => i.alternativeGroupId!)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addDishNewIngredient),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(l10n.typeLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeRequired,
                        icon: Icons.check_circle,
                        color: Colors.green,
                        selected: !isOptional && alternativeGroupId == null,
                        onTap: () => setDialogState(() {
                          isOptional = false;
                          alternativeGroupId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeOptional,
                        icon: Icons.add_circle_outline,
                        color: Colors.orange,
                        selected: isOptional,
                        onTap: () => setDialogState(() {
                          isOptional = true;
                          alternativeGroupId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeAlternative,
                        icon: Icons.swap_horiz,
                        color: Colors.blue,
                        selected: alternativeGroupId != null,
                        onTap: () => setDialogState(() {
                          isOptional = false;
                          alternativeGroupId = existingGroups.isNotEmpty ? existingGroups.first : 'A';
                        }),
                      ),
                    ),
                  ],
                ),
                if (alternativeGroupId != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(l10n.typeGroup),
                      const SizedBox(width: 8),
                      ...['A', 'B', 'C'].map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: alternativeGroupId == g,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => alternativeGroupId = g);
                            }
                          },
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildAlternativeGroupPreview(alternativeGroupId!, -1),
                ],
              ],
            ),
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

                  final ingredientName = nameController.text.trim().toLowerCase();
                  
                  await ref.read(ingredientRepositoryProvider).createIngredient(
                    Ingredient(
                      id: '',
                      userId: user.uid,
                      name: ingredientName,
                      quantity: 0,
                      unit: selectedUnit,
                      addedAt: DateTime.now(),
                    ),
                  );

                  setState(() {
                    _ingredients.add(DishIngredient(
                      name: ingredientName,
                      quantity: double.tryParse(quantityController.text) ?? 1,
                      unit: selectedUnit,
                      isOptional: isOptional,
                      alternativeGroupId: alternativeGroupId,
                    ));
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(l10n.addDishCreateAndAdd),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(Ingredient ingredient) {
    final l10n = AppLocalizations.of(context)!;
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = ingredient.unit;
    bool isOptional = false;
    String? alternativeGroupId;

    final existingGroups = _ingredients
        .where((i) => i.alternativeGroupId != null)
        .map((i) => i.alternativeGroupId!)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            ingredient.name.substring(0, 1).toUpperCase() +
                ingredient.name.substring(1),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addDishPantryAvailable(ingredient.displayText),
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
                const Divider(),
                const SizedBox(height: 8),
                Text(l10n.typeLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeRequired,
                        icon: Icons.check_circle,
                        color: Colors.green,
                        selected: !isOptional && alternativeGroupId == null,
                        onTap: () => setDialogState(() {
                          isOptional = false;
                          alternativeGroupId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeOptional,
                        icon: Icons.add_circle_outline,
                        color: Colors.orange,
                        selected: isOptional,
                        onTap: () => setDialogState(() {
                          isOptional = true;
                          alternativeGroupId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: l10n.typeAlternative,
                        icon: Icons.swap_horiz,
                        color: Colors.blue,
                        selected: alternativeGroupId != null,
                        onTap: () => setDialogState(() {
                          isOptional = false;
                          alternativeGroupId = existingGroups.isNotEmpty ? existingGroups.first : 'A';
                        }),
                      ),
                    ),
                  ],
                ),
                if (alternativeGroupId != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(l10n.typeGroup),
                      const SizedBox(width: 8),
                      ...['A', 'B', 'C'].map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: alternativeGroupId == g,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => alternativeGroupId = g);
                            }
                          },
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildAlternativeGroupPreview(alternativeGroupId!, -1),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _ingredients.add(DishIngredient(
                    name: ingredient.name,
                    quantity: double.tryParse(quantityController.text) ?? 1,
                    unit: selectedUnit,
                    isOptional: isOptional,
                    alternativeGroupId: alternativeGroupId,
                  ));
                });
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _editDishIngredient(int index) {
    final l10n = AppLocalizations.of(context)!;
    final ingredient = _ingredients[index];
    final quantityController = TextEditingController(
      text: ingredient.quantity == ingredient.quantity.toInt() 
        ? ingredient.quantity.toInt().toString() 
        : ingredient.quantity.toString()
    );
    String selectedUnit = ingredient.unit;
    bool isOptional = ingredient.isOptional;
    String? alternativeGroupId = ingredient.alternativeGroupId;

    final existingGroups = _ingredients
        .where((i) => i.alternativeGroupId != null)
        .map((i) => i.alternativeGroupId!)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            ingredient.name.substring(0, 1).toUpperCase() +
                ingredient.name.substring(1),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Divider(),
                const SizedBox(height: 8),
                Text(l10n.typeIngredientLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: Text(l10n.typeRequired),
                  subtitle: Text(l10n.typeRequiredDesc),
                  value: 'required',
                  groupValue: alternativeGroupId != null ? 'alternative' : (isOptional ? 'optional' : 'required'),
                  onChanged: (value) {
                    setDialogState(() {
                      isOptional = false;
                      alternativeGroupId = null;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<String>(
                  title: Text(l10n.typeOptional),
                  subtitle: Text(l10n.typeOptionalDesc),
                  value: 'optional',
                  groupValue: alternativeGroupId != null ? 'alternative' : (isOptional ? 'optional' : 'required'),
                  onChanged: (value) {
                    setDialogState(() {
                      isOptional = true;
                      alternativeGroupId = null;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<String>(
                  title: Text(l10n.typeAlternative),
                  subtitle: Text(l10n.typeAlternativeDesc),
                  value: 'alternative',
                  groupValue: alternativeGroupId != null ? 'alternative' : (isOptional ? 'optional' : 'required'),
                  onChanged: (value) {
                    setDialogState(() {
                      isOptional = false;
                      alternativeGroupId = existingGroups.isNotEmpty ? existingGroups.first : 'A';
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                if (alternativeGroupId != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(l10n.typeGroup),
                      const SizedBox(width: 8),
                      ...['A', 'B', 'C'].map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: alternativeGroupId == g,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() => alternativeGroupId = g);
                            }
                          },
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildAlternativeGroupPreview(alternativeGroupId!, index),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _ingredients[index] = DishIngredient(
                    name: ingredient.name,
                    quantity: double.tryParse(quantityController.text) ?? 1,
                    unit: selectedUnit,
                    isOptional: isOptional,
                    alternativeGroupId: alternativeGroupId,
                  );
                });
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeGroupPreview(String groupId, int excludeIndex) {
    final l10n = AppLocalizations.of(context)!;
    final othersInGroup = _ingredients
        .asMap()
        .entries
        .where((e) => e.key != excludeIndex && e.value.alternativeGroupId == groupId)
        .map((e) => e.value.name)
        .toList();
    
    if (othersInGroup.isEmpty) {
      return Text(
        l10n.addDishFirstInGroup(groupId),
        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }
    
    return Text(
      l10n.addDishAlternatives(othersInGroup.join(", ")),
      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
    );
  }

  List<Widget> _buildIngredientsList() {
    final l10n = AppLocalizations.of(context)!;
    final widgets = <Widget>[];
    
    final required = _ingredients.asMap().entries.where((e) => e.value.isRequired).toList();
    final optional = _ingredients.asMap().entries.where((e) => e.value.isOptional).toList();
    final alternativeGroups = <String, List<MapEntry<int, DishIngredient>>>{};
    
    for (final entry in _ingredients.asMap().entries) {
      if (entry.value.alternativeGroupId != null) {
        alternativeGroups.putIfAbsent(entry.value.alternativeGroupId!, () => []).add(entry);
      }
    }

    for (final entry in required) {
      widgets.add(_buildIngredientTile(entry.key, entry.value, null));
    }

    for (final groupId in alternativeGroups.keys) {
      final groupEntries = alternativeGroups[groupId]!;
      widgets.add(Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.swap_horiz, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 4),
                Text(
                  l10n.dishAlternativesNeed1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
              ],
            ),
            ...groupEntries.map((e) => _buildIngredientTile(e.key, e.value, Colors.blue)),
          ],
        ),
      ));
    }

    if (optional.isNotEmpty) {
      widgets.add(Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  l10n.dishOptionals,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                ),
              ],
            ),
            ...optional.map((e) => _buildIngredientTile(e.key, e.value, Colors.orange)),
          ],
        ),
      ));
    }

    return widgets;
  }

  Widget _buildIngredientTile(int index, DishIngredient ingredient, Color? accentColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (accentColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
        child: Icon(
          Icons.restaurant_menu,
          color: accentColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(ingredient.name),
      subtitle: Text(ingredient.displayText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.blue,
            onPressed: () => _editDishIngredient(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () {
              setState(() {
                _ingredients.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addStep() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addDishStepNumber(_steps.length + 1)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.addDishStepDescription,
            hintText: l10n.addDishStepHint,
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _steps.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDish() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addDishAtLeastOne)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('No user logged in');

      final dish = Dish(
        id: _existingDish?.id ?? '',
        userId: user.uid,
        name: _nameController.text.trim(),
        imageUrl: _existingImageUrl,
        servings: int.tryParse(_servingsController.text) ?? 2,
        prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 0,
        difficulty: _selectedDifficulty,
        steps: _steps,
        ingredients: _ingredients,
        isFavorite: _existingDish?.isFavorite ?? false,
        createdAt: _existingDish?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(dishRepositoryProvider).updateDish(
          dish,
          newImageFile: _imageFile,
          newImageBytes: _imageBytes,
        );
      } else {
        await ref.read(dishRepositoryProvider).createDish(
          dish,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
        );
      }

      if (mounted) {
        context.go('/dishes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editDishTitle : l10n.addDishTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/dishes'),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveDish,
              child: Text(
                l10n.addDishSave,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading && _isEditing && _existingDish == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_imageBytes!),
                                fit: BoxFit.cover,
                              )
                            : _imageFile != null && !kIsWeb
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : _existingImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_existingImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                      ),
                      child: _imageBytes == null && _imageFile == null && _existingImageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.addDishAddPhoto,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.addDishName,
                      prefixIcon: const Icon(Icons.restaurant),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.addDishValidateName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          decoration: InputDecoration(
                            labelText: l10n.addDishDifficulty,
                            prefixIcon: const Icon(Icons.signal_cellular_alt),
                          ),
                          items: AppConstants.difficultyKeys
                              .map((d) => DropdownMenuItem(value: d, child: Text(AppConstants.localizedDifficulty(context, d))))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedDifficulty = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          decoration: InputDecoration(
                            labelText: l10n.addDishTime,
                            prefixIcon: const Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _servingsController,
                    decoration: InputDecoration(
                      labelText: l10n.addDishServings,
                      prefixIcon: const Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.addDishIngredients,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addDishAdd),
                      ),
                    ],
                  ),
                  if (_ingredients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.addDishNoIngredients,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ..._buildIngredientsList(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.addDishSteps,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addDishAdd),
                      ),
                    ],
                  ),
                  if (_steps.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.addDishNoSteps,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _steps.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final step = _steps.removeAt(oldIndex);
                          _steps.insert(newIndex, step);
                        });
                      },
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: ValueKey(index),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(_steps[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _steps.removeAt(index);
                                  });
                                },
                              ),
                              const Icon(Icons.drag_handle),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
