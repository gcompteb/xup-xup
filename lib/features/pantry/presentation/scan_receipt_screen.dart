import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/ingredient.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/ingredient_repository.dart';
import '../../../shared/services/gemini_service.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  File? _imageFile;
  List<ParsedIngredient>? _parsedIngredients;
  bool _isLoading = false;
  String? _error;
  List<Ingredient> _pantryIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadPantryIngredients();
  }

  Future<void> _loadPantryIngredients() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final ingredients = await ref.read(ingredientRepositoryProvider).getIngredients(user.uid);
    setState(() => _pantryIngredients = ingredients);
  }

  Ingredient? _findMatch(String parsedName) {
    final lower = parsedName.toLowerCase().trim();
    
    for (final ing in _pantryIngredients) {
      if (ing.nameLowerCase == lower) return ing;
    }
    
    for (final ing in _pantryIngredients) {
      if (ing.nameLowerCase.contains(lower) || lower.contains(ing.nameLowerCase)) {
        return ing;
      }
    }
    
    final parsedWords = lower.split(' ').where((w) => w.length > 2).toSet();
    for (final ing in _pantryIngredients) {
      final ingWords = ing.nameLowerCase.split(' ').where((w) => w.length > 2).toSet();
      if (parsedWords.intersection(ingWords).isNotEmpty) {
        return ing;
      }
    }
    
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _parsedIngredients = null;
        _error = null;
      });
      _analyzeReceipt();
    }
  }

  Future<void> _analyzeReceipt() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pantryData = _pantryIngredients
          .map((i) => {'name': i.name, 'unit': i.unit})
          .toList();
      
      final ingredients = await GeminiService.parseReceiptImage(
        _imageFile!,
        pantryData,
      );
      
      for (final parsed in ingredients) {
        final match = _findMatch(parsed.name);
        if (match != null) {
          parsed.linkedIngredientId = match.id;
          parsed.linkedIngredientName = match.name;
        }
      }
      
      setState(() {
        _parsedIngredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToPantry() async {
    if (_parsedIngredients == null) return;
    final l10n = AppLocalizations.of(context)!;

    final selected = _parsedIngredients!.where((i) => i.selected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanSelectAtLeastOne)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('No user');

      final repo = ref.read(ingredientRepositoryProvider);
      final existingIngredients = await repo.getIngredients(user.uid);

      for (final parsed in selected) {
        Ingredient? existing;
        
        if (parsed.isLinked) {
          existing = existingIngredients.firstWhere(
            (e) => e.id == parsed.linkedIngredientId,
            orElse: () => Ingredient(
              id: '',
              userId: user.uid,
              name: parsed.name,
              quantity: 0,
              unit: parsed.unit,
              addedAt: DateTime.now(),
            ),
          );
        } else {
          existing = existingIngredients.firstWhere(
            (e) => e.nameLowerCase == parsed.name.toLowerCase(),
            orElse: () => Ingredient(
              id: '',
              userId: user.uid,
              name: parsed.name,
              quantity: 0,
              unit: parsed.unit,
              addedAt: DateTime.now(),
            ),
          );
        }

        if (existing.id.isEmpty) {
          await repo.createIngredient(Ingredient(
            id: '',
            userId: user.uid,
            name: parsed.name,
            quantity: parsed.quantity,
            unit: parsed.unit,
            addedAt: DateTime.now(),
          ));
        } else {
          double quantityToAdd = parsed.quantity;
          if (UnitConverter.areCompatible(parsed.unit, existing.unit)) {
            quantityToAdd = UnitConverter.convert(parsed.quantity, parsed.unit, existing.unit);
          }
          await repo.addQuantity(existing, quantityToAdd);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.scanAddedSuccess(selected.length)),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanTitle),
      ),
      body: _buildBody(),
      floatingActionButton: _parsedIngredients != null && _parsedIngredients!.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _addToPantry,
              icon: const Icon(Icons.add),
              label: Text(l10n.scanAddToPantry),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_imageFile == null) {
      return _buildImagePicker();
    }

    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _imageFile!,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {
              _imageFile = null;
              _parsedIngredients = null;
            }),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.scanChangeImage),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.scanAnalyzing),
                ],
              ),
            )
          else if (_error != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _analyzeReceipt,
                      child: Text(l10n.scanRetry),
                    ),
                  ],
                ),
              ),
            )
          else if (_parsedIngredients != null)
            _buildIngredientsList(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.scanTakePhoto,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.addDishCamera),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.addDishGallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    final l10n = AppLocalizations.of(context)!;
    if (_parsedIngredients!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                l10n.scanNoIngredients,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final uncertainCount = _parsedIngredients!.where((i) => i.uncertain).length;
    final certainCount = _parsedIngredients!.length - uncertainCount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scanDetected(certainCount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (uncertainCount > 0)
                    Text(
                      l10n.scanUncertain(uncertainCount),
                      style: TextStyle(fontSize: 12, color: Colors.amber[700]),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                setState(() {
                  switch (value) {
                    case 'select_all':
                      for (final i in _parsedIngredients!) {
                        i.selected = true;
                      }
                      break;
                    case 'deselect_all':
                      for (final i in _parsedIngredients!) {
                        i.selected = false;
                      }
                      break;
                    case 'deselect_uncertain':
                      for (final i in _parsedIngredients!) {
                        if (i.uncertain) i.selected = false;
                      }
                      break;
                    case 'remove_uncertain':
                      _parsedIngredients!.removeWhere((i) => i.uncertain);
                      break;
                  }
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'select_all',
                  child: Row(
                    children: [
                      const Icon(Icons.check_box, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.scanSelectAll),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'deselect_all',
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.scanDeselectAll),
                    ],
                  ),
                ),
                if (uncertainCount > 0) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'deselect_uncertain',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, size: 20, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(l10n.scanDeselectUncertain),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove_uncertain',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.scanRemoveUncertain(uncertainCount)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _parsedIngredients!.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ing = _parsedIngredients![index];
              final isUncertain = ing.uncertain;
              
              return Container(
                color: isUncertain ? Colors.amber.withOpacity(0.1) : null,
                child: CheckboxListTile(
                  value: ing.selected,
                  onChanged: (value) {
                    setState(() => ing.selected = value ?? false);
                  },
                  title: Row(
                    children: [
                      if (isUncertain)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.help_outline, size: 18, color: Colors.amber),
                        ),
                      Expanded(
                        child: Text(
                          ing.name.substring(0, 1).toUpperCase() + ing.name.substring(1),
                          style: TextStyle(
                            color: isUncertain ? Colors.amber[800] : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUncertain && ing.originalText != null)
                        Text(
                          l10n.scanTicketLabel(ing.originalText!),
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      if (isUncertain && ing.question != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            ing.question!,
                            style: TextStyle(fontSize: 12, color: Colors.amber[800], fontWeight: FontWeight.w500),
                          ),
                        ),
                      Text('${_formatQuantity(ing.quantity)} ${ing.unit}'),
                      if (ing.isLinked)
                        InkWell(
                          onTap: () => _showLinkDialog(index),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                '→ ${ing.linkedIngredientName}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!isUncertain)
                        InkWell(
                          onTap: () => _showLinkDialog(index),
                          child: Row(
                            children: [
                              const Icon(Icons.add_link, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                l10n.scanNewIngredient,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  secondary: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUncertain)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _parsedIngredients!.removeAt(index);
                            });
                          },
                          tooltip: l10n.delete,
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editIngredient(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String _formatQuantity(double q) {
    return q == q.toInt() ? q.toInt().toString() : q.toStringAsFixed(1);
  }

  void _editIngredient(int index) {
    final l10n = AppLocalizations.of(context)!;
    final ing = _parsedIngredients![index];
    final nameController = TextEditingController(text: ing.name);
    final quantityController = TextEditingController(
      text: _formatQuantity(ing.quantity),
    );
    String selectedUnit = ing.unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.scanEditIngredient),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.name),
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
                      value: AppConstants.unitKeys.contains(selectedUnit)
                          ? selectedUnit
                          : 'unitats',
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
              onPressed: () {
                setState(() {
                  _parsedIngredients![index] = ParsedIngredient(
                    name: nameController.text.trim().toLowerCase(),
                    quantity: double.tryParse(quantityController.text) ?? ing.quantity,
                    unit: selectedUnit,
                    selected: ing.selected,
                    linkedIngredientId: ing.linkedIngredientId,
                    linkedIngredientName: ing.linkedIngredientName,
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

  void _showLinkDialog(int index) {
    final l10n = AppLocalizations.of(context)!;
    final ing = _parsedIngredients![index];
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = _pantryIngredients
              .where((i) => i.nameLowerCase.contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: Text(l10n.scanLinkIngredient),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scanDetectedLabel(ing.name),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.scanSearchPantry,
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
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: const Icon(Icons.add, color: Colors.orange),
                    ),
                    title: Text(l10n.scanCreateAsNew),
                    subtitle: Text(l10n.scanAddNameToPantry(ing.name)),
                    onTap: () {
                      setState(() {
                        _parsedIngredients![index].linkedIngredientId = null;
                        _parsedIngredients![index].linkedIngredientName = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              l10n.scanNoPantryIngredients,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final pantryIng = filtered[i];
                              final isSelected = pantryIng.id == ing.linkedIngredientId;
                              return ListTile(
                                leading: isSelected
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : const Icon(Icons.circle_outlined),
                                title: Text(
                                  pantryIng.name.substring(0, 1).toUpperCase() +
                                      pantryIng.name.substring(1),
                                ),
                                subtitle: Text(pantryIng.displayText),
                                onTap: () {
                                  setState(() {
                                    _parsedIngredients![index].linkedIngredientId = pantryIng.id;
                                    _parsedIngredients![index].linkedIngredientName = pantryIng.name;
                                  });
                                  Navigator.pop(context);
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
}
