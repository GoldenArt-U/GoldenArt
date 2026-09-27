import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/providers/cart_provider.dart';
import 'package:artisan_market/screens/cod_checkout_screen.dart';
import 'package:artisan_market/utils/constants.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mon Panier', style: AppTextStyles.heading2),
        actions: [
          if (cart.cartItems.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Vider le panier'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir vider votre panier ?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Confirmer')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await cart.clearCart(auth.userId);
                }
              },
              child: Text('Vider',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text('Votre panier est vide',
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 8),
                  Text('Ajoutez des produits pour continuer',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    child: Text('Continuer les achats',
                        style: AppTextStyles.button),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.cartItems.length,
                    itemBuilder: (_, i) {
                      final item = cart.cartItems[i];
                      final product = cart.productForItem(item);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: product?.thumbnail.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl: product!.thumbnail,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 72,
                                      height: 72,
                                      color: AppColors.divider,
                                      child: const Icon(Icons.image_outlined,
                                          color: AppColors.textLight),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product?.name ?? 'Produit',
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppConstants.formatMoney(
                                        product?.price ?? 0),
                                    style: AppTextStyles.price,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    _qtyBtn(
                                      icon: Icons.remove,
                                      onPressed: () => cart.updateQty(
                                          item.id, item.quantity - 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text('${item.quantity}',
                                          style: AppTextStyles.bodyMedium),
                                    ),
                                    _qtyBtn(
                                      icon: Icons.add,
                                      onPressed: () => cart.updateQty(
                                          item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () =>
                                      cart.removeItem(item.id),
                                  child: Text('Supprimer',
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Sous-total',
                          AppConstants.formatMoney(cart.subtotal)),
                      const SizedBox(height: 8),
                      _summaryRow('Livraison',
                          AppConstants.formatMoney(cart.delivery)),
                      const Divider(height: 24),
                      _summaryRow(
                        'Total',
                        AppConstants.formatMoney(cart.total),
                        bold: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CODCheckoutScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            elevation: 0,
                          ),
                          child: Text('Passer la commande (COD)',
                              style: AppTextStyles.button),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppTextStyles.bodyMedium
                : AppTextStyles.body
                    .copyWith(color: AppColors.textMedium)),
        Text(value,
            style: bold
                ? AppTextStyles.price.copyWith(fontSize: 18)
                : AppTextStyles.body),
      ],
    );
  }
}
