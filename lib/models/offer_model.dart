import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String productId;
  final String productTitle;
  final String buyerId;
  final String artisanId;
  final double amount;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.artisanId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OfferModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      buyerId: data['buyerId'] ?? '',
      artisanId: data['artisanId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'buyerId': buyerId,
      'artisanId': artisanId,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
