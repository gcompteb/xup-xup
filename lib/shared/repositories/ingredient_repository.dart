import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient.dart';
import '../services/notification_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firestore_constants.dart';
import 'auth_repository.dart';

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(
    firestore: FirebaseFirestore.instance,
  );
});

final ingredientsStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(ingredientRepositoryProvider).watchIngredients(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class IngredientRepository {
  final FirebaseFirestore _firestore;

  IngredientRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _ingredientsRef =>
      _firestore.collection(FirestoreConstants.ingredientsCollection);

  Stream<List<Ingredient>> watchIngredients(String userId) {
    return _ingredientsRef
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ingredient.fromFirestore(doc)).toList());
  }

  Future<List<Ingredient>> getIngredients(String userId) async {
    final snapshot = await _ingredientsRef
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => Ingredient.fromFirestore(doc)).toList();
  }

  Future<Ingredient?> findIngredientByName(String userId, String name) async {
    final snapshot = await _ingredientsRef
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name.toLowerCase().trim())
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return Ingredient.fromFirestore(snapshot.docs.first);
  }

  Future<Ingredient> createIngredient(Ingredient ingredient) async {
    final existingIngredients = await getIngredients(ingredient.userId);
    final existing = existingIngredients.cast<Ingredient?>().firstWhere(
      (i) => i!.nameLowerCase == ingredient.name.toLowerCase().trim(),
      orElse: () => null,
    );
    
    if (existing != null) {
      double newQuantity = existing.quantity + ingredient.quantity;
      
      if (UnitConverter.areCompatible(ingredient.unit, existing.unit)) {
        newQuantity = existing.quantity + UnitConverter.convert(
          ingredient.quantity, ingredient.unit, existing.unit
        );
      }
      
      DateTime? newExpiryDate = ingredient.expiryDate ?? existing.expiryDate;
      if (existing.expiryDate != null && ingredient.expiryDate != null) {
        newExpiryDate = existing.expiryDate!.isBefore(ingredient.expiryDate!) 
            ? existing.expiryDate 
            : ingredient.expiryDate;
      }
      
      final updated = existing.copyWith(
        quantity: newQuantity,
        expiryDate: newExpiryDate,
        updatedAt: DateTime.now(),
      );
      await updateIngredient(updated);
      return updated;
    }
    
    final docRef = _ingredientsRef.doc();
    final newIngredient = ingredient.copyWith(id: docRef.id);
    await docRef.set(newIngredient.toFirestore());
    
    if (newIngredient.expiryDate != null) {
      await NotificationService().scheduleExpiryNotification(
        ingredientId: newIngredient.id,
        ingredientName: newIngredient.name,
        expiryDate: newIngredient.expiryDate!,
      );
    }
    
    return newIngredient;
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    var updated = ingredient.copyWith(updatedAt: DateTime.now());
    
    if (updated.quantity == 0) {
      updated = updated.copyWith(clearExpiryDate: true);
    }
    
    await _ingredientsRef.doc(updated.id).update(updated.toFirestore());
    
    if (updated.expiryDate != null) {
      await NotificationService().scheduleExpiryNotification(
        ingredientId: updated.id,
        ingredientName: updated.name,
        expiryDate: updated.expiryDate!,
      );
    } else {
      await NotificationService().cancelExpiryNotification(updated.id);
    }
  }

  Future<void> deleteIngredient(String ingredientId) async {
    await NotificationService().cancelExpiryNotification(ingredientId);
    await _ingredientsRef.doc(ingredientId).delete();
  }

  Future<void> addQuantity(Ingredient ingredient, double amount) async {
    await _ingredientsRef.doc(ingredient.id).update({
      'quantity': ingredient.quantity + amount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> subtractQuantity(Ingredient ingredient, double amount) async {
    var newQuantity = (ingredient.quantity - amount).clamp(0.0, double.infinity);
    if (newQuantity < 0.05) newQuantity = 0;
    
    final updateData = <String, dynamic>{
      'quantity': newQuantity,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    
    if (newQuantity == 0) {
      updateData['expiryDate'] = null;
      await NotificationService().cancelExpiryNotification(ingredient.id);
    }
    
    await _ingredientsRef.doc(ingredient.id).update(updateData);
  }

  Future<void> subtractIngredientsForDish(
    String userId,
    List<Map<String, dynamic>> dishIngredients,
  ) async {
    final ingredients = await getIngredients(userId);
    final batch = _firestore.batch();
    final now = Timestamp.fromDate(DateTime.now());

    for (final di in dishIngredients) {
      final name = (di['name'] as String).toLowerCase().trim();
      final quantity = (di['quantity'] as num).toDouble();
      final unit = di['unit'] as String? ?? 'unitats';
      
      final ingredient = ingredients.firstWhere(
        (i) => i.nameLowerCase == name,
        orElse: () => Ingredient(
          id: '',
          userId: userId,
          name: name,
          quantity: 0,
          unit: 'unitats',
          addedAt: DateTime.now(),
        ),
      );
      
      if (ingredient.id.isNotEmpty) {
        double quantityToSubtract = quantity;
        
        if (UnitConverter.areCompatible(unit, ingredient.unit)) {
          quantityToSubtract = UnitConverter.convert(quantity, unit, ingredient.unit);
        }
        
        var newQuantity = (ingredient.quantity - quantityToSubtract).clamp(0.0, double.infinity);
        if (newQuantity < 0.05) newQuantity = 0;
        
        final updateData = <String, dynamic>{
          'quantity': newQuantity,
          'updatedAt': now,
        };
        
        if (newQuantity == 0) {
          updateData['expiryDate'] = null;
          NotificationService().cancelExpiryNotification(ingredient.id);
        }
        
        batch.update(_ingredientsRef.doc(ingredient.id), updateData);
      }
    }

    await batch.commit();
  }
}
