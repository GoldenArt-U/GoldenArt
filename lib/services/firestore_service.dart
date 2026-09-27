import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artisan_market/models/product_model.dart';
import 'package:artisan_market/models/cart_item_model.dart';
import 'package:artisan_market/models/order_model.dart';

class FirestoreService {
  static bool get isFirebaseReady => Firebase.apps.isNotEmpty;
  static FirebaseFirestore? get _db => isFirebaseReady ? FirebaseFirestore.instance : null;

  // ── In-Memory Mock Database for immediate testing ─────────────────────────
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: 'prod_1',
      title: 'Poterie Rustique de Sejnane',
      description: 'Pièce authentique façonnée à la main par les femmes potières de Sejnane, classée au patrimoine culturel immatériel de l\'UNESCO. Argile naturelle cuite au feu de bois et polie avec des coquillages.',
      price: 35.0,
      imageUri: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=600',
      category: 'Poterie',
      artisanId: 'Atelier Sejnane Héritage',
      isOneOfAKind: true,
      rating: 4.9,
      reviewCount: 24,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_2',
      title: 'Tapis Berbère Margoum Pur Laine',
      description: 'Tapis traditionnel tissé à la main sur métier à tisser en bois. Motifs géométriques berbères ancestraux en teintes rouge carmin et safran. Dimensions: 120 x 80 cm.',
      price: 120.0,
      imageUri: 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?w=600',
      category: 'Tissage',
      artisanId: 'Coopérative Oudhref',
      isOneOfAKind: true,
      rating: 5.0,
      reviewCount: 18,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_3',
      title: 'Plat Émaillé en Céramique de Nabeul',
      description: 'Plat de présentation aux arabesques turquoise et cobalt peintes délicatement à la main. Idéal pour servir vos plats traditionnels ou en décoration murale.',
      price: 28.0,
      imageUri: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600',
      category: 'Poterie',
      artisanId: 'Poterie Chemla Nabeul',
      isOneOfAKind: false,
      rating: 4.8,
      reviewCount: 32,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_4',
      title: 'Sacoche Bandoulière en Cuir Naturel',
      description: 'Cuir véritable tanné naturellement selon le savoir-faire des artisans maroquiniers de la Médina de Tunis. Coutures sellier renforcées, fermoir en laiton vieilli.',
      price: 65.0,
      imageUri: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
      category: 'Cuir',
      artisanId: 'Maroquinerie El Bey',
      isOneOfAKind: false,
      rating: 4.7,
      reviewCount: 15,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_5',
      title: 'Saladier Sculpté en Bois d\'Olivier',
      description: 'Sculpté dans une seule pièce de bois d\'olivier centenaire de la région de Sfax. Chaque veinure est unique et le bois est nourri avec de l\'huile d\'olive vierge.',
      price: 42.0,
      imageUri: 'https://images.unsplash.com/photo-1590736704728-f4730bb30770?w=600',
      category: 'Bois',
      artisanId: 'Olivier de Thyna',
      isOneOfAKind: true,
      rating: 4.9,
      reviewCount: 41,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_6',
      title: 'Lanterne Orientale Cuivre Martelé',
      description: 'Lanterne ajourée traditionnelle en cuivre ciselé à la pointe par les maîtres dinandiers de Kairouan. Projette des reflets féeriques dans vos pièces.',
      price: 55.0,
      imageUri: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
      category: 'Cuir',
      artisanId: 'Dinanderie de Kairouan',
      isOneOfAKind: false,
      rating: 4.6,
      reviewCount: 9,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_7',
      title: 'Bracelet & Collier Berbère en Argent',
      description: 'Bijou ethnique traditionnel en argent massif 925 gravé avec des perles d\'ambre et d\'émail vert et jaune. Création originale d\'artisans bijoutiers de Djerba.',
      price: 85.0,
      imageUri: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600',
      category: 'Bijoux',
      artisanId: 'Bijouterie Houmt Souk',
      isOneOfAKind: true,
      rating: 5.0,
      reviewCount: 27,
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_8',
      title: 'Chéchia Tunisienne Pur Feutre Rouge',
      description: 'L\'authentique chéchia tunisienne confectionnée à la main dans le Souk des Chéchias selon les 12 étapes traditionnelles ancestrales. Laine peignée de premier choix.',
      price: 22.0,
      imageUri: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600',
      category: 'Tissage',
      artisanId: 'Chaouachia Médina',
      isOneOfAKind: false,
      rating: 4.9,
      reviewCount: 53,
      isAvailable: true,
    ),
  ];

  static final List<CartItemModel> _mockCart = [];
  static final StreamController<List<CartItemModel>> _mockCartController =
      StreamController<List<CartItemModel>>.broadcast();

  static final List<OrderModel> _mockOrders = [];
  static final StreamController<List<OrderModel>> _mockOrdersController =
      StreamController<List<OrderModel>>.broadcast();

  // ── Products ─────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> getProducts({String? category}) {
    if (isFirebaseReady) {
      Query<Map<String, dynamic>> q = _db!.collection('products')
          .where('isAvailable', isEqualTo: true);
      if (category != null && category != 'All') {
        q = q.where('category', isEqualTo: category);
      }
      return q.snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          // Fallback to mock data so the user has something to see when DB is empty
          var list = _mockProducts;
          if (category != null && category != 'All') {
            list = list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
          }
          return list;
        }
        return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
      });
    }

    // Mock stream
    var list = _mockProducts;
    if (category != null && category != 'All') {
      list = list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return Stream.value(list);
  }

  Stream<ProductModel> getProduct(String id) {
    if (isFirebaseReady) {
      return _db!.collection('products').doc(id).snapshots()
          .map((d) => ProductModel.fromFirestore(d));
    }
    final p = _mockProducts.firstWhere(
      (item) => item.id == id,
      orElse: () => _mockProducts.first,
    );
    return Stream.value(p);
  }

  /// Task 3 — Write a new product listing to Firestore.
  /// Requires a signed-in user; throws [StateError] otherwise.
  /// Includes [createdAt] serverTimestamp and [userId] automatically.
  Future<String> addProduct({
    required String userId,
    required String title,
    required String description,
    required double price,
    required String category,
    String imageUri = '',
    bool isOneOfAKind = true,
  }) async {
    if (userId.isEmpty) {
      throw StateError('User must be signed in to list a product.');
    }
    final data = {
      'title': title.trim(),
      'description': description.trim(),
      'price': price,
      'category': category.trim(),
      'image_uri': imageUri.trim(),
      'isOneOfAKind': isOneOfAKind,
      'isAvailable': true,
      'rating': 0.0,
      'reviewCount': 0,
      'artisanId': userId,
      'userId': userId,
      'createdAt': isFirebaseReady
          ? FieldValue.serverTimestamp()
          : Timestamp.now(),
    };

    if (isFirebaseReady) {
      final ref = await _db!.collection('products').add(data);
      return ref.id;
    }

    // Mock: add to local list and return generated id
    final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    _mockProducts.add(ProductModel(
      id: newId,
      title: title.trim(),
      description: description.trim(),
      price: price,
      imageUri: imageUri.trim(),
      category: category.trim(),
      artisanId: userId,
      isOneOfAKind: isOneOfAKind,
      rating: 0.0,
      reviewCount: 0,
      isAvailable: true,
    ));
    return newId;
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    if (isFirebaseReady) {
      final snap = await _db!.collection('products')
          .where(FieldPath.documentId, whereIn: ids).get();
      return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
    }
    return _mockProducts.where((p) => ids.contains(p.id)).toList();
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  Stream<List<CartItemModel>> getCartItems(String userId) {
    if (isFirebaseReady) {
      return _db!.collection('cartItems')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => CartItemModel.fromFirestore(d)).toList());
    }
    // Return mock cart
    return _mockCartController.stream.startWith(_mockCart.where((i) => i.userId == userId).toList());
  }

  Future<void> addToCart(CartItemModel item) async {
    if (isFirebaseReady) {
      final existing = await _db!.collection('cartItems')
          .where('userId', isEqualTo: item.userId)
          .where('product_id', isEqualTo: item.productId)
          .get();
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentQty = (doc.data()['quantity'] ?? 1) as int;
        await doc.reference.update({'quantity': currentQty + item.quantity});
      } else {
        await _db!.collection('cartItems').add(item.toMap());
      }
      return;
    }

    // Mock add
    final idx = _mockCart.indexWhere((i) =>
        i.userId == item.userId && i.productIdString == item.productIdString);
    if (idx >= 0) {
      final current = _mockCart[idx];
      _mockCart[idx] = current.copyWith(quantity: current.quantity + item.quantity);
    } else {
      final newItem = CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        productId: item.productId,
        quantity: item.quantity,
        userId: item.userId,
      );
      _mockCart.add(newItem);
    }
    _mockCartController.add(List.from(_mockCart));
  }

  Future<void> updateCartItemQty(String itemId, int quantity) async {
    if (isFirebaseReady) {
      if (quantity <= 0) {
        await _db!.collection('cartItems').doc(itemId).delete();
      } else {
        await _db!.collection('cartItems')
            .doc(itemId)
            .update({'quantity': quantity});
      }
      return;
    }

    if (quantity <= 0) {
      _mockCart.removeWhere((i) => i.id == itemId);
    } else {
      final idx = _mockCart.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        _mockCart[idx] = _mockCart[idx].copyWith(quantity: quantity);
      }
    }
    _mockCartController.add(List.from(_mockCart));
  }

  Future<void> removeCartItem(String itemId) async {
    if (isFirebaseReady) {
      await _db!.collection('cartItems').doc(itemId).delete();
      return;
    }
    _mockCart.removeWhere((i) => i.id == itemId);
    _mockCartController.add(List.from(_mockCart));
  }

  Future<void> clearCart(String userId) async {
    if (isFirebaseReady) {
      final batch = _db!.batch();
      final snap = await _db!.collection('cartItems')
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return;
    }
    _mockCart.removeWhere((i) => i.userId == userId);
    _mockCartController.add(List.from(_mockCart));
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<String> placeOrder(OrderModel order) async {
    if (isFirebaseReady) {
      final ref = await _db!.collection('orders').add(order.toMap());
      return ref.id;
    }
    final generatedId = 'CMD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final savedOrder = OrderModel(
      id: generatedId,
      userId: order.userId,
      items: order.items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      address: order.address,
      status: order.status,
      createdAt: order.createdAt,
      isCOD: order.isCOD,
    );
    _mockOrders.insert(0, savedOrder);
    _mockOrdersController.add(List.from(_mockOrders));
    return generatedId;
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    if (isFirebaseReady) {
      return _db!.collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
    }
    return _mockOrdersController.stream.startWith(_mockOrders.where((o) => o.userId == userId).toList());
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<String>> getCategories() async {
    if (isFirebaseReady) {
      final snap = await _db!.collection('categories').get();
      return snap.docs
          .map((d) => d.data()['name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return ['All', 'Poterie', 'Tissage', 'Bijoux', 'Cuir', 'Bois'];
  }

  // ── Offers ────────────────────────────────────────────────────────────────

  Future<void> submitOffer(String productId, String productTitle, String artisanId, String buyerId, double amount) async {
    if (isFirebaseReady) {
      await _db!.collection('offers').add({
        'productId': productId,
        'productTitle': productTitle,
        'buyerId': buyerId,
        'artisanId': artisanId,
        'amount': amount,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });
      return;
    }
    // No-op for mock mode, or we can just print.
    print('Mock Mode: Submitted offer of \$amount for \$productTitle');
  }

  Stream<List<Map<String, dynamic>>> getOffersForArtisan(String artisanId) {
    if (isFirebaseReady) {
      return _db!.collection('offers')
          .where('artisanId', isEqualTo: artisanId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) {
                final data = d.data();
                data['id'] = d.id;
                return data;
              }).toList());
    }
    return Stream.value([]);
  }

  Future<void> updateOfferStatus(String offerId, String status) async {
    if (isFirebaseReady) {
      await _db!.collection('offers').doc(offerId).update({'status': status});
    }
  }
}

extension _StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}
