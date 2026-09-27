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

  Widget _badgeWidget(ProductModel product) {
    final text = product.isOneOfAKind ? '1 OF 1' : 'ARTISAN MADE';
    return Container(
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: AppColors.border,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'GOLDEN',
                style: AppTextStyles.heading3.copyWith(color: AppColors.dark, letterSpacing: 2)),
            TextSpan(text: 'ART',
                style: AppTextStyles.heading3.copyWith(color: AppColors.primary, letterSpacing: 4)),
          ]),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                    child: Text('Home', style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary)),
                  ),
                  Text('  /  ', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Catalog', style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary)),
                  ),
                  Text('  /  ', style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                  Expanded(
                    child: Text(
                      product.title,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Deep Look Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: GestureDetector(
                onTap: () {
                  if (product.imageUri.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImage(url: product.imageUri)));
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.imageUri.isNotEmpty
                        ? Hero(
                            tag: product.imageUri,
                            child: CachedNetworkImage(
                              imageUrl: product.imageUri,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                                child: Icon(Icons.image_outlined, size: 80, color: Color(0xFF9CA3AF))),
                          ),
                    // "Deep Look" Overlay Badge
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('Deep Look', style: AppTextStyles.captionBold.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badgeWidget(product),
                  const SizedBox(height: 16),
                  Text(product.title, style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.formatMoney(product.price),
                    style: AppTextStyles.priceLarge,
                  ),
                  const SizedBox(height: 24),
                  // CTA Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoggedIn
                          ? () async {
                              final nav = Navigator.of(context);
                              final msg = ScaffoldMessenger.of(context);
                              await cart.addProduct(auth.userId, product, 1);
                              msg.showSnackBar(SnackBar(
                                content: Text('${product.title} ajouté au panier'),
                                backgroundColor: AppColors.success,
                                action: SnackBarAction(
                                  label: 'Voir',
                                  textColor: Colors.white,
                                  onPressed: () => nav.push(MaterialPageRoute(
                                      builder: (_) => const CartScreen())),
                                ),
                              ));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        elevation: 0,
                      ),
                      child: Text('Add to Collection', style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (auth.isLoggedIn) {
                          _showOfferDialog(context, product, auth);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Veuillez vous connecter pour faire une offre.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.dark, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: Text('Make an Offer',
                          style: AppTextStyles.button.copyWith(color: AppColors.dark)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Provenance
                  Text('Provenance & Details', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  Text(product.description, style: AppTextStyles.body.copyWith(height: 1.7)),
                  const SizedBox(height: 16),
                  // Key-value table
                  _detailRow('Catégorie', product.category),
                  _detailRow('Artisan', product.artisanId),
                  _detailRow('Disponibilité', product.isAvailable ? 'En stock' : 'Épuisé'),
                  if (product.isOneOfAKind) _detailRow('Édition', 'Pièce unique'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Artisan card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.dark,
                          child: Text(
                            product.artisanId.isNotEmpty
                                ? product.artisanId[0].toUpperCase()
                                : 'A',
                            style: AppTextStyles.heading3.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.artisanId, style: AppTextStyles.heading4),
                              const SizedBox(height: 2),
                              Text('Artisan Vérifié • Tunisie',
                                  style: AppTextStyles.caption
                                      .copyWith(letterSpacing: 0.5, color: AppColors.textMedium)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOfferDialog(BuildContext context, ProductModel product, AuthProvider auth) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Make an Offer', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Propose a price for ${product.title}. The artisan will be notified.', style: AppTextStyles.body),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (TND)',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text.replaceAll(',', '.'));
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
                    SnackBar(content: Text('Offer submitted successfully!'), backgroundColor: AppColors.success),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid number (e.g. 1500)')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Submit Offer', style: AppTextStyles.button.copyWith(color: Colors.white)),
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
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark)),
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
              placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.primary),
              errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
