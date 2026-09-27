import 'package:artisan_market/models/cart_item_model.dart';
import 'package:artisan_market/models/product_model.dart';
import 'package:artisan_market/utils/constants.dart';

String formatMoney(double amount, String currency) {
  if (currency.isEmpty) return amount.toStringAsFixed(2);
  return '$currency${amount.toStringAsFixed(2)}';
}

String availableBalanceLabel(double availableBalance) {
  return formatMoney(availableBalance, '');
}

double cartSubtotal(
  List<CartItemModel> cartItems,
  List<ProductModel> products,
) {
  return cartItems.fold(0.0, (acc, item) {
    final p = products.where((prod) {
      final pId = prod.reference?.id ?? prod.id;
      return pId == item.productIdString;
    }).firstOrNull;
    if (p == null) return acc;
    return acc + (p.price * item.quantity);
  });
}

double deliveryFee() => AppConstants.deliveryFeeValue;

String deliveryFeeLabel() => formatMoney(deliveryFee(), AppConstants.currency);

Map<String, dynamic> firstCartItem(
  List<CartItemModel> cartItems,
  List<ProductModel> products,
) {
  final item = cartItems.firstOrNull;
  if (item == null) return {};
  final p = products.where((prod) {
    final pId = prod.reference?.id ?? prod.id;
    return pId == item.productIdString;
  }).firstOrNull;
  if (p == null) return {};
  return {
    'id': item.id,
    'title': p.title,
    'price_label': formatMoney(p.price, '${AppConstants.currency} '),
    'description': p.description,
  };
}

String pendingBalanceLabel(double pendingBalance) {
  return formatMoney(pendingBalance, '');
}

String priceLabel(List<ProductModel> products, String productId) {
  final p = products.where((prod) => (prod.reference?.id ?? prod.id) == productId).firstOrNull;
  return formatMoney(p?.price ?? 0, '${AppConstants.currency} ');
}

Map<String, dynamic> selectedProduct(
  List<ProductModel> products,
  String productId,
) {
  final p = products
      .where((prod) => (prod.reference?.id ?? prod.id) == productId)
      .firstOrNull;
  if (p == null) return {};
  return {
    'id': p.id,
    'title': p.title,
    'description': p.description,
    'price': p.price,
    'image_uri': p.imageUri,
    'artisan_id': p.artisanId,
    'is_one_of_a_kind': p.isOneOfAKind,
  };
}
