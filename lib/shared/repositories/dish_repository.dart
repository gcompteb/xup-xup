import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/dish.dart';
import '../../core/constants/firestore_constants.dart';
import 'auth_repository.dart';

final dishRepositoryProvider = Provider<DishRepository>((ref) {
  return DishRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final dishesStreamProvider = StreamProvider<List<Dish>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(dishRepositoryProvider).watchDishes(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class DishRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  DishRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _dishesRef =>
      _firestore.collection(FirestoreConstants.dishesCollection);

  Stream<List<Dish>> watchDishes(String userId) {
    return _dishesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Dish.fromFirestore(doc)).toList());
  }

  Future<List<Dish>> getDishes(String userId) async {
    final snapshot = await _dishesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Dish.fromFirestore(doc)).toList();
  }

  Future<Dish?> getDish(String dishId) async {
    final doc = await _dishesRef.doc(dishId).get();
    if (!doc.exists) return null;
    return Dish.fromFirestore(doc);
  }

  Future<String?> uploadDishImage(String userId, File imageFile) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('dishes/$userId/$fileName');
    
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  Future<String?> uploadDishImageBytes(String userId, Uint8List imageBytes) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('dishes/$userId/$fileName');
    
    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<Dish> createDish(Dish dish, {File? imageFile, Uint8List? imageBytes}) async {
    String? imageUrl;
    if (kIsWeb && imageBytes != null) {
      imageUrl = await uploadDishImageBytes(dish.userId, imageBytes);
    } else if (imageFile != null) {
      imageUrl = await uploadDishImage(dish.userId, imageFile);
    }

    final now = DateTime.now();
    final docRef = _dishesRef.doc();
    final newDish = dish.copyWith(
      id: docRef.id,
      imageUrl: imageUrl ?? dish.imageUrl,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(newDish.toFirestore());
    return newDish;
  }

  Future<void> updateDish(Dish dish, {File? newImageFile, Uint8List? newImageBytes}) async {
    String? imageUrl = dish.imageUrl;
    
    if ((kIsWeb && newImageBytes != null) || newImageFile != null) {
      if (dish.imageUrl != null) {
        try {
          await _storage.refFromURL(dish.imageUrl!).delete();
        } catch (_) {}
      }
      if (kIsWeb && newImageBytes != null) {
        imageUrl = await uploadDishImageBytes(dish.userId, newImageBytes);
      } else if (newImageFile != null) {
        imageUrl = await uploadDishImage(dish.userId, newImageFile);
      }
    }

    final updatedDish = dish.copyWith(
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );
    await _dishesRef.doc(dish.id).update(updatedDish.toFirestore());
  }

  Future<void> deleteDish(Dish dish) async {
    if (dish.imageUrl != null) {
      try {
        await _storage.refFromURL(dish.imageUrl!).delete();
      } catch (_) {}
    }
    await _dishesRef.doc(dish.id).delete();
  }

  Future<void> toggleFavorite(Dish dish) async {
    await _dishesRef.doc(dish.id).update({
      'isFavorite': !dish.isFavorite,
    });
  }

  Future<void> markAsCooked(String dishId) async {
    final now = Timestamp.fromDate(DateTime.now());
    await _dishesRef.doc(dishId).update({
      'lastCookedAt': now,
      'updatedAt': now,
    });
  }
}
