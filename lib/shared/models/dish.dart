import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import 'dish_ingredient.dart';

class Dish {
  final String id;
  final String userId;
  final String name;
  final String? imageUrl;
  final int servings;
  final int prepTimeMinutes;
  final String difficulty;
  final bool isHealthy;
  final List<String> steps;
  final List<DishIngredient> ingredients;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastCookedAt;

  Dish({
    required this.id,
    required this.userId,
    required this.name,
    this.imageUrl,
    this.servings = 2,
    required this.prepTimeMinutes,
    required this.difficulty,
    this.isHealthy = false,
    required this.steps,
    required this.ingredients,
    this.isFavorite = false,
    required this.createdAt,
    DateTime? updatedAt,
    this.lastCookedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  factory Dish.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Dish(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      servings: data['servings'] ?? 2,
      prepTimeMinutes: data['prepTimeMinutes'] ?? 0,
      difficulty: AppConstants.normalizeDifficultyKey(data['difficulty'] ?? 'medium'),
      isHealthy: data['isHealthy'] ?? false,
      steps: List<String>.from(data['steps'] ?? []),
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map((e) => DishIngredient.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFavorite: data['isFavorite'] ?? false,
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt,
      lastCookedAt: (data['lastCookedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'servings': servings,
      'prepTimeMinutes': prepTimeMinutes,
      'difficulty': difficulty,
      'isHealthy': isHealthy,
      'steps': steps,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastCookedAt': lastCookedAt != null ? Timestamp.fromDate(lastCookedAt!) : null,
    };
  }

  Dish copyWith({
    String? id,
    String? userId,
    String? name,
    String? imageUrl,
    int? servings,
    int? prepTimeMinutes,
    String? difficulty,
    bool? isHealthy,
    List<String>? steps,
    List<DishIngredient>? ingredients,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastCookedAt,
  }) {
    return Dish(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      isHealthy: isHealthy ?? this.isHealthy,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCookedAt: lastCookedAt ?? this.lastCookedAt,
    );
  }

  String get prepTimeDisplay {
    if (prepTimeMinutes < 60) {
      return '$prepTimeMinutes min';
    }
    final hours = prepTimeMinutes ~/ 60;
    final minutes = prepTimeMinutes % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }
}
