import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUri;       // image_uri (single string)
  final String category;
  final String artisanId;      // artisan_id
  final bool isOneOfAKind;     // is_one_of_a_kind
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DocumentReference? reference;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUri,
    required this.category,
    required this.artisanId,
    this.isOneOfAKind = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.reference,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUri: data['image_uri'] ?? '',
      category: data['category'] ?? '',
      artisanId: data['artisan_id'] ?? '',
      isOneOfAKind: data['is_one_of_a_kind'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      reference: doc.reference,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'price': price,
    'image_uri': imageUri,
    'category': category,
    'artisan_id': artisanId,
    'is_one_of_a_kind': isOneOfAKind,
    'rating': rating,
    'reviewCount': reviewCount,
    'isAvailable': isAvailable,
  };

  /// For backwards compatibility with any UI using .name
  String get name => title;
  String get thumbnail => imageUri;
}
