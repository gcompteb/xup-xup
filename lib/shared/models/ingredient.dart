import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String id;
  final String userId;
  final String name;
  final double quantity;
  final String unit;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? expiryDate;

  Ingredient({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.addedAt,
    DateTime? updatedAt,
    this.expiryDate,
  }) : updatedAt = updatedAt ?? addedAt;

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final addedAt = (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Ingredient(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'unitats',
      addedAt: addedAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? addedAt,
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'nameLowerCase': name.toLowerCase().trim(),
      'quantity': quantity,
      'unit': unit,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  Ingredient copyWith({
    String? id,
    String? userId,
    String? name,
    double? quantity,
    String? unit,
    DateTime? addedAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
  }) {
    return Ingredient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
    );
  }

  String get displayText {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '$quantity $unit';
  }

  String get nameLowerCase => name.toLowerCase().trim();

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }
}
