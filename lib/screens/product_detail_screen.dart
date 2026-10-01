import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/models/product_model.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/providers/cart_provider.dart';
import 'package:artisan_market/screens/cart_screen.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'GOLDEN',
                style: AppTextStyles.heading3
                    .copyWith(color: Colors.white, letterSpacing: 3)),
            TextSpan(
                text: 'ART',
                style: AppTextStyles.heading3
                    .copyWith(color: AppColors.primary, letterSpacing: 5)),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Full-Bleed Hero Image ──────────────────────────────────────
            GestureDetector(
              onTap: () {
                if (product.imageUri.isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImage(url: product.imageUri)));
                }
              },
              child: SizedBox(
                height: 420,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.imageUri.isNotEmpty
                        ? Hero(
                            tag: product.imageUri,
                            child: CachedNetworkImage(
                              imageUrl: product.imageUri,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            color: AppColors.surface,
                            child: const Center(
                                child: Icon(Icons.image_outlined,
                                    size: 80, color: Color(0xFF3F3F46))),
                          ),
                    // Bottom fade to background
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Deep Look badge
                    Positioned(
                      bottom: 24,
                      right: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.zoom_in,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text('Deep Look',
                                    style: AppTextStyles.captionBold
                                        .copyWith(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Details ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    color: AppColors.primary,
                    child: Text(
                      product.isOneOfAKind ? 'PIÈCE UNIQUE' : 'ARTISAN MADE',
                      style: AppTextStyles.badge,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(product.title, style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.formatMoney(product.price),
                    style: AppTextStyles.priceLarge,
                  ),
                  const SizedBox(height: 28),

                  // Qty selector
                  Row(
                    children: [
                      Text('Quantité',
                          style: AppTextStyles.bodyMedium),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      size: 16, color: Colors.white),
                                  onPressed: _qty > 1
                                      ? () => setState(() => _qty--)
                                      : null,
                                ),
                                Text('$_qty',
                                    style: AppTextStyles.bodyMedium),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 16, color: Colors.white),
                                  onPressed: () =>
                                      setState(() => _qty++),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add to Collection button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoggedIn
                          ? () async {
                              final nav = Navigator.of(context);
                              final msg =
                                  ScaffoldMessenger.of(context);
                              await cart.addProduct(
                                  auth.userId, product, _qty);
                              msg.showSnackBar(SnackBar(
                                content: Text(
                                    '${product.title} ajouté au panier'),
                                backgroundColor: AppColors.primary,
                                action: SnackBarAction(
                                  label: 'Voir',
                                  textColor: Colors.white,
                                  onPressed: () => nav.push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CartScreen())),
                                ),
                              ));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text('Add to Collection',
                          style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Make an Offer button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (auth.isLoggedIn) {
                          _showOfferDialog(context, product, auth);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Veuillez vous connecter pour faire une offre.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Make an Offer',
                          style: AppTextStyles.button
                              .copyWith(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // Provenance
                  Row(children: [
                    Container(
                        width: 3, height: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('Provenance & Details',
                        style: AppTextStyles.heading3),
                  ]),
                  const SizedBox(height: 14),
                  Text(product.description,
                      style:
                          AppTextStyles.body.copyWith(height: 1.8)),
                  const SizedBox(height: 16),
                  _detailRow('Catégorie', product.category),
                  _detailRow('Artisan', product.artisanId),
                  _detailRow('Disponibilité',
                      product.isAvailable ? 'En stock' : 'Épuisé'),
                  if (product.isOneOfAKind)
                    _detailRow('Édition', 'Pièce unique'),

                  const SizedBox(height: 28),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // Artisan glass card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                product.artisanId.isNotEmpty
                                    ? product.artisanId[0].toUpperCase()
                                    : 'A',
                                style: AppTextStyles.heading3
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(product.artisanId,
                                      style: AppTextStyles.heading4),
                                  const SizedBox(height: 2),
                                  Text('Artisan Vérifié • Tunisie',
                                      style: AppTextStyles.caption
                                          .copyWith(
                                              letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOfferDialog(
      BuildContext context, ProductModel product, AuthProvider auth) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Make an Offer', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Propose a price for ${product.title}. The artisan will be notified.',
                style: AppTextStyles.body),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Amount (TND)',
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount =
                  double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                Navigator.pop(ctx);
                await FirestoreService().submitOffer(
                  product.id,
                  product.title,
                  product.artisanId,
                  auth.userId,
                  amount,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Offer submitted successfully!'),
                        backgroundColor: AppColors.primary),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Please enter a valid number (e.g. 1500)')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: Text('Submit Offer',
                style: AppTextStyles.button
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Expanded(child: Text(value, style: AppTextStyles.body)),
          ],
        ),
      );
}

class FullScreenImage extends StatelessWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: Center(
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  CircularProgressIndicator(color: AppColors.primary),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
