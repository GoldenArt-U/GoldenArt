import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String customerName;
  final String customerPhone;
  final String address;
  final OrderStatus status;
  final DateTime createdAt;
  final bool isCOD;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.isCOD = true,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 7.5).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      address: data['address'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCOD: data['isCOD'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'items': items,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'address': address,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'isCOD': isCOD,
  };

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending: return 'En attente';
      case OrderStatus.confirmed: return 'Confirmé';
      case OrderStatus.shipped: return 'Expédié';
      case OrderStatus.delivered: return 'Livré';
      case OrderStatus.cancelled: return 'Annulé';
    }
  }
}
