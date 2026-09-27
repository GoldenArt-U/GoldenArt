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
import 'package:artisan_market/screens/buyer_profile_screen.dart';
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
  String _sortBy = 'new';
  double? _minPrice;
  double? _maxPrice;
  String _typeFilter = 'all';

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'image': ''},
    {'name': 'Poterie', 'image': 'https://images.unsplash.com/photo-1590209664654-20b13cf76a26?q=80&w=200&auto=format&fit=crop'},
    {'name': 'Tissage', 'image': 'https://images.unsplash.com/photo-1600164318680-a616782db276?q=80&w=200&auto=format&fit=crop'},
    {'name': 'Bijoux', 'image': 'https://images.unsplash.com/photo-1616866160879-1144a95610ec?q=80&w=200&auto=format&fit=crop'},
    {'name': 'Cuir', 'image': 'https://images.unsplash.com/photo-1549488344-c4a037bdff70?q=80&w=200&auto=format&fit=crop'},
    {'name': 'Broderie', 'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=200&auto=format&fit=crop'},
    {'name': 'Bois', 'image': 'https://images.unsplash.com/photo-1590736704728-f4730bb30770?q=80&w=200&auto=format&fit=crop'},
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
      text: TextSpan(
        children: [
          TextSpan(
            text: 'GOLDEN',
            style: AppTextStyles.heading3.copyWith(color: AppColors.dark, letterSpacing: 2),
          ),
          TextSpan(
            text: 'ART',
            style: AppTextStyles.heading3.copyWith(color: AppColors.primary, letterSpacing: 4),
          ),
        ],
      ),
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
          // â”€â”€ App Bar â”€â”€
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0.5,
            shadowColor: AppColors.border,
            title: _buildLogo(),
            centerTitle: false,
            actions: [
              // Cart
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706), shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Color(0xFF0F172A)),
                onPressed: () {
                  if (auth.isSeller) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerProfileScreen()));
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // â”€â”€ Hero Section â”€â”€
          SliverToBoxAdapter(
            child: SizedBox(
              height: 480,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1584285406059-0268571fa0df?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.dark),
                    errorWidget: (_, __, ___) => Container(color: AppColors.dark),
                  ),
                  Container(color: const Color(0xCC0F172A)), // dark overlay
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'THE PREMIUM MARKETPLACE',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary, letterSpacing: 3),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Discover the\nExtraordinary',
                          style: AppTextStyles.displayLarge
                              .copyWith(color: Colors.white, height: 1.1),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tunisia's exclusive destination for authenticated\nrare artifacts and 1-of-1 creations.",
                          style: AppTextStyles.body.copyWith(color: const Color(0xFFD1D5DB)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Frosted glass search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.search, color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v.toLowerCase()),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Search for ceramics, rare art...',
                                    hintStyle: TextStyle(color: Colors.white60),
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
                                      style: AppTextStyles.button),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Curated Collections â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Curated Collections', style: AppTextStyles.heading2),
                      TextButton(
                        onPressed: () => setState(() => _selectedCategory = 'All'),
                        child: Text('View Catalog â†’',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected = cat['name'] == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat['name']!),
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF3F4F6),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: selected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: cat['image']!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: cat['image']!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.grid_view_rounded,
                                          color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name']!,
                                  style: AppTextStyles.navLabel.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textDark,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Catalog Header ──
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 28),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('The Catalog', style: AppTextStyles.heading1),
                        const SizedBox(height: 4),
                        Text('Unique authenticated pieces from Tunisia',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('Sort by:', style: AppTextStyles.caption),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        style: AppTextStyles.bodyMedium,
                        items: const [
                          DropdownMenuItem(value: 'new', child: Text('Newly Added')),
                          DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                          DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                        ],
                        onChanged: (v) => setState(() => _sortBy = v ?? 'new'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Listing Layout: Sidebar + Grid ──
          StreamBuilder<List<ProductModel>>(
            stream: _service.getProducts(
                category: _selectedCategory == 'All' ? null : _selectedCategory),
            builder: (context, snap) {
              var products = snap.data ?? [];
              if (_searchQuery.isNotEmpty) {
                products = products
                    .where((p) =>
                        p.title.toLowerCase().contains(_searchQuery) ||
                        p.artisanId.toLowerCase().contains(_searchQuery))
                    .toList();
              }
              // Price filter
              if (_maxPrice != null) {
                products = products.where((p) => p.price <= _maxPrice!).toList();
              }
              if (_minPrice != null) {
                products = products.where((p) => p.price >= _minPrice!).toList();
              }
              // Sort
              if (_sortBy == 'price_high') {
                products = [...products]..sort((a, b) => b.price.compareTo(a.price));
              } else if (_sortBy == 'price_low') {
                products = [...products]..sort((a, b) => a.price.compareTo(b.price));
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 700;
                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sidebar
                                SizedBox(width: 220, child: _buildSidebar()),
                                const SizedBox(width: 24),
                                // Grid
                                Expanded(child: _buildGrid(products, auth, cart)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildSidebar(),
                                const SizedBox(height: 16),
                                _buildGrid(products, auth, cart),
                              ],
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          Text('Category', style: AppTextStyles.heading4
              .copyWith(letterSpacing: 0.5)),
          const Divider(height: 16),
          ..._categories.map((cat) {
            final selected = cat['name'] == _selectedCategory;
            return InkWell(
              onTap: () => setState(() => _selectedCategory = cat['name']!),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 5 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        color: selected ? AppColors.primary : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(cat['name']!,
                        style: AppTextStyles.body.copyWith(
                          color: selected ? AppColors.textDark : AppColors.textMedium,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          // Price filter
          Text('Price Range', style: AppTextStyles.heading4
              .copyWith(letterSpacing: 0.5)),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                   keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Min',
                    hintStyle: AppTextStyles.caption,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _minPrice = double.tryParse(v)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('–', style: AppTextStyles.caption),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Max',
                    hintStyle: AppTextStyles.caption,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _maxPrice = double.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Type filter
          Text('Type', style: AppTextStyles.heading4
              .copyWith(letterSpacing: 0.5)),
          const Divider(height: 16),
          ...[
            {'label': '1 of 1 Only', 'value': 'unique'},
            {'label': 'All Pieces', 'value': 'all'},
          ].map((item) {
            final selected = _typeFilter == item['value'];
            return InkWell(
              onTap: () => setState(() => _typeFilter = item['value']!),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 5 : 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item['label']!,
                        style: AppTextStyles.body.copyWith(
                          color: selected ? AppColors.textDark : AppColors.textMedium,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrid(
      List<ProductModel> products, AuthProvider auth, CartProvider cart) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 64, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text('Aucun résultat', style: AppTextStyles.heading3),
            ],
          ),
        ),
      );
    }
    // Apply type filter after data available
    var filtered = _typeFilter == 'unique'
        ? products.where((p) => p.isOneOfAKind).toList()
        : products;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemCount: filtered.length,
      itemBuilder: (_, i) => ProductCard(
        product: filtered[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: filtered[i]),
          ),
        ),
        onAddToCart: auth.isLoggedIn
            ? () async {
                final messenger = ScaffoldMessenger.of(context);
                await cart.addProduct(auth.userId, filtered[i]);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${filtered[i].title} ajouté au panier'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
