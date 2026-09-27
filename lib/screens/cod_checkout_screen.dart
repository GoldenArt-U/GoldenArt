import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/models/order_model.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/providers/cart_provider.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/utils/constants.dart';
import 'package:artisan_market/utils/custom_functions.dart';

class CODCheckoutScreen extends StatefulWidget {
  const CODCheckoutScreen({super.key});
  @override
  State<CODCheckoutScreen> createState() => _CODCheckoutScreenState();
}

class _CODCheckoutScreenState extends State<CODCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final service = FirestoreService();

    final items = cart.cartItems.map((item) {
      final product = cart.productForItem(item);
      return {
        'productId': item.productIdString,
        'productTitle': product?.title ?? '',
        'price': product?.price ?? 0,
        'quantity': item.quantity,
      };
    }).toList();

    final order = OrderModel(
      id: '',
      userId: auth.userId,
      items: items,
      subtotal: cart.subtotal,
      deliveryFee: deliveryFee(),
      total: cart.total,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      createdAt: DateTime.now(),
      isCOD: true,
    );

    final orderId = await service.placeOrder(order);
    await cart.clearCart(auth.userId);
    setState(() => _placing = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Commande confirmée !',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Votre commande #${orderId.substring(0, 8).toUpperCase()} a été passée avec succès.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${AppConstants.formatMoney(cart.total)}',
                style: AppTextStyles.price,
              ),
              const SizedBox(height: 16),
              Text(
                'Paiement à la livraison (COD)',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMedium),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                ),
                child: Text('Retour à l\'accueil',
                    style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      );
    }
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide:
                const BorderSide(color: AppColors.error)),
      );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Paiement COD', style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COD badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text('Paiement à la livraison',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Informations de livraison',
                  style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDecor('Nom complet', Icons.person_outline),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),
              // Phone
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    _inputDecor('Téléphone', Icons.phone_outlined),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Téléphone requis' : null,
              ),
              const SizedBox(height: 12),
              // Address
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration:
                    _inputDecor('Adresse de livraison', Icons.location_on_outlined),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 28),
              // Order summary
              Text('Récapitulatif', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    // Items list
                    ...cart.cartItems.map((item) {
                      final product = cart.productForItem(item);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${product?.title ?? 'Produit'} x${item.quantity}',
                                style: AppTextStyles.body,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              AppConstants.formatMoney(
                                  (product?.price ?? 0) * item.quantity),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    _row('Sous-total',
                        AppConstants.formatMoney(cart.subtotal)),
                    const SizedBox(height: 6),
                    _row('Livraison', deliveryFeeLabel()),
                    const Divider(),
                    _row(
                      'Total à payer',
                      AppConstants.formatMoney(cart.total),
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _placing ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              elevation: 0,
            ),
            child: _placing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(
                    'Confirmer la commande — ${AppConstants.formatMoney(cart.total)}',
                    style: AppTextStyles.button,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
                    : AppTextStyles.bodyMedium),
          ],
        ),
      );
}
