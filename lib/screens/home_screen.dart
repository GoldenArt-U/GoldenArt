import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/models/product_model.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/providers/cart_provider.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/screens/cart_screen.dart';
import 'package:artisan_market/screens/orders_screen.dart';
import 'package:artisan_market/screens/product_detail_screen.dart';
import 'package:artisan_market/screens/dashboard_screen.dart';
import 'package:artisan_market/widgets/product_card.dart';
import 'package:artisan_market/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All', 'Poterie', 'Tissage', 'Bijoux', 'Cuir', 'Broderie', 'Bois',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<CartProvider>().listenToCart(auth.userId);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'GOLDEN',
          style: AppTextStyles.heading3.copyWith(
              color: Colors.white, letterSpacing: 3),
        ),
        TextSpan(
          text: 'ART',
          style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary, letterSpacing: 5),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black.withOpacity(0.85),
            elevation: 0,
            title: _buildLogo(),
            centerTitle: false,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.transparent),
              ),
            ),
            actions: [
              // Cart with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen())),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── Editorial Hero ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 520,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1584285406059-0268571fa0df?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.dark),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.dark),
                  ),
                  // Heavy dark gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC000000),
                          Color(0x66000000),
                          Color(0xFF0A0A0A),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sub-label
                        Text(
                          'TUNISIAN 1-OF-1 COLLECTION',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Massive editorial headline
                        Text('RARE', style: AppTextStyles.displayLarge),
                        Text('ARTIFACTS', style: AppTextStyles.displayLarge),
                        const SizedBox(height: 20),
                        // Arrow CTA
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search Bar (transition between hero and grid) ───────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: AppColors.textLight, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v.toLowerCase()),
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search ceramics, rare art...',
                              hintStyle: AppTextStyles.caption,
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Explore',
                                style: AppTextStyles.button
                                    .copyWith(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Category Pills ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: AppTextStyles.caption.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textMedium,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Section Title ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Row(
                children: [
                  Container(
                      width: 3,
                      height: 22,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text('NEW ACQUISITIONS',
                      style: AppTextStyles.heading2
                          .copyWith(letterSpacing: 2, fontSize: 18)),
                ],
              ),
            ),
          ),

          // ── Products Grid ───────────────────────────────────────────────
          StreamBuilder<List<ProductModel>>(
            stream: _service.getProducts(
                category: _selectedCategory == 'All'
                    ? null
                    : _selectedCategory),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  ),
                );
              }
              var products = snap.data ?? [];
              if (_searchQuery.isNotEmpty) {
                products = products
                    .where((p) =>
                        p.title
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        p.artisanId
                            .toLowerCase()
                            .contains(_searchQuery))
                    .toList();
              }
              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          Text('Aucun résultat',
                              style: AppTextStyles.heading3),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.56,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(
                      product: products[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: products[i]),
                        ),
                      ),
                      onAddToCart: auth.isLoggedIn
                          ? () async {
                              await cart.addProduct(
                                  auth.userId, products[i]);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${products[i].title} ajouté au panier'),
                                    backgroundColor: AppColors.primary,
                                    duration:
                                        const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
