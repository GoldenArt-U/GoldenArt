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
    {'image': 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?w=100', 'title': 'Tapis BerbÃ¨re Margoum Pur Laine', 'ref': 'TG-002', 'price': '120.00 TND', 'status': 'Active', 'views': '128'},
    {'image': '', 'title': 'Plat Ã‰maillÃ© en CÃ©ramique de Nabeul', 'ref': 'CE-003', 'price': '28.00 TND', 'status': 'Draft', 'views': 'â€”'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isSeller) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: const Center(child: Text('This area is restricted to approved artisans.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: AppColors.border,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text('My Studio', style: AppTextStyles.heading3),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('List New Item', style: AppTextStyles.button),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            Row(
              children: [
                _statCard('Active Listings', '12', AppColors.dark),
                const SizedBox(width: 12),
                _statCard('Total Sales (TND)', '4,250', AppColors.primary),
                const SizedBox(width: 12),
                _statCard('Store Views (30d)', '1,842', AppColors.dark),
              ],
            ),
            const SizedBox(height: 24),
            // Inventory table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                      color: Color(0xFFF9FAFB),
                    ),
                    child: Text('Active Inventory', style: AppTextStyles.heading3),
                  ),
                  // Table header
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
                  const Divider(height: 1),
                  ..._inventoryItems.map((item) => _inventoryRow(item)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildOffersTable(auth.userId),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersTable(String artisanId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              color: Color(0xFFF9FAFB),
            ),
            child: Text('Incoming Offers', style: AppTextStyles.heading3),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService().getOffersForArtisan(artisanId),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
              }
              final offers = snapshot.data ?? [];
              if (offers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('No incoming offers yet.', style: AppTextStyles.body)),
                );
              }
              return Column(
                children: offers.map((offer) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(offer['productTitle'] ?? 'Unknown Item', style: AppTextStyles.bodyMedium),
                    subtitle: Text('Offer: ${offer['amount']} TND | Status: ${offer['status']}'.toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    trailing: offer['status'] == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: AppColors.success),
                                onPressed: () => FirestoreService().updateOfferStatus(offer['id'], 'accepted'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: AppColors.error),
                                onPressed: () => FirestoreService().updateOfferStatus(offer['id'], 'rejected'),
                              ),
                            ],
                          )
                        : null,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: AppTextStyles.captionBold.copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.heading1.copyWith(color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _inventoryRow(Map<String, String> item) {
    final isActive = item['status'] == 'Active';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
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
                    color: const Color(0xFFF3F4F6),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: item['image']!.isNotEmpty
                      ? Image.network(item['image']!, fit: BoxFit.cover)
                      : const Center(child: Text('â€”', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('Ref: ${item['ref']}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(item['price']!, style: AppTextStyles.bodyMedium)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['status']!,
                style: AppTextStyles.captionBold.copyWith(
                  color: isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(flex: 1, child: Text(item['views']!, style: AppTextStyles.caption)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text('Edit',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Text('Unlist',
                      style: AppTextStyles.caption.copyWith(color: const Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}