import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String userId;
  final String name;
  final double quantity;
  final String unit;
  final bool isChecked;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
    required this.createdAt,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      quantity: (data['quantity'] ?? 1).toDouble(),
      unit: data['unit'] ?? 'unitats',
      isChecked: data['isChecked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayText {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '$quantity $unit';
  }
}
