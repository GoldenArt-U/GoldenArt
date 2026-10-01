import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/screens/add_product_screen.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _inventoryItems = [
    {'image': 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=100', 'title': 'Poterie Rustique de Sejnane', 'ref': 'PT-001', 'price': '35.00 TND', 'status': 'Active', 'views': '342'},
    {'image': 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?w=100', 'title': 'Tapis Berbère Margoum Pur Laine', 'ref': 'TG-002', 'price': '120.00 TND', 'status': 'Active', 'views': '128'},
    {'image': '', 'title': 'Plat Émaillé en Céramique de Nabeul', 'ref': 'CE-003', 'price': '28.00 TND', 'status': 'Draft', 'views': '—'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isSeller) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Unauthorized')),
        body: Center(
            child: Text('This area is restricted to approved artisans.',
                style: AppTextStyles.body)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('My Studio', style: AppTextStyles.heading3),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AddProductScreen())),
              icon: const Icon(Icons.add, size: 16),
              label: Text('List New Item', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats ──────────────────────────────────────────────────────
            Row(
              children: [
                _statCard('Active Listings', '12', Colors.white),
                const SizedBox(width: 12),
                _statCard('Total Sales TND', '4,250', AppColors.primary),
                const SizedBox(width: 12),
                _statCard('Views 30d', '1,842', Colors.white),
              ],
            ),
            const SizedBox(height: 24),

            // ── Inventory Table ─────────────────────────────────────────────
            _glassSection(
              title: 'Active Inventory',
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('ITEM', style: AppTextStyles.captionBold.copyWith(letterSpacing: 1))),
                        Expanded(flex: 1, child: Text('PRICE', style: AppTextStyles.captionBold.copyWith(letterSpacing: 1))),
                        Expanded(flex: 1, child: Text('STATUS', style: AppTextStyles.captionBold.copyWith(letterSpacing: 1))),
                        Expanded(flex: 1, child: Text('VIEWS', style: AppTextStyles.captionBold.copyWith(letterSpacing: 1))),
                        Expanded(flex: 1, child: Text('ACTIONS', style: AppTextStyles.captionBold.copyWith(letterSpacing: 1), textAlign: TextAlign.end)),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.divider, height: 1),
                  ..._inventoryItems.map((item) => _inventoryRow(item)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Incoming Offers ─────────────────────────────────────────────
            _buildOffersSection(auth.userId),
          ],
        ),
      ),
    );
  }

  Widget _glassSection({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08))),
                ),
                child: Row(children: [
                  Container(
                      width: 3, height: 16, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(title, style: AppTextStyles.heading3),
                ]),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: AppTextStyles.captionBold
                        .copyWith(letterSpacing: 0.8)),
                const SizedBox(height: 8),
                Text(value,
                    style: AppTextStyles.heading1
                        .copyWith(color: valueColor, fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inventoryRow(Map<String, String> item) {
    final isActive = item['status'] == 'Active';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: item['image']!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(item['image']!,
                              fit: BoxFit.cover))
                      : Center(
                          child: Text('—',
                              style: AppTextStyles.caption)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text('Ref: ${item['ref']}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(item['price']!, style: AppTextStyles.price)),
          Expanded(
            flex: 1,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.success.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isActive
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                item['status']!,
                style: AppTextStyles.captionBold.copyWith(
                  color: isActive
                      ? AppColors.success
                      : AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(item['views']!, style: AppTextStyles.caption)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text('Edit',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Text('Unlist',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(String artisanId) {
    return _glassSection(
      title: 'Incoming Offers',
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getOffersForArtisan(artisanId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)));
          }
          final offers = snapshot.data ?? [];
          if (offers.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                  child: Text('No incoming offers yet.',
                      style: AppTextStyles.body)),
            );
          }
          return Column(
            children: offers.map((offer) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(offer['productTitle'] ?? 'Unknown Item',
                    style: AppTextStyles.bodyMedium),
                subtitle: Text(
                    'Offer: ${offer['amount']} TND | Status: ${offer['status']}'
                        .toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
                trailing: offer['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle,
                                color: AppColors.success),
                            onPressed: () =>
                                FirestoreService().updateOfferStatus(
                                    offer['id'], 'accepted'),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel,
                                color: AppColors.error),
                            onPressed: () =>
                                FirestoreService().updateOfferStatus(
                                    offer['id'], 'rejected'),
                          ),
                        ],
                      )
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
