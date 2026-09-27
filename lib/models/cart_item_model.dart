import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final dynamic productId; // DocumentReference in Firestore, or String id in mock
  final int quantity;
  final String userId;
  final DocumentReference? reference;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.userId,
    this.reference,
  });

  String get productIdString {
    if (productId is DocumentReference) {
      return (productId as DocumentReference).id;
    }
    return productId.toString();
  }

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      productId: data['product_id'] ?? data['productId'],
      quantity: data['quantity'] ?? 1,
      userId: data['userId'] ?? '',
      reference: doc.reference,
    );
  }

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'quantity': quantity,
    'userId': userId,
  };

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    id: id,
    productId: productId,
    quantity: quantity ?? this.quantity,
    userId: userId,
    reference: reference,
  );
}
