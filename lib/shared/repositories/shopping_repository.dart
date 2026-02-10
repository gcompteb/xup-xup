import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shopping_item.dart';
import '../models/ingredient.dart';
import '../../core/constants/firestore_constants.dart';
import 'auth_repository.dart';
import 'ingredient_repository.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(
    firestore: FirebaseFirestore.instance,
    ingredientRepository: ref.read(ingredientRepositoryProvider),
  );
});

final shoppingItemsStreamProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(shoppingRepositoryProvider).watchShoppingItems(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class ShoppingRepository {
  final FirebaseFirestore _firestore;
  final IngredientRepository _ingredientRepository;

  ShoppingRepository({
    required FirebaseFirestore firestore,
    required IngredientRepository ingredientRepository,
  })  : _firestore = firestore,
        _ingredientRepository = ingredientRepository;

  CollectionReference<Map<String, dynamic>> get _shoppingRef =>
      _firestore.collection(FirestoreConstants.shoppingItemsCollection);

  Stream<List<ShoppingItem>> watchShoppingItems(String userId) {
    return _shoppingRef
        .where('userId', isEqualTo: userId)
        .orderBy('isChecked')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ShoppingItem.fromFirestore(doc)).toList());
  }

  Future<List<ShoppingItem>> getShoppingItems(String userId) async {
    final snapshot = await _shoppingRef
        .where('userId', isEqualTo: userId)
        .orderBy('isChecked')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ShoppingItem.fromFirestore(doc)).toList();
  }

  Future<ShoppingItem> createShoppingItem(ShoppingItem item) async {
    final docRef = _shoppingRef.doc();
    final newItem = item.copyWith(id: docRef.id);
    await docRef.set(newItem.toFirestore());
    return newItem;
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    await _shoppingRef.doc(item.id).update(item.toFirestore());
  }

  Future<void> toggleChecked(ShoppingItem item) async {
    await _shoppingRef.doc(item.id).update({
      'isChecked': !item.isChecked,
    });
  }

  Future<void> deleteShoppingItem(String itemId) async {
    await _shoppingRef.doc(itemId).delete();
  }

  Future<void> deleteAllChecked(String userId) async {
    final snapshot = await _shoppingRef
        .where('userId', isEqualTo: userId)
        .where('isChecked', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> transferCheckedToPantry(String userId) async {
    final snapshot = await _shoppingRef
        .where('userId', isEqualTo: userId)
        .where('isChecked', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      final item = ShoppingItem.fromFirestore(doc);
      
      final existingIngredient = await _ingredientRepository
          .findIngredientByName(userId, item.name);
      
      if (existingIngredient != null) {
        await _ingredientRepository.addQuantity(
          existingIngredient,
          item.quantity,
        );
      } else {
        await _ingredientRepository.createIngredient(
          Ingredient(
            id: '',
            userId: userId,
            name: item.name.toLowerCase().trim(),
            quantity: item.quantity,
            unit: item.unit,
            addedAt: DateTime.now(),
          ),
        );
      }
      
      await doc.reference.delete();
    }
  }
}
