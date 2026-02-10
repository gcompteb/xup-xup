class DishIngredient {
  final String name;
  final double quantity;
  final String unit;
  final bool isOptional;
  final String? alternativeGroupId;

  DishIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.isOptional = false,
    this.alternativeGroupId,
  });

  factory DishIngredient.fromMap(Map<String, dynamic> map) {
    return DishIngredient(
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'unitats',
      isOptional: map['isOptional'] ?? false,
      alternativeGroupId: map['alternativeGroupId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isOptional': isOptional,
      'alternativeGroupId': alternativeGroupId,
    };
  }

  DishIngredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    bool? isOptional,
    String? alternativeGroupId,
    bool clearAlternativeGroup = false,
  }) {
    return DishIngredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isOptional: isOptional ?? this.isOptional,
      alternativeGroupId: clearAlternativeGroup ? null : (alternativeGroupId ?? this.alternativeGroupId),
    );
  }

  bool get isRequired => !isOptional && alternativeGroupId == null;
  bool get isAlternative => alternativeGroupId != null;

  String get displayText {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit de $name';
    }
    return '$quantity $unit de $name';
  }
}
