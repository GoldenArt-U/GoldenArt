import 'package:flutter/foundation.dart';
import 'package:artisan_market/models/cart_item_model.dart';
import 'package:artisan_market/models/product_model.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/utils/custom_functions.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<CartItemModel> _cartItems = [];
  List<ProductModel> _products = [];

  List<CartItemModel> get cartItems => _cartItems;
  List<ProductModel> get products => _products;
  int get itemCount => _cartItems.fold(0, (acc, i) => acc + i.quantity);
  double get subtotal => cartSubtotal(_cartItems, _products);
  double get delivery => deliveryFee();
  double get total => subtotal + delivery;

  void listenToCart(String userId) {
    _service.getCartItems(userId).listen((items) async {
      _cartItems = items;
      await _loadProducts();
      notifyListeners();
    });
  }

  Future<void> _loadProducts() async {
    final ids = _cartItems.map((i) => i.productIdString).toList();
    _products = await _service.getProductsByIds(ids);
  }

  Future<void> addProduct(String userId, ProductModel product, [int qty = 1]) async {
    final dynamic pId = product.reference ?? product.id;
    final item = CartItemModel(
      id: '',
      productId: pId,
      quantity: qty,
      userId: userId,
    );
    await _service.addToCart(item);
    if (!_products.any((p) => (p.reference?.id ?? p.id) == product.id)) {
      _products.add(product);
    }
    notifyListeners();
  }

  // Backwards-compatible addItem
  Future<void> addItem(String userId, dynamic productRefOrModel) async {
    if (productRefOrModel is ProductModel) {
      await addProduct(userId, productRefOrModel);
    } else {
      final item = CartItemModel(
        id: '',
        productId: productRefOrModel,
        quantity: 1,
        userId: userId,
      );
      await _service.addToCart(item);
      await _loadProducts();
      notifyListeners();
    }
  }

  Future<void> updateQty(String itemId, int qty) async {
    await _service.updateCartItemQty(itemId, qty);
  }

  Future<void> removeItem(String itemId) async {
    await _service.removeCartItem(itemId);
  }

  Future<void> clearCart(String userId) async {
    await _service.clearCart(userId);
  }

  ProductModel? productForItem(CartItemModel item) {
    return _products.where((p) =>
        (p.reference?.id == item.productIdString) || (p.id == item.productIdString)
    ).firstOrNull;
  }
}
